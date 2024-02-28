# Internal utilities used in connect_hub and connect_model_output functions
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

model_output_dir_path <- function(hub_path, config_admin,
                                  call = rlang::caller_env()) {
  UseMethod("model_output_dir_path")
}
#' @export
model_output_dir_path.default <- function(hub_path, config_admin,
                                          call = rlang::caller_env()) {
  model_output_dir <- ifelse(
    is.null(config_admin[["model_output_dir"]]),
    fs::path(hub_path, "model-output"),
    fs::path(hub_path, config_admin[["model_output_dir"]])
  )
  if (!dir.exists(model_output_dir)) {
    cli::cli_abort(
      "Directory {.path {basename(model_output_dir)}} does not exist
      at path {.path { model_output_dir }}.",
      call = call
    )
  }
  model_output_dir
}

#' @export
model_output_dir_path.SubTreeFileSystem <- function(hub_path, config_admin,
                                                    call = rlang::caller_env()) {
  if (is.null(config_admin[["model_output_dir"]])) {
    model_output_dir <- hub_path$path("model-output")
  } else {
    model_output_dir <- hub_path$path(config_admin[["model_output_dir"]])
  }

  if (!basename(model_output_dir$base_path) %in% hub_path$ls()) {
    cli::cli_abort(
      "Directory {.path {basename(model_output_dir$base_path)}} does not exist
      at path {.path { model_output_dir$base_path }}.",
      call = call
    )
  }
  model_output_dir
}

get_file_format_meta <- function(dataset, model_output_dir, file_format) {
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
    ~ file_format_n(model_output_dir, .x)
  )

  rbind(n_open, n_in_dir)
}

check_file_format <- function(model_output_dir, file_format,
                              call = rlang::caller_env(), error = FALSE) {
  dir_file_formats <- get_dir_file_formats(model_output_dir)
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

file_format_n <- function(model_output_dir, file_format) {
  checkmate::assert_string(file_format)
  UseMethod("file_format_n")
}

#' @export
file_format_n.default <- function(model_output_dir, file_format) {
  length(
    fs::dir_ls(
      model_output_dir,
      recurse = TRUE,
      glob = paste0("*.", file_format)
    )
  )
}

#' @export
file_format_n.SubTreeFileSystem <- function(model_output_dir, file_format) {
  sum(fs::path_ext(model_output_dir$ls(recursive = TRUE)) == file_format)
}


warn_unopened_files <- function(x, dataset, model_output_dir) {
  x <- as.data.frame(x)
  unopened_file_formats <- purrr::map_lgl(x, ~ .x[1] < .x[2])
  if (any(unopened_file_formats)) {
    dataset_files <- list_dataset_files(dataset)

    unopened_files <- purrr::map(
      purrr::set_names(names(x)[unopened_file_formats]),
      ~ list_dir_files(model_output_dir, file_format)
    ) %>%
      # check dir files against files opened in dataset
      purrr::imap(
        function(.x, .y) {
          .x[!.x %in% dataset_files[[.y]]]
        }
      ) %>%
      purrr::list_simplify() %>%
      purrr::set_names("x")

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


list_dir_files <- function(model_output_dir, file_format = NULL) {
  checkmate::assert_string(file_format, null.ok = TRUE)
  UseMethod("list_dir_files")
}


#' @export
list_dir_files.default <- function(model_output_dir, file_format = NULL) {
  if (is.null(file_format)) {
    file_format <- "*"
  }
  fs::dir_ls(
    model_output_dir,
    recurse = TRUE,
    glob = paste0("*.", file_format)
  )
}

#' @export
list_dir_files.SubTreeFileSystem <- function(model_output_dir, file_format = NULL) {
  all_files <- model_output_dir$ls(recursive = TRUE)
  if (is.null(file_format)) {
    return(all_files)
  }
  all_files[fs::path_ext(all_files) == file_format]
}

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

get_dir_file_formats <- function(model_output_dir) {
  all_ext <- list_dir_files(model_output_dir) %>%
    fs::path_ext() %>%
    unique()

  intersect(all_ext, c("csv", "parquet", "arrow"))
}
