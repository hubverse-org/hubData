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
#' @examples
#' # Clone example hub
#' tmp_hub_path <- withr::local_tempdir()
#' example_hub <- "https://github.com/hubverse-org/example-complex-forecast-hub.git"
#' gert::git_clone(url = example_hub, path = tmp_hub_path)
#' # Connect to oracle-output data
#' oo_con <- connect_target_oracle_output(tmp_hub_path)
#' oo_con
#' # Collect all oracle-output data
#' oo_con |> dplyr::collect()
#' # Filter for a specific date before collecting
#' oo_con |>
#'   dplyr::filter(target_end_date == "2022-11-12") |>
#'   dplyr::collect()
#' # Filter for a specific location before collecting
#' oo_con |>
#'   dplyr::filter(location == "US") |>
#'   dplyr::collect()
#' # Get distinct target_end_date values
#' oo_con |>
#'   dplyr::distinct(target_end_date) |>
#'   dplyr::pull(as_vector = TRUE)
#' # Access Target oracle-output data from a cloud hub
#' s3_hub_path <- s3_bucket("example-complex-forecast-hub")
#' s3_con <- connect_target_oracle_output(s3_hub_path)
#' s3_con
#' s3_con |> dplyr::collect()
connect_target_oracle_output <- function(hub_path = ".", na = c("NA", ""),
                                         ignore_files = NULL) {
  ignore_files <- unique(c(ignore_files, "README", ".DS_Store"))
  oo_path <- validate_target_data_path(hub_path, "oracle-output")
  oo_ext <- get_target_file_ext(hub_path, oo_path)
  oo_schema <- create_oracle_output_schema(hub_path, ignore_files = ignore_files)
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
    ext = oo_ext, schema = oo_schema,
    na = na, ignore_files = ignore_files
  )

  structure(oo_data,
    class = c("target_oracle_output", class(oo_data)),
    oo_path = out_path,
    hub_path = hub_path
  )
}
