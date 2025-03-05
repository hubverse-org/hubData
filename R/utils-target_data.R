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

#' @noRd
get_target_file_ext <- function(hub_path = NULL, ts_path) {
  UseMethod("get_target_file_ext")
}

# Get the file extension of the target data file(s) in `ts_path`. Assumes the target data
# path has been validated first.
#' @noRd
#' @export
get_target_file_ext.default <- function(hub_path = NULL, ts_path) {
  if (fs::is_dir(ts_path)) {
    ts_dir_paths <- fs::dir_ls(ts_path, type = "file", recurse = TRUE)
    return(unique(fs::path_ext(ts_dir_paths)))
  }
  fs::path_ext(ts_path)
}

#' @noRd
#' @export
get_target_file_ext.SubTreeFileSystem <- function(hub_path = NULL, ts_path) {
  is_dir <- is_cloud_dir(hub_path, ts_path)
  if (is_dir) {
    ts_dir_paths <- hub_path$path(ts_path)$ls(allow_not_found = TRUE)
    return(unique(fs::path_ext(ts_dir_paths)))
  }
  fs::path_ext(ts_path)
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
get_target_path.default <- function(hub_path, target_type = c("time-series", "oracle-output")) {
  target_type <- rlang::arg_match(target_type)
  target_data_path <- fs::path(hub_path, "target-data")
  checkmate::assert_directory(target_data_path)

  fs::dir_ls(target_data_path,
    regexp = target_type,
    type = c("file", "directory")
  )
}

#' @export
#' @noRd
get_target_path.SubTreeFileSystem <- function(hub_path, target_type = c("time-series", "oracle-output")) {
  target_type <- rlang::arg_match(target_type)
  target_data_path <- hub_path$path("target-data")

  td_files <- target_data_path$ls(allow_not_found = TRUE)
  ts_files <- td_files[grepl("time-series", td_files, ignore.case = TRUE)]
  paste0(target_data_path$base_path, ts_files)
}
