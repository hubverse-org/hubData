#' Open connection to time-series target data
#'
#' `r lifecycle::badge("experimental")` Open the time-series target data file(s)
#' in a hub as an arrow dataset.
#' @param hub_path Path to hub directory. Defaults to current working directory.
#'
#' @returns An arrow dataset object of subclass <target_timeseries>.
#' @export
#' @details
#' If the target data is split across multiple files in a `time-series` directory,
#' all files must share the same file format, either csv or parquet.
#' No other types of flies are currently allowed in a `time-series` directory.
#'
#' @examples
#' # Clone example hub
#' tmp_hub_path <- withr::local_tempdir()
#' example_hub <- "https://github.com/hubverse-org/example-complex-forecast-hub.git"
#' git2r::clone(url = example_hub, local_path = tmp_hub_path)
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
connect_target_timeseries <- function(hub_path = ".") {
  checkmate::assert_character(hub_path, len = 1L)
  checkmate::assert_directory_exists(hub_path)

  ts_path <- validate_target_data_path(hub_path, "time-series")
  ts_ext <- get_target_file_ext(ts_path)
  ts_schema <- create_timeseries_schema(hub_path)

  ts_data <- if (ts_ext == "csv") {
    arrow::open_dataset(ts_path,
      format = "csv", schema = ts_schema,
      skip = 1L
    )
  } else {
    arrow::open_dataset(ts_path,
      format = "parquet", schema = ts_schema
    )
  }

  structure(ts_data,
    class = c("target_timeseries", class(ts_data)),
    ts_path = as.character(fs::path_rel(ts_path, hub_path))
  )
}
