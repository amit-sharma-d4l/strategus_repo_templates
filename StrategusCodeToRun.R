library(Strategus)

# ENVIRONMENT SETTINGS NEEDED FOR RUNNING Strategus ------------
Sys.setenv("_JAVA_OPTIONS"="-Xmx4g") # Sets the Java maximum heap space to 4GB
Sys.setenv("VROOM_THREADS"=1) # Sets the number of threads to 1 to avoid deadlocks on file system

##=========== START OF INPUTS ==========
cdmDatabaseSchema <- "main"
workDatabaseSchema <- "main"
outputLocation <- file.path(getwd(), "results")
databaseName <- "results" # Only used as a folder name for results from the study
minCellCount <- 5
cohortTableName <- "sample_study"


# connectionDetails <- Eunomia::getEunomiaConnectionDetails()
# connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sqlite", server = "/var/folders/t2/g6fq88md4sv1vj5pl0t16h3h0000gn/T//Rtmp9onkHk/file13c768e6c138.sqlite")
# connect to synpuf
cdmDatabaseSchema <- "cdm_5pct_9a0f90a32250497d9483c981ef1e1e70"
connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms='postgresql', 
    connectionString='jdbc:postgresql://localhost:41192/alpdev_pg',
    user="postgres",
    # user="alp_pg_admin_user",
    
    password='MACDwXdyA6NGRTuxnrBY28R0E',
    pathToDriver = '/Users/amit.sharma/Documents/Projects/d2e/flows/_shared_flow_utils'
)

# clean results folder
results_folder <- file.path(outputLocation)
cat("Trying to delete previousfolders:", results_folder, "\n")
# Remove everything inside the folder
if (dir.exists(results_folder)) {
  unlink(results_folder, recursive = TRUE, force = TRUE)
}
# Recreate the empty folder (optional, if Strategus expects it to exist)
dir.create(results_folder, showWarnings = FALSE, recursive = TRUE)
if (!dir.exists(file.path(outputLocation, databaseName))) {
  dir.create(file.path(outputLocation, databaseName), recursive = T)
}

analysisSpecifications <- ParallelLogger::loadSettingsFromJson(
  fileName = "inst/Eunomia/sampleStudy/treatmentPatternsAnalysisSpecification.json"
)

executionSettings <- createCdmExecutionSettings(
  workDatabaseSchema = workDatabaseSchema,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable = cohortTableName),
  workFolder = file.path(outputLocation, databaseName, "strategusWork"),
  resultsFolder = file.path(outputLocation, databaseName, "strategusOutput"),
  minCellCount = minCellCount
)


# ParallelLogger::saveSettingsToJson(
#   object = executionSettings,
#   fileName = file.path(outputLocation, databaseName, "executionSettings.json")
# )

execute(
  analysisSpecifications = analysisSpecifications,
  executionSettings = executionSettings,
  connectionDetails = connectionDetails
)

print("Strategus execution complete")
# # upload results to db
# resultsFolder <- file.path(outputLocation, databaseName, "strategusOutput")

# print("creating database model")
# resultsDataModelSettings <- createResultsDataModelSettings(
#   resultsDatabaseSchema = cdmDatabaseSchema,
#   resultsFolder = resultsFolder,
#   logFileName = file.path(resultsFolder, "strategus-results-data-model-log.txt"),
# )

# createResultDataModel(
#   analysisSpecifications = analysisSpecifications,
#   resultsDataModelSettings = resultsDataModelSettings,
#   resultsConnectionDetails = connectionDetails
# )
# print("Uploading results")
# uploadResults(
#   analysisSpecifications = analysisSpecifications,
#   resultsDataModelSettings = resultsDataModelSettings,
#   resultsConnectionDetails = connectionDetails
# )

