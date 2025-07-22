library(DatabaseConnector)
library(SqlRender)

# 1. Connect to OMOP SQLite database
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "sqlite",
  server = "/var/folders/t2/g6fq88md4sv1vj5pl0t16h3h0000gn/T//RtmpELJpaf/file4db1281392cb.sqlite"
)
conn <- DatabaseConnector::connect(connectionDetails)


# 2. Define SQL with @cdm_database_schema placeholder
sql <- "
SELECT 
  MIN(event_date) AS global_min_date,
  MAX(event_date) AS global_max_date
FROM (
  SELECT drug_exposure_start_date AS event_date FROM @cdm_database_schema.drug_exposure
  UNION ALL
  SELECT condition_start_date AS event_date FROM @cdm_database_schema.condition_occurrence
  UNION ALL
  SELECT procedure_date AS event_date FROM @cdm_database_schema.procedure_occurrence
  UNION ALL
  SELECT measurement_date AS event_date FROM @cdm_database_schema.measurement
  UNION ALL
  SELECT observation_date AS event_date FROM @cdm_database_schema.observation
) all_events;
"

# 3. Render and translate for SQLite
renderedSql <- SqlRender::render(
  sql,
  cdm_database_schema = "main"
)
translatedSql <- SqlRender::translate(
  renderedSql,
  targetDialect = "sqlite"
)

# 4. Execute the query and retrieve result
result <- DatabaseConnector::querySql(conn, translatedSql)
print(result)

# 5. Disconnect
DatabaseConnector::disconnect(conn)