################################################################################
# INSTRUCTIONS: This R script defines a Strategus-based Kaplan-Meier survival
#               analysis study using the CohortSurvival module.
################################################################################

library(dplyr)
library(Strategus)

# Study time window
studyStartDate <- '19000101' # YYYYMMDD
studyEndDate <- '20231231'   # YYYYMMDD

# Load cohort definitions
cohortDefinitionSet <- CohortGenerator::getCohortDefinitionSet(
  settingsFileName = "inst/Eunomia/sampleStudy/Cohorts.csv",
  jsonFolder = "inst/Eunomia/sampleStudy/cohorts",
  sqlFolder = "inst/Eunomia/sampleStudy/sql/sql_server"
)

# Target and outcome cohorts
targetCohortTable <- "target_cohort"
outcomeCohortTable <- "outcome_cohort"

# Stratification variables (if any)
strata <- list(
  ageGroup = c("age_group"),
  gender = c("gender")
)

# Time gap and follow-up period
timeGap <- 7  # Time gap in days
followUp <- 365  # Follow-up period in days

# Minimum cell count for privacy protection
minCellCount <- 5

# CohortSurvivalModule ---------------------------------------------------------
csModuleSettingsCreator <- CohortSurvivalModule$new()

cohortSurvivalModuleSpecifications <- csModuleSettingsCreator$createModuleSpecifications(
  targetCohortTable = targetCohortTable,
  outcomeCohortTable = outcomeCohortTable,
  strata = strata,
  timeGap = timeGap,
  followUp = followUp,
  minCellCount = minCellCount
)

# Cohort Generator -------------------------------------------------------------
cgModuleSettingsCreator <- CohortGeneratorModule$new()
cohortDefinitionShared <- cgModuleSettingsCreator$createCohortSharedResourceSpecifications(cohortDefinitionSet)
cohortGeneratorModuleSpecifications <- cgModuleSettingsCreator$createModuleSpecifications()

# Create the analysis specifications -------------------------------------------
analysisSpecifications <- Strategus::createEmptyAnalysisSpecificiations() |>
  Strategus::addSharedResources(cohortDefinitionShared) |>
  Strategus::addModuleSpecifications(cohortGeneratorModuleSpecifications) |>
  Strategus::addModuleSpecifications(cohortSurvivalModuleSpecifications)

# Save the analysis specifications to a JSON file
ParallelLogger::saveSettingsToJson(
  analysisSpecifications,
  file.path("inst", "Eunomia", "SampleStudy", "sampleStudyAnalysisSpecificationSurvival.json")
)