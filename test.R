# save this as csv_to_tibble.R

library(readr)
library(dplyr)
library(CohortGenerator)

# 1. Specify your CSV file path
csv_file <- "./excludedCovariateConcepts.csv"  # change this to your CSV file

data <- CohortGenerator::readCsv(file = csv_file) %>% head(50)

# 2. Function to create nicely formatted tibble code
tibble_to_code <- function(df, tibble_name = "my_tibble", max_per_line = 5) {
  format_vec <- function(vec) {
    if (is.character(vec) || is.factor(vec)) vec <- paste0("'", vec, "'")
    if (is.logical(vec)) vec <- ifelse(vec, "TRUE", "FALSE")
    
    # Split into lines for readability
    lines <- split(vec, ceiling(seq_along(vec)/max_per_line))
    line_str <- sapply(lines, function(x) paste(x, collapse = ", "))
    paste0(paste(line_str, collapse = ",\n    "))
  }
  
  cols <- sapply(names(df), function(col) {
    paste0(col, " = c(", format_vec(df[[col]]), ")")
  })
  
  code <- paste0(tibble_name, " <- tibble(\n  ", paste(cols, collapse = ",\n  "), "\n)")
  return(code)
}

# 3. Print code to paste in your script
cat(tibble_to_code(data, tibble_name = "cohorts"))