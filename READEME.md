## ** Simplified version of original code (from Strategus Repo) to include just PLP study on 1 target cohort and 1 outcome cohort. **

Changes in the simplified version

1. Removed all modules except CohortGenerator and PLP
2. Removed subset and negative control outcomes
3. Modified study dates to cater for longer analysis

Please follow the following steps to use this code -

1. Clone the original strategus repo (from https://github.com/ohdsi-studies/StrategusStudyRepoTemplate.git)
2. Add the R files from this branch to the cloned repo
3. Remove unncessary cohort (sql and json defintions)
4. Execute the simplified PLP R script to create specification
5. Execute the StrategusCodeToRun.R file using the simplified json created above.

Experiments -

1. Try with different train-test split values.
2. Try 1 fold validation instead of 3.
3. Try different ML models
