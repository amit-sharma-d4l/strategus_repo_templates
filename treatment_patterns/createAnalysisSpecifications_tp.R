################################################################################
# Strategus Treatment Patterns Study: Depression Treatment Sequences
################################################################################

library(Strategus)
library(dplyr)

# Study period
studyStartDate <- "19001201"
studyEndDate <- "20231231"

# Load all cohorts
cohortDefinitionSet <- CohortGenerator::getCohortDefinitionSet(
  # settingsFileName = "./atlas_cohorts/Cohorts.csv",
  # jsonFolder = "./atlas_cohorts/cohorts",
  # sqlFolder = "./atlas_cohorts/sql/sql_server"

  settingsFileName = "./gibleed_cohorts/Cohorts.csv",
  jsonFolder = "./gibleed_cohorts/cohorts",
  sqlFolder = "./gibleed_cohorts/sql/sql_server"
)

# Shared resources
cgModuleSettingsCreator <- CohortGeneratorModule$new()
cohortDefinitionShared <- cgModuleSettingsCreator$createCohortSharedResourceSpecifications(cohortDefinitionSet)
cohortGeneratorModuleSpecifications <- cgModuleSettingsCreator$createModuleSpecifications(generateStats = TRUE)

# TreatmentPatterns module setup
tpModuleSettingsCreator <- TreatmentPatternsModule$new()
cohorts_frame = data.frame(
                cohortId = c(1, 3),
                cohortName = c("celecoxib", "GI Bleed"),
                type = c("target", "event")
            )
# cohorts_frame = data.frame(
#                 cohortId = c(1, 2, 3, 4),
#                 cohortName = c("depression", "SSRI", "SNRI", "BUPROPION"),
#                 type = c("target", "event", "event", "event")
#             )
treatmentPatternsSpecifications <- tpModuleSettingsCreator$createModuleSpecifications(
  cohorts = cohorts_frame, 
  windowEnd = 365
)

# Create analysis spec
# Create analysis spec
analysisSpecifications <- Strategus::createEmptyAnalysisSpecificiations() |>
  Strategus::addSharedResources(cohortDefinitionShared) |>
  Strategus::addModuleSpecifications(cohortGeneratorModuleSpecifications) |>
  Strategus::addModuleSpecifications(treatmentPatternsSpecifications)

# Save JSON
ParallelLogger::saveSettingsToJson(
  analysisSpecifications,
  file.path("./", "analysis_specs_tp.json")
)
print("Analysis specifications saved successfully.")