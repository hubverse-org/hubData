# Schema fixtures =====
oracle_output_schema_fixture <- function(
  partition_col = NULL, # e.g. "target_end_date", "target", or NULL
  output_type_id = c("string", "double") # match test case
) {
  output_type_id <- rlang::arg_match(output_type_id)

  output_type_id_type <- switch(
    output_type_id,
    string = arrow::string(),
    double = arrow::float64()
  )

  schema_obj <- arrow::schema(
    location = arrow::string(),
    target_end_date = arrow::date32(),
    target = arrow::string(),
    output_type = arrow::string(),
    output_type_id = output_type_id_type,
    oracle_value = arrow::float64()
  )

  if (!is.null(partition_col) && partition_col %in% names(schema_obj)) {
    # Move partition col to end
    schema_obj <- schema_obj[c(
      setdiff(names(schema_obj), partition_col),
      partition_col
    )]
  }

  schema_obj$ToString()
}

timeseries_schema_fixture <- function(
  partition_col = NULL # e.g. "target_end_date", "target", or NULL
) {
  schema_obj <- arrow::schema(
    target_end_date = arrow::date32(),
    target = arrow::string(),
    location = arrow::string(),
    observation = arrow::float64()
  )

  if (!is.null(partition_col) && partition_col %in% names(schema_obj)) {
    # Move partition col to end
    schema_obj <- schema_obj[c(
      setdiff(names(schema_obj), partition_col),
      partition_col
    )]
  }

  schema_obj$ToString()
}
