#' Create time-series target data file schema
#'
#' @param hub_path Path to hub directory
#' @param date_col Optional column name to be interpreted as date. Default is `NULL`.
#' Useful when the required date column is a partitioning column in the target data
#' and does not have the same name as a date typed task ID variable in the config.
#'
#' @return an arrow `<schema>` class object
#' @export
#' @importFrom rlang !!!
#' @examples
#' #' # Clone example hub
#' tmp_hub_path <- withr::local_tempdir()
#' example_hub <- "https://github.com/hubverse-org/example-complex-forecast-hub.git"
#' git2r::clone(url = example_hub, local_path = tmp_hub_path)
#' # Create target time-series schema
#' create_timeseries_schema(tmp_hub_path)
create_timeseries_schema <- function(hub_path, date_col = NULL) {
  checkmate::assert_character(hub_path, len = 1L)
  checkmate::assert_directory_exists(hub_path)
  ts_path <- validate_target_data_path(hub_path, "time-series")

  config_tasks <- hubUtils::read_config(hub_path)
  hub_schema <- create_hub_schema(config_tasks)

  ts_ext <- validate_target_file_ext(ts_path)
  file_schema <- arrow::open_dataset(ts_path, format = ts_ext)$schema

  ts_schema <- hub_schema[hub_schema$names %in% file_schema$names]
  ts_schema[["as_of"]] <- arrow::date32()
  ts_schema[["observation"]] <- hub_schema[["value"]]$type

  missing <- setdiff(file_schema$names, ts_schema$names)
  ts_schema <- arrow::schema(!!!c(ts_schema$fields, file_schema[missing]$fields))

  if (!is.null(date_col)) {
    checkmate::assert_character(date_col, len = 1L)
    if (!date_col %in% ts_schema$names) {
      cli::cli_abort(
        c(
          "x" = "Column {.arg {date_col}} not found in {.path {basename(ts_path)}} file(s).",
          "i" = "Column must be present in the file or partition to be used as the date column."
        )
      )
    }
    ts_schema[[date_col]] <- arrow::date32()
  }

  has_date_col <- any(
    purrr::map_lgl(
      ts_schema[ts_schema$names != "as_of"]$fields,
      ~ .x$type == arrow::date32()
    )
  )
  if (!has_date_col) {
    cli::cli_abort(
      c(
        "x" = "No {.cls date} type column found in {.path {basename(ts_path)}}.",
        "i" = "Must contain at least one column other than optional {.arg as_of}
        column interprettable as {.cls date}."
      )
    )
  }
  ts_schema[file_schema$names]
}
