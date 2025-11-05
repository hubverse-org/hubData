#' Open connection to oracle-output target data
#'
#' `r lifecycle::badge("experimental")` Open the oracle-output target data file(s)
#' in a hub as an arrow dataset.
#' @inheritParams connect_hub
#'
#' @returns An arrow dataset object of subclass <target_oracle_output>.
#' @export
#' @details
#' If the target data is split across multiple files in a `oracle-output` directory,
#' all files must share the same file format, either csv or parquet.
#' No other types of files are currently allowed in a `oracle-output` directory.
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
#' **Pre-v6 hubs**: Original file ordering is preserved regardless of format.
#'
#' @examples
#' # Column Ordering: CSV vs Parquet in v6+ hubs
#' # For v6+ hubs with target-data.json, ordering differs by file format
#'
#' # Example 1: CSV format (single file) - preserves original file ordering
#' hub_path_csv <- system.file("testhubs/v6/target_file", package = "hubUtils")
#' oo_con_csv <- connect_target_oracle_output(hub_path_csv)
#'
#' # CSV columns are in their original file order
#' names(oo_con_csv)
#'
#' # Collect and filter as usual
#' oo_con_csv |> dplyr::collect()
#' oo_con_csv |>
#'   dplyr::filter(location == "US") |>
#'   dplyr::collect()
#'
#' # Example 2: Parquet format (directory) - reordered to hubverse convention
#' hub_path_parquet <- system.file("testhubs/v6/target_dir", package = "hubUtils")
#' oo_con_parquet <- connect_target_oracle_output(hub_path_parquet)
#'
#' # Parquet columns follow hubverse convention (date first, then alphabetical)
#' names(oo_con_parquet)
#'
#' # Reordering is safe for Parquet because it matches columns by name
#' # rather than position during collection
#' oo_con_parquet |> dplyr::collect()
#'
#' # Both formats support the same filtering operations
#' oo_con_parquet |>
#'   dplyr::filter(target_end_date ==  "2022-12-31") |>
#'   dplyr::collect()
#'
#' # Get distinct target_end_date values
#' oo_con_parquet |>
#'   dplyr::distinct(target_end_date) |>
#'   dplyr::pull(as_vector = TRUE)
#'
#' \dontrun{
#' # Access Target oracle-output data from a cloud hub
#' s3_hub_path <- s3_bucket("example-complex-forecast-hub")
#' s3_con <- connect_target_oracle_output(s3_hub_path)
#' s3_con
#' s3_con |> dplyr::collect()
#' }
connect_target_oracle_output <- function(
  hub_path = ".",
  na = c("NA", ""),
  ignore_files = NULL,
  output_type_id_datatype = c(
    "from_config",
    "auto",
    "character",
    "double",
    "integer",
    "logical",
    "Date"
  )
) {
  output_type_id_datatype <- rlang::arg_match(output_type_id_datatype)
  ignore_files <- unique(c(ignore_files, "README", ".DS_Store"))
  oo_path <- validate_target_data_path(hub_path, "oracle-output")
  oo_ext <- get_target_file_ext(hub_path, oo_path)
  oo_schema <- create_oracle_output_schema(
    hub_path,
    ignore_files = ignore_files,
    output_type_id_datatype = output_type_id_datatype
  )
  if (inherits(hub_path, "SubTreeFileSystem")) {
    # We create URI paths for cloud storage to ensure we can open single file
    # data correctly.
    oo_path <- file_system_path(hub_path, oo_path, uri = TRUE)
    hub_path <- file_system_path(hub_path, "", uri = TRUE)
    out_path <- oo_path
  } else {
    out_path <- as.character(fs::path_rel(oo_path, hub_path))
  }

  oo_data <- open_target_dataset(
    oo_path,
    ext = oo_ext,
    schema = oo_schema,
    na = na,
    ignore_files = ignore_files
  )

  structure(
    oo_data,
    class = c("target_oracle_output", class(oo_data)),
    oo_path = out_path,
    hub_path = hub_path
  )
}
