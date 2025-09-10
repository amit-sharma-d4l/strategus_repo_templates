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
  settingsFileName = "inst/Eunomia/sampleStudy/treatment_util/Cohorts.csv",
  jsonFolder = "inst/Eunomia/sampleStudy/treatment_util/cohorts",
  sqlFolder = "inst/Eunomia/sampleStudy/treatment_util/sql/sql_server"
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
  windowEnd = 730
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
  file.path("inst", "Eunomia", "SampleStudy", "treatmentPatternsAnalysisSpecification.json")
)
print("Analysis specifications saved successfully.")