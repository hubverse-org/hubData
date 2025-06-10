#' Determine and validate the path to a given target data file/directory
#'
#' The function checks that the appropriate target data file/directory can be
#' exclusively identified, exists and contains file(s) with a single file format.
#' @param hub_path Path to hub directory.
#' @param target_type Type of target data to validate. One of "time-series" or
#' "oracle-output".
#' @param call Internal parameter for error messaging.
#'
#' @returns The path to the appropriate target data file/directory invisibly.
#' @noRd
validate_target_data_path <- function(
    hub_path, target_type = c(
      "time-series",
      "oracle-output"
    ),
    call = rlang::caller_env()) {
  target_type <- rlang::arg_match(target_type)
  ts_path <- get_target_path(hub_path, target_type)

  if (length(ts_path) == 0L) {
    cli::cli_abort(
      c("x" = "No {.field {target_type}} data found in {.path target-data} directory"),
      call = call
    )
  }
  if (length(ts_path) > 1L) {
    cli::cli_abort(
      c(
        "x" = "Multiple {.field {target_type}} data found in hub {.path target-data} directory",
        stats::setNames(paste0("{.path ", basename(ts_path), "}"), rep("*", length(ts_path)))
      ),
      call = call
    )
  }
  validate_target_file_ext(ts_path, hub_path = hub_path, call = call)

  invisible(ts_path)
}

#' Determine and validate the file extension of the target data file(s) in `ts_path`.
#'
#' @param ts_path Path to target data file/directory.
#' @param hub_path If not `NULL`, must be a `SubTreeFileSystem` class object of a
#' cloud hosted hub root. Required to trigger `SubTreeFileSystem` method.
#' @param call Internal parameter for error messaging.
#'
#' @returns The file extension of the target data file(s) invisibly.
#' @noRd
validate_target_file_ext <- function(ts_path, hub_path = NULL, call = rlang::caller_env()) {
  ts_ext <- get_target_file_ext(hub_path, ts_path)
  target_type <- fs::path_file(ts_path) |> fs::path_ext_remove() # nolint: object_usage_linter

  if (length(ts_ext) > 1L) {
    cli::cli_abort(
      c(
        "x" = "Multiple data file formats ({.val {ts_ext}}) found in
          {.path {fs::path('target-data', target_type)}} directory",
        "!" = "{.field {target_type}} target data files must all share the same format."
      ),
      call = call
    )
  }

  valid_ext <- c("csv", "parquet")
  invalid_ext <- setdiff(ts_ext, valid_ext)
  if (length(invalid_ext) > 0L) {
    cli::cli_abort(
      c(
        "x" = "Unsupported {.field {target_type}} file {cli::qty(length(invalid_ext))}
        format{?s} {.code {invalid_ext}} detected",
        "i" = "Must be one of: {.code {valid_ext}}"
      ),
      call = call
    )
  }
  invisible(ts_ext)
}

#' Get target data file unique file extensions.
#'
#' Get the unique file extension(s) of the target data file(s) in `target_path`.
#' If `target_path` is a directory, the function will return the unique file
#' extensions of all files in the directory. If `target_path` is a file,
#' the function will return the file extension of that file.
#' @param hub_path If not `NULL`, must be a `SubTreeFileSystem` class object of
#' the root to a cloud hosted hub. Required to trigger the `SubTreeFileSystem`
#' method.
#' @param target_path character string. The path to the target data
#' file or directory. Usually the output of [get_target_path()].
#'
#' @export
#' @examples
#' hub_path <- withr::local_tempdir()
#' example_hub <- "https://github.com/hubverse-org/example-complex-forecast-hub.git"
#' gert::git_clone(url = example_hub, path = hub_path)
#' target_path <- get_target_path(hub_path, "time-series")
#' get_target_file_ext(hub_path, target_path)
get_target_file_ext <- function(hub_path = NULL, target_path) {
  checkmate::assert_character(target_path, len = 1L)
  UseMethod("get_target_file_ext")
}

# Get the file extension of the target data file(s) in `target_path`. Assumes the target data
# path has been validated first.
#' @noRd
#' @export
get_target_file_ext.default <- function(hub_path = NULL, target_path) {
  if (fs::is_dir(target_path)) {
    ts_dir_paths <- fs::dir_ls(target_path, type = "file", recurse = TRUE)
    return(unique(fs::path_ext(ts_dir_paths)))
  }
  fs::path_ext(target_path)
}

#' @noRd
#' @export
get_target_file_ext.SubTreeFileSystem <- function(hub_path = NULL, target_path) {
  is_dir <- is_cloud_dir(hub_path, target_path)
  if (is_dir) {
    ts_dir_paths <- hub_path$path(target_path)$ls(
      recursive = TRUE,
      allow_not_found = TRUE
    )

    return(setdiff(unique(fs::path_ext(ts_dir_paths)), ""))
  }
  fs::path_ext(target_path)
}

#' Get the path(s) to the target data file(s) in the hub directory.
#'
#' @inheritParams connect_hub
#' @param target_type Type of target data to retrieve matching files. One of "time-series" or
#' "oracle-output". Defaults to "time-series".
#'
#' @returns a character vector of path(s) to target data file(s) (in the `target-data` directory) that make the
#' `target_type` requested.
#' @export
#'
#' @examples
#' hub_path <- withr::local_tempdir()
#' example_hub <- "https://github.com/hubverse-org/example-complex-forecast-hub.git"
#' gert::git_clone(url = example_hub, path = hub_path)
#' get_target_path(hub_path)
#' get_target_path(hub_path, "time-series")
#' get_target_path(hub_path, "oracle-output")
#' # Access cloud data
#' s3_bucket_name <- get_s3_bucket_name(hub_path)
#' s3_hub_path <- s3_bucket(s3_bucket_name)
#' get_target_path(s3_hub_path)
#' get_target_path(s3_hub_path, "oracle-output")
get_target_path <- function(hub_path, target_type = c("time-series", "oracle-output")) {
  UseMethod("get_target_path")
}


#' @export
#' @noRd
get_target_path.default <- function(hub_path,
                                    target_type = c("time-series", "oracle-output")) {
  target_type <- rlang::arg_match(target_type)
  target_data_path <- fs::path(hub_path, "target-data")
  checkmate::assert_directory(target_data_path)

  td_files <- fs::dir_ls(target_data_path,
    regexp = target_type,
    type = c("file", "directory")
  )
  td_files[fs::path_ext_remove(basename(td_files)) == target_type]
}

#' @export
#' @noRd
get_target_path.SubTreeFileSystem <- function(hub_path,
                                              target_type = c("time-series", "oracle-output")) {
  target_type <- rlang::arg_match(target_type)
  target_data_path <- hub_path$path("target-data")

  td_files <- target_data_path$ls(allow_not_found = TRUE)
  ts_files <- td_files[fs::path_ext_remove(td_files) == target_type]
  fs::path(target_data_path$base_path, ts_files)
}

#' Retrieve the full schema for a target dataset
#'
#' Opens a target dataset at the specified path and returns its full Arrow schema.
#' The schema is constructed using both:
#'
#' 1. Column  definitions explicitly specified in the hub's configuration.
#' 2. Inferred types for any remaining columns found in the dataset but not covered by the config
#'
#' This ensures consistent typing for required fields, while still capturing any
#' extra columns  present in the data. Unlike [open_target_dataset()], this
#'  function **does not accept an override** schema, it always derives its output
#'  from the config and actual data on disk.
#' This function is used internally by [create_timeseries_schema()] and
#' [create_oracle_output_schema()] to infer canonical dataset structure before validation.
#'
#' @param path Path to a target dataset or directory.
#' @param ext File extension (`"csv"` or `"parquet"`).
#' @param na Character vector of values to interpret as missing (applies to CSV only).
#' @param ignore_files Character vector of file name prefixes to ignore when reading directories.
#'
#' @return An Arrow [schema][arrow::schema] object representing the dataset structure.
#'
#' @keywords internal
#' @noRd
get_target_schema <- function(path, ext, na, ignore_files) {
  is_dir <- fs::path_ext(path) == ""
  if (ext == "csv" && is_dir) {
    file_schema <- arrow::open_dataset(path,
      format = ext,
      na = na, quoted_na = TRUE,
      factory_options = list(
        selector_ignore_prefixes = ignore_files
      )
    )
  } else if (ext == "parquet" && is_dir) {
    file_schema <- arrow::open_dataset(path,
      format = ext,
      factory_options = list(
        selector_ignore_prefixes = ignore_files
      )
    )
  } else if (ext == "csv") {
    file_schema <- arrow::open_dataset(path,
      format = ext,
      na = na, quoted_na = TRUE
    )
  } else {
    file_schema <- arrow::open_dataset(path, format = ext)
  }
  file_schema$schema
}

#' Open a target dataset with format-specific options
#'
#' Opens a dataset using [arrow::open_dataset()] with arguments adapted based on
#' file format (`csv` or `parquet`) and whether the path is a directory or a single file.
#' For directories, `factory_options` are used to exclude ignored files via the
#' `selector_ignore_prefixes` option. CSVs are opened with common parsing options
#' such as skipping the header row and handling quoted `NA` values.
#' The schema passed here typically originates from the hub configuration and reflects the
#' expected column structure for target datasets. This function supports both file-based and
#' directory-based datasets in either `"csv"` or `"parquet"` format.
#' This function is used internally by the `connect_target_*()` family of functions to establish
#' structured access to validated target data using Arrow.
#'
#' @param path Path to a dataset or directory containing model output files.
#'   Can be a single file or a directory of files in a supported Arrow format.
#' @param ext File extension (`"csv"` or `"parquet"`).
#' @param schema An Arrow [schema][arrow::schema] describing the expected structure
#'   of the dataset.
#' @param na Character vector of values to treat as missing (`NA`) when reading CSVs.
#'   Ignored for non-CSV formats.
#' @param ignore_files Character vector of file name prefixes to ignore when reading
#'   directories (only applied if `path` is a directory).
#'
#' @return An Arrow [Dataset][arrow::Dataset] object.
#'
#' @keywords internal
#' @noRd
open_target_dataset <- function(path, ext, schema, na, ignore_files) {
  is_dir <- fs::path_ext(path) == ""
  if (ext == "csv" && is_dir) {
    arrow::open_dataset(path,
      format = ext,
      schema = schema,
      skip = 1L, quoted_na = TRUE, na = na,
      factory_options = list(
        selector_ignore_prefixes = ignore_files
      )
    )
  } else if (ext == "parquet" && is_dir) {
    arrow::open_dataset(path,
      format = ext,
      schema = schema,
      factory_options = list(
        selector_ignore_prefixes = ignore_files
      )
    )
  } else if (ext == "csv") {
    arrow::open_dataset(path,
      format = ext,
      schema = schema,
      skip = 1L, quoted_na = TRUE, na = na
    )
  } else {
    arrow::open_dataset(path,
      format = ext,
      schema = schema
    )
  }
}
