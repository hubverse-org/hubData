#' Open connection to time-series target data
#'
#' `r lifecycle::badge("experimental")` Open the time-series target data file(s)
#' in a hub as an arrow dataset.
#' @inheritParams connect_hub
#' @param date_col Optional column name to be interpreted as date. Default is `NULL`.
#' Useful when the required date column is a partitioning column in the target data
#' and does not have the same name as a date typed task ID variable in the config.
#'
#' @returns An arrow dataset object of subclass <target_timeseries>.
#' @export
#' @details
#' If the target data is split across multiple files in a `time-series` directory,
#' all files must share the same file format, either csv or parquet.
#' No other types of files are currently allowed in a `time-series` directory.
#'
#' @examples
#' # Clone example hub
#' tmp_hub_path <- withr::local_tempdir()
#' example_hub <- "https://github.com/hubverse-org/example-complex-forecast-hub.git"
#' gert::git_clone(url = example_hub, path = tmp_hub_path)
#' # Connect to time-series data
#' ts_con <- connect_target_timeseries(tmp_hub_path)
#' ts_con
#' # Collect all time-series data
#' ts_con |> dplyr::collect()
#' # Filter for a specific date before collecting
#' ts_con |>
#'   dplyr::filter(date == "2020-01-11") |>
#'   dplyr::collect()
#' # Filter for a specific location before collecting
#' ts_con |>
#'   dplyr::filter(location == "US") |>
#'   dplyr::collect()
#' # Access Target time-series data from a cloud hub
#' s3_hub_path <- s3_bucket("example-complex-forecast-hub")
#' s3_con <- connect_target_timeseries(s3_hub_path)
#' s3_con
#' s3_con |> dplyr::collect()
connect_target_timeseries <- function(hub_path = ".", date_col = NULL,
                                      na = c("NA", ""),
                                      ignore_files = NULL) {
  ignore_files <- unique(c(ignore_files, "README", ".DS_Store"))
  ts_path <- validate_target_data_path(hub_path, "time-series")
  ts_ext <- get_target_file_ext(hub_path, ts_path)
  ts_schema <- create_timeseries_schema(hub_path, date_col,
    na = na,
    ignore_files = ignore_files
  )
  if (inherits(hub_path, "SubTreeFileSystem")) {
    # We create URI paths for cloud storage to ensure we can open single file
    # data correctly.
    ts_path <- file_system_path(hub_path, ts_path, uri = TRUE)
    hub_path <- file_system_path(hub_path, "", uri = TRUE)
    out_path <- ts_path
  } else {
    out_path <- as.character(fs::path_rel(ts_path, hub_path))
  }
  ts_data <- open_target_dataset(
    ts_path,
    ext = ts_ext, schema = ts_schema,
    na = na, ignore_files = ignore_files
  )

  structure(ts_data,
    class = c("target_timeseries", class(ts_data)),
    ts_path = out_path,
    hub_path = hub_path
  )
}
