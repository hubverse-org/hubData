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
#' ## Schema Creation
#'
#' This function uses different methods to create the Arrow schema depending on
#' the hub configuration version:
#'
#' **v6+ hubs (with `target-data.json`):** Schema is created directly from the
#' `target-data.json` configuration file using [create_timeseries_schema()].
#' This config-based approach is fast and deterministic, requiring no filesystem
#' I/O to scan data files. It's especially beneficial for cloud storage where
#' file scanning can be slow.
#'
#' **Hubs (without `target-data.json`):** Schema is inferred by scanning
#' the actual data files. This inference-based approach examines file structure
#' and content to determine column types.
#'
#' The function automatically detects which method to use based on the presence
#' of `target-data.json` in the hub configuration.
#'
#' ## Schema Ordering
#'
#' Column ordering in the resulting dataset depends on configuration version and file format:
#'
#' **v6+ hubs (with `target-data.json`):**
#' - **Parquet**: Columns are reordered to the standard hubverse convention (see [get_target_data_colnames()]).
#'   Parquet's column-by-name matching enables safe reordering.
#' - **CSV**: Original file ordering is preserved to avoid column name/position mismatches during collection.
#'
#' **Hubs (without `target-data.json`)**: Original file ordering is preserved regardless of format.
#'
#' @examples
#' # Column Ordering: CSV vs Parquet in v6+ hubs
#' # For v6+ hubs with target-data.json, ordering differs by file format
#'
#' # Example 1: CSV format (single file) - preserves original file ordering
#' hub_path_csv <- system.file("testhubs/v6/target_file", package = "hubUtils")
#' ts_con_csv <- connect_target_timeseries(hub_path_csv)
#'
#' # CSV columns are in their original file order
#' names(ts_con_csv)
#' # Note: columns appear in the order they are in the CSV file
#'
#' # Collect and filter as usual
#' ts_con_csv |> dplyr::collect()
#' ts_con_csv |>
#'   dplyr::filter(location == "US") |>
#'   dplyr::collect()
#'
#' # Example 2: Parquet format (directory) - reordered to hubverse convention
#' hub_path_parquet <- system.file("testhubs/v6/target_dir", package = "hubUtils")
#' ts_con_parquet <- connect_target_timeseries(hub_path_parquet)
#'
#' # Parquet columns follow hubverse convention
#' names(ts_con_parquet)
#'
#' # Reordering is safe for Parquet because it matches columns by name
#' # rather than position during collection
#' ts_con_parquet |> dplyr::collect()
#'
#' # Both formats support the same filtering operations
#' ts_con_parquet |>
#'   dplyr::filter(target_end_date ==  "2022-12-31") |>
#'   dplyr::collect()
#'
#'\dontrun{
#' # Access Target time-series data from a cloud hub
#' s3_hub_path <- s3_bucket("example-complex-forecast-hub")
#' s3_con <- connect_target_timeseries(s3_hub_path)
#' s3_con
#' s3_con |> dplyr::collect()
#' }
connect_target_timeseries <- function(
  hub_path = ".",
  date_col = NULL,
  na = c("NA", ""),
  ignore_files = NULL
) {
  ignore_files <- unique(c(ignore_files, "README", ".DS_Store"))
  ts_path <- validate_target_data_path(hub_path, "time-series")
  ts_ext <- get_target_file_ext(hub_path, ts_path)
  ts_schema <- create_timeseries_schema(
    hub_path,
    date_col,
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
    ext = ts_ext,
    schema = ts_schema,
    na = na,
    ignore_files = ignore_files
  )

  structure(
    ts_data,
    class = c("target_timeseries", class(ts_data)),
    ts_path = out_path,
    hub_path = hub_path
  )
}
