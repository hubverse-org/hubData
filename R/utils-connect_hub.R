# Internal utilities used in connect_hub and connect_model_output functions ----
#' List all files in a hub
#'
#' This function returns a character vector of all file paths in a hub. It is
#' primarily intended to support downstream internal functions by providing
#' a complete list of files, particularly when working with cloud-based hubs
#' where minimizing repeated remote calls is beneficial.
#'
#' @param hub_path A path to the hub. Can be a character string (for local paths)
#'   or a file system object (e.g. of class `SubTreeFileSystem`) for cloud hubs.
#'
#' @return A character vector of file paths relative to the hub root.
#'
#' @keywords internal
#' @noRd
list_hub_files <- function(hub_path) {
  UseMethod("list_hub_files")
}
#' @export
list_hub_files.default <- function(hub_path) {
  checkmate::assert_directory_exists(hub_path)
  fs::dir_ls(
    hub_path,
    recurse = TRUE
  )
}
#' @export
list_hub_files.SubTreeFileSystem <- function(hub_path) {
  hub_path$ls(recursive = TRUE)
}

#' Resolve and validate file format from configuration or user input
#'
#' Determines the file format to use for reading model output data, either
#' by validating a user-supplied value or falling back to the value(s)
#' specified in the hub's administrative configuration (`admin.json`).
#'
#' If `file_format` is supplied, it must match one of the formats listed in
#' `config_admin[["file_format"]]`. Otherwise, the function returns the
#' configured format(s) directly. If no valid formats are found in the config
#' and no argument is provided, an error is raised.
#'
#' @param config_admin A named list containing hub configuration values, typically
#'   loaded from `admin.json`. Must contain a `file_format` entry.
#' @param file_format Optional file format to validate and use (e.g. `"csv"`, `"parquet"`).
#'   If not supplied, the function defaults to the format(s) listed in the config.
#' @param call The calling environment, used for error reporting. Defaults to [rlang::caller_env()].
#'
#' @return A single valid file format (if provided), or a character vector of valid formats
#'   from the configuration.
#'
#' @keywords internal
#' @noRd
get_file_format <- function(config_admin,
                            file_format = c("csv", "parquet", "arrow"),
                            call = rlang::caller_env()) {
  config_file_format <- config_admin[["file_format"]]

  if (!rlang::is_missing(file_format)) {
    file_format <- rlang::arg_match(file_format)

    if (!file_format %in% config_file_format) {
      cli::cli_abort(
        c(
          "x" = "{.arg file_format} value {.val {file_format}} is not a valid
                file format available for this hub.",
          "!" = "Must be {?/one of}: {.val {config_file_format}}."
        ),
        call = call
      )
    }

    return(file_format)
  }

  if (length(config_file_format) == 0L) {
    cli::cli_abort(
      c(
        "x" = "{.arg file_format} value could not be extracted from config
            file {.field admin.json}.",
        "!" = "Use argument {.arg file_format} to specify a file format
            or contact hub maintainers for assistance."
      ),
      call = call
    )
  }

  return(config_file_format)
}

#' Locate the model output directory within a hub
#'
#' Returns the full path to the model output directory as specified in the
#' hub's `config_admin`. This function supports both local and cloud-based hubs
#' through method dispatch.
#'
#' For local hubs (where `hub_path` is a character path), the function checks
#' the existence of the directory on the local filesystem. In this case, the
#' `hub_files` argument is optional and ignored.
#'
#' For cloud hubs (e.g. when `hub_path` is a `SubTreeFileSystem`), the `hub_files`
#' argument is **required** and must be a character vector listing all file paths
#' available in the hub. This is typically obtained from [list_hub_files()] and
#' helps avoid repeated and costly remote file system calls.
#'
#' @param hub_path A hub path, either as a local character path or a file system object
#'   such as a `SubTreeFileSystem`.
#' @param config_admin A named list of administrative configuration values, expected to
#'   optionally contain `model_output_dir`.
#' @param hub_files A character vector of file paths in the hub (as returned by
#'   [list_hub_files()]). This is **required for cloud-based hubs** to allow efficient
#'   existence checks, but is ignored for local hubs.
#' @param call The calling environment, used for error reporting.
#' Defaults to [rlang::caller_env()].
#'
#' @return The full path to the model output directory. For local hubs, this is a
#'   character string path. For cloud hubs, this is a file system object path.
#'
#' @keywords internal
#' @noRd
model_output_dir_path <- function(hub_path, config_admin, hub_files = NULL,
                                  call = rlang::caller_env()) {
  UseMethod("model_output_dir_path")
}

#' @export
model_output_dir_path.default <- function(hub_path, config_admin, hub_files = NULL,
                                          call = rlang::caller_env()) {
  model_output_dir <- ifelse(
    is.null(config_admin[["model_output_dir"]]),
    fs::path(hub_path, "model-output"),
    fs::path(hub_path, config_admin[["model_output_dir"]])
  )
  if (!dir.exists(model_output_dir)) {
    cli::cli_abort(
      "Directory {.path {basename(model_output_dir)}} does not exist in hub
      at path {.path { model_output_dir }}.",
      call = call
    )
  }
  model_output_dir
}

#' @export
model_output_dir_path.SubTreeFileSystem <- function(hub_path, config_admin, hub_files,
                                                    call = rlang::caller_env()) {
  if (is.null(config_admin[["model_output_dir"]])) {
    model_output_dir <- hub_path$path("model-output")
  } else {
    model_output_dir <- hub_path$path(config_admin[["model_output_dir"]])
  }

  if (!basename(model_output_dir$base_path) %in% hub_files) {
    cli::cli_abort(
      "Directory {.path {basename(model_output_dir$base_path)}} does not exist
      in S3 cloud hub {.path { hub_path$base_path }}.",
      call = call
    )
  }
  model_output_dir
}


#' Get metadata about opened vs existing model output files by file format
#'
#' Given a dataset and a list of model output files (typically from
#' [list_model_out_files()]), this function returns a two-row matrix indicating:
#'
#' - The number of files successfully opened per file format in the dataset
#' - The number of files of that format that exist in the model output directory
#'
#' This helps validate whether all expected files of each format were ingested.
#'
#' @param dataset An Arrow dataset object (e.g. from [arrow::open_dataset()]).
#' @param model_out_files Character vector of file paths in the model output directory
#'   (typically from [list_model_out_files()]).
#' @param file_format Character vector of expected file formats (e.g. `"csv"`, `"parquet"`).
#'
#' @return A matrix with file formats as columns and two rows:
#'   `n_open` and `n_in_dir`.
#'
#' @keywords internal
#' @noRd
get_file_format_meta <- function(dataset, model_out_files, file_format) {
  # Get number of files per file format successfully opened in dataset
  n_open <- lengths(list_dataset_files(dataset))
  if (is.null(names(n_open))) {
    return(NULL)
  }
  # to avoid confusion override renaming of arrow file format to ipc by arrow
  # package
  names(n_open)[names(n_open) == "ipc"] <- "arrow"

  # Ensure that entire file formats which should have been included aren't missing
  # from the dataset
  if (any(!file_format %in% names(n_open))) {
    n_open[setdiff(file_format, names(n_open))] <- 0
  }
  # Get number of files per file format that should be in the dataset that exist
  # in model out dir
  n_in_dir <- purrr::map_int(
    names(n_open),
    ~ file_format_n(model_out_files, .x)
  )

  rbind(n_open, n_in_dir)
}

#' Validate presence of expected file formats in model output files
#'
#' Checks whether any of the expected `file_format` values are present in
#' the provided model output files. If none are found, a warning or error
#' is raised depending on the `error` flag.
#'
#' This is useful for validating input before attempting to read datasets.
#'
#' @param model_out_files Character vector of file paths (typically from
#'   [list_model_out_files()]).
#' @param file_format Character vector of expected file formats.
#' @param skip_checks Logical. Ignored in current implementation (reserved for future use).
#' @param call Calling environment (for accurate error reporting).
#' @param error Logical. If `TRUE`, an error is raised when no matching formats are found;
#'   otherwise, a warning is issued.
#'
#' @return A character vector of valid file formats found in the model output directory.
#'
#' @keywords internal
#' @noRd
check_file_format <- function(model_out_files, file_format, skip_checks,
                              call = rlang::caller_env(), error = FALSE) {
  dir_file_formats <- get_dir_file_formats(model_out_files)
  valid_file_format <- file_format[file_format %in% dir_file_formats]

  if (length(valid_file_format) == 0L && error) {
    cli::cli_abort("No files of file format{?s}
                   {.val {file_format}}
                   found in model output directory.",
      call = call
    )
  }
  if (length(valid_file_format) == 0L) {
    cli::cli_warn("No files of file format{?s}
                   {.val {file_format}}
                   found in model output directory.",
      call = call
    )
  }
  valid_file_format
}

#' Count the number of files of a given format
#'
#' Counts how many files in the model output directory match a given file format.
#'
#' @param model_out_files Character vector of file paths (typically from
#'   [list_model_out_files()]).
#' @param file_format A string indicating the file extension (e.g. `"csv"`).
#'
#' @return An integer count of the number of matching files.
#'
#' @keywords internal
#' @noRd
file_format_n <- function(model_out_files, file_format) {
  checkmate::assert_string(file_format)
  subset_files_by_format(model_out_files, file_format) |> length()
}

#' Warn about unopened model output files
#'
#' Issues a warning if any expected model output files were not opened into the dataset.
#' It compares the number of opened files (`x`) against the number of files present
#' in the directory (`model_out_files`) for each file format.
#'
#' You may optionally specify `ignore_files` to exclude known missing files from the warning.
#'
#' @param x A matrix with rows `n_open` and `n_in_dir`, typically from [get_file_format_meta()].
#' @param dataset The Arrow dataset object opened from model output files.
#' @param model_out_files Character vector of file paths in the model output directory
#'   (typically from [list_model_out_files()]).
#' @param ignore_files Character vector of file name prefixes to ignore from the
#'   warning (optional).
#'
#' @return Invisibly returns `TRUE` if no unopened files remain (or all were ignored),
#'   otherwise `FALSE`.
#'
#' @keywords internal
#' @noRd
warn_unopened_files <- function(x, dataset, model_out_files,
                                ignore_files = NULL) {
  x <- as.data.frame(x)
  unopened_file_formats <- purrr::map_lgl(x, ~ .x[1] < .x[2])
  if (any(unopened_file_formats)) {
    dataset_files <- list_dataset_files(dataset)

    unopened_files <- purrr::map(
      purrr::set_names(names(x)[unopened_file_formats]),
      ~ subset_files_by_format(model_out_files, .x)
    ) %>%
      # check dir files against files opened in dataset
      purrr::imap(
        function(.x, .y) {
          .x[!normalizePath(.x) %in% normalizePath(dataset_files[[.y]])]
        }
      ) %>%
      purrr::list_simplify() %>%
      purrr::set_names("x")

    # Check whether missing files were explicitly ignored. If so, remove
    # them from the list of unopened files. If no files are left,
    # skip warning and return TRUE silently.
    if (!is.null(ignore_files)) {
      unopened_files <- purrr::discard(
        unopened_files,
        ~ any(startsWith(basename(.x), ignore_files))
      )
      if (length(unopened_files) == 0L) {
        return(invisible(TRUE))
      }
    }

    cli::cli_warn(
      c(
        "!" = "{cli::qty(length(unopened_files))} The following potentially
        invalid model output file{?s} not opened successfully.",
        sprintf("{.path %s}", unopened_files)
      )
    )
    invisible(FALSE)
  }
  invisible(TRUE)
}

#' List model output files in the hub
#'
#' Returns a character vector of files or directories located under a given
#' model output directory. Supports both local and cloud-based hubs.
#'
#' For local hubs (where `model_output_dir` is a character path), this function
#' directly queries the local filesystem. In this case, the `hub_files` argument
#' is optional and ignored.
#'
#' For cloud hubs (where `model_output_dir` is a `SubTreeFileSystem` path),
#' the `hub_files` argument is **required** and must contain a full list of
#' files and directories in the hub (typically from [list_hub_files()]). This
#' avoids repeated and potentially expensive remote file listing operations.
#'
#' @param model_output_dir The full path to the model output directory.
#'   For local hubs, a character path. For cloud hubs, a `SubTreeFileSystem` object.
#' @param hub_files A character vector of all file paths in the hub (e.g. from [list_hub_files()]).
#'   **Required for cloud hubs**, optional for local hubs (passed only for interface consistency).
#' @param file_format Optional string indicating the file extension (without dot)
#'   to filter for (e.g. `"csv"`, `"parquet"`). If `NULL`, all formats are returned.
#' @param type Type of filesystem entry to return. One of `"any"` (default),
#'   `"file"`, or `"directory"`.
#'
#' @return A character vector of file or directory paths under the model output directory.
#'
#' @keywords internal
#' @noRd
list_model_out_files <- function(model_output_dir, hub_files = NULL, file_format = NULL,
                                 type = "any") {
  checkmate::assert_string(file_format, null.ok = TRUE)
  UseMethod("list_model_out_files")
}


#' @export
# hub_files not required but passed for consistency with SubTreeFileSystem method
list_model_out_files.default <- function(model_output_dir, hub_files = NULL, file_format = NULL,
                                         type = c("any", "file", "directory")) {
  type <- rlang::arg_match(type)

  if (is.null(file_format)) {
    file_format <- "*"
  }
  fs::dir_ls(
    model_output_dir,
    recurse = TRUE,
    type = type,
    glob = paste0("*.", file_format)
  )
}

#' @export
list_model_out_files.SubTreeFileSystem <- function(model_output_dir, hub_files, file_format = NULL,
                                                   type = c("any", "file", "directory")) {
  type <- rlang::arg_match(type)

  model_out_files <- hub_files[startsWith(
    hub_files,
    model_output_dir$base_path
  )]

  is_dir <- fs::path_ext(model_out_files) == ""
  out_files <- switch(type,
    any = model_out_files,
    file = model_out_files[!is_dir],
    directory = model_out_files[is_dir]
  )

  if (is.null(file_format)) {
    return(out_files)
  }
  subset_files_by_format(out_files, file_format)
}

#' Subset model output files by file format
#'
#' Filters the provided model output file paths to include only those with
#' a matching file extension.
#'
#' @param model_out_files Character vector of file paths (typically from
#'   [list_model_out_files()]).
#' @param file_format A string indicating the file extension to filter for (e.g. `"csv"`).
#'
#' @return A character vector of file paths matching the given format.
#'
#' @keywords internal
#' @noRd
subset_files_by_format <- function(model_out_files, file_format) {
  model_out_files[fs::path_ext(model_out_files) == file_format]
}

#' List files in an Arrow dataset by file format
#'
#' Returns a named list mapping file format type to the files used in an
#' Arrow dataset. Supports both regular datasets and `UnionDataset` types.
#'
#' @param dataset An Arrow dataset object (e.g. from [arrow::open_dataset()]).
#'
#' @return A named list of character vectors. Each name corresponds to a file format
#'   (e.g. `"csv"`, `"parquet"`), and the values are vectors of file paths.
#'
#' @keywords internal
#' @noRd
list_dataset_files <- function(dataset) {
  UseMethod("list_dataset_files")
}

#' @export
list_dataset_files.default <- function(dataset) {
  stats::setNames(
    list(dataset$files),
    dataset$format$type
  )
}

#' @export
list_dataset_files.UnionDataset <- function(dataset) {
  stats::setNames(
    purrr::map(dataset$children, ~ .x$files),
    purrr::map_chr(dataset$children, ~ .x$format$type)
  )
}

#' Get file formats present in the model output directory
#'
#' Identifies the distinct file formats (by extension) present in a given set
#' of model output files, filtering only for formats currently supported
#' (CSV, Parquet, Arrow).
#'
#' @param model_out_files Character vector of file paths (typically from
#'   [list_model_out_files()]).
#'
#' @return A character vector of file format extensions present in the directory.
#'
#' @keywords internal
#' @noRd
get_dir_file_formats <- function(model_out_files) {
  all_ext <- model_out_files |>
    fs::path_ext() |>
    unique()

  intersect(all_ext, c("csv", "parquet", "arrow"))
}

#' List model output files with unsupported or unexpected formats
#'
#' Identifies files in the model output directory that do not match the
#' expected set of file formats.
#'
#' @param model_out_files Character vector of file paths (typically from
#'   [list_model_out_files()]).
#' @param file_format Character vector of accepted file extensions (default:
#'   `c("csv", "parquet", "arrow")`).
#'
#' @return A character vector of file names with unrecognized or invalid extensions.
#'
#' @keywords internal
#' @noRd
list_invalid_format_files <- function(model_out_files,
                                      file_format = c("csv", "parquet", "arrow")) {
  files <- fs::path_file(model_out_files)
  files[fs::path_ext(files) != file_format]
}
