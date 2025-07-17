#' Create time-series target data file schema
#'
#' @inheritParams connect_hub
#' @param date_col Optional column name to be interpreted as date. Default is `NULL`.
#' Useful when the required date column is a partitioning column in the target data
#' and does not have the same name as a date typed task ID variable in the config.
#'
#' @return an arrow `<schema>` class object
#' @export
#' @importFrom rlang !!!
#' @importFrom hubUtils read_config
#' @examples
#' #' # Clone example hub
#' tmp_hub_path <- withr::local_tempdir()
#' example_hub <- "https://github.com/hubverse-org/example-complex-forecast-hub.git"
#' gert::git_clone(url = example_hub, path = tmp_hub_path)
#' # Create target time-series schema
#' create_timeseries_schema(tmp_hub_path)
#' #  target time-series schema from a cloud hub
#' s3_hub_path <- s3_bucket("example-complex-forecast-hub")
#' create_timeseries_schema(s3_hub_path)
create_timeseries_schema <- function(
  hub_path,
  date_col = NULL,
  na = c("NA", ""),
  ignore_files = NULL
) {
  ignore_files <- unique(c(ignore_files, "README", ".DS_Store"))
  ts_path <- validate_target_data_path(hub_path, "time-series")

  config_tasks <- read_config(hub_path)
  hub_schema <- create_hub_schema(config_tasks)

  ts_ext <- validate_target_file_ext(ts_path, hub_path)
  if (inherits(hub_path, "SubTreeFileSystem")) {
    ts_path <- file_system_path(hub_path, ts_path, uri = TRUE)
  }

  file_schema <- get_target_schema(
    ts_path,
    ext = ts_ext,
    na = na,
    ignore_files = ignore_files
  )

  ts_schema <- hub_schema[hub_schema$names %in% file_schema$names]
  ts_schema[["as_of"]] <- arrow::date32()
  ts_schema[["observation"]] <- hub_schema[["value"]]$type

  missing <- setdiff(file_schema$names, ts_schema$names)
  ts_schema <- arrow::schema(
    !!!c(ts_schema$fields, file_schema[missing]$fields)
  )

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
