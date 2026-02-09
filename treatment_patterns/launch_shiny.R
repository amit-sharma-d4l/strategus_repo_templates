library(DatabaseConnector)
library(OhdsiShinyAppBuilder)
library(OhdsiShinyModules)
library(shiny)
library(dplyr)
library(future)
library(readr)
library(TreatmentPatterns)

analysisName_base = "analysis_specs_tp"
analysisName <- paste0(analysisName_base, ".json")
results_schema_name <- paste0("res_", analysisName_base, "_amit")
resultsDatabaseSchema <- results_schema_name


# database connection and execution settings
dbms   <- "postgresql"        # dbms type (postgresql, sqlserver, oracle, ... )
server <- "127.0.0.1/study_results"  # for PostgreSQL, can be "localhost/DBNAME"
user   <- "amit.sharma"
pw     <- "Tango==1262"
port   <- 5432              # local forwarded port from your SSH tunnel
pathToDriver <- "/Users/amit.sharma/Documents/Projects"  # e.g., "/path/to/your/jdbc/driver"

# Create connection details
connectionDetails <- createConnectionDetails(
  dbms = dbms,
  server = server,
  user = user,
  password = pw,
  port = port,
  pathToDriver = pathToDriver
)

########### Treatment Patterns module ##############################
patternsModuleUI <- function(id) {
  ns <- NS(id)  # Namespace for the module
  fluidPage(
    # Dropdown to choose a dataset or option
    selectInput(
      inputId = ns("dataset"),      # namespaced ID
      label   = "Choose a dataset", # label shown to user
      choices = NULL
    ),
    # Sunburst diagram output
    sunburstR::sunburstOutput(ns("sunburst"))
  )
}

patternsModuleServer <- function(id, resultDatabaseSettings, connectionHandler) {
  moduleServer(id, function(input, output, session) {
    dataset_choices <- reactive({
      conn <- connectionHandler$getConnection()
      res <- DatabaseConnector::querySql(
        conn,
        paste0(
          "SELECT DISTINCT cdm_source_abbreviation
              FROM ", resultsDatabaseSchema, ".tp_cdm_source_info"
        )
      )
      return(res$cdm_source_abbreviation)
    })
    observeEvent(dataset_choices(), {
      updateSelectInput(
        session,
        inputId = "dataset",
        choices = dataset_choices(),
        selected = dataset_choices()[1]
      )
    })
    
    output$sunburst <- sunburstR::renderSunburst({
      req(input$dataset)  # Wait for dataset to be selected
      conn <- connectionHandler$getConnection()
      tp_data <- DatabaseConnector::querySql(
          conn,
          paste0(
          "SELECT pathway, freq, index_year, age, sex
              FROM ", resultsDatabaseSchema, ".tp_treatment_pathways
              WHERE database_id = (Select database_id from ", resultsDatabaseSchema, ".tp_cdm_source_info WHERE cdm_source_abbreviation = '", input$dataset, "')"
          )
      )
      colnames(tp_data) <- tolower(colnames(tp_data))
      createSunburstPlot(tp_data)
    })
  })
}

# ADD OR REMOVE MODULES TAILORED TO YOUR STUDY
config <- initializeModuleConfig() %>%
  addModuleConfig(
    createDefaultAboutConfig()
  )  %>%
  addModuleConfig(
    createDefaultCohortGeneratorConfig()
  ) %>%
  addModuleConfig(
    createDefaultCharacterizationConfig()
  ) %>%
  addModuleConfig(
    createDefaultPredictionConfig()
  ) %>%
  addModuleConfig(
    createDefaultEstimationConfig()
  ) %>%
  addModuleConfig(
    createModuleConfig(
      moduleId = 'patterns',
      tabName = "TreatmentPatterns",
      shinyModulePackage = NULL,
      shinyModulePackageVersion = NULL,
      moduleUiFunction = patternsModuleUI,
      moduleServerFunction = patternsModuleServer,
      moduleInfoBoxFile = function(){},
      moduleIcon = "info",
      installSource = "CRAN",
      gitHubRepo = NULL
    )
  )


############################ Launch Shiny RS Viewer ############################
connection <- ResultModelManager::ConnectionHandler$new(connectionDetails)

databaseSettings <- createDefaultResultDatabaseSettings(
    schema=resultsDatabaseSchema
  )

# OhdsiShinyAppBuilder::viewShiny(
#     config = config, 
#     connection = connection,  
#     resultDatabaseSettings = databaseSettings
# )

app <- OhdsiShinyAppBuilder::createShinyApp(
  config = config, 
  connection = connection,
  resultDatabaseSettings = databaseSettings
)

shiny::runApp(
  app, 
  host = "0.0.0.0", 
  port = 3838,
  launch.browser = TRUE
)