#' Create a full path to a file or directory in a SubTreeFileSystem object, usually in S3.
#'
#' @param hub_path a `<SubTreeFileSystem>` object representing an S3 cloud hub file system.
#' @param path a character string representing the path to a file or directory
#' relative to the cloud hub root.
#' @param uri a logical value indicating whether to return a URI or full path should be
#' return. URIs include the url schema as a prefix to the path.
#'
#' @returns A character string representing the full path/URI to the file or directory
#' in `path`.
#' @noRd
#' @examples
#' hub_path <- s3_bucket("example-complex-forecast-hub")
#' file_system_path(hub_path, "target-data/times-series.csv")
#' file_system_path(hub_path, "target-data/times-series.csv", uri = TRUE)
file_system_path <- function(hub_path, path, uri = FALSE) {
  if (!inherits(hub_path, "SubTreeFileSystem")) {
    cli::cli_abort("{.arg hub_path} must be a {.cls SubTreeFileSystem} object")
  }
  prefix <- NULL
  if (uri) {
    prefix <- paste0(hub_path$url_scheme, "://")
  }

  paste0(prefix, fs::path(hub_path$base_path, path))
}


#' Get the bucket name for the cloud storage location.
#'
#' @param hub_path Path to a hub directory.
#'
#' @returns The bucket name for the cloud storage location.
#' @export
#'
#' @examples
#' hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
#' get_s3_bucket_name(hub_path)
#' # Get config info from GitHub
#' get_s3_bucket_name(
#'   "https://github.com/hubverse-org/example-complex-forecast-hub"
#' )
get_s3_bucket_name <- function(hub_path = ".") {
  config_admin <- hubUtils::read_config(hub_path, "admin")
  if (!config_admin$cloud$enabled) {
    cli::cli_warn(c("!" = "Cloud storage is not enabled."))
  }
  config_admin$cloud$host$storage_location
}

is_cloud_dir <- function(hub_path, path) {
  ts_info <- get_file_info(hub_path, path)

  if (ts_info$type == 3L) {
    return(TRUE)
  }
  FALSE
}

get_file_info <- function(hub_path, path) {
  hub_path$GetFileInfo(path)[[1]]
}

# nolint start: object_name_linter
is_SubTreeFileSystem <- function(x) {
  inherits(x, "SubTreeFileSystem")
}
# nolint end
