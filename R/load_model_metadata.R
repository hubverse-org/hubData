#' Compile hub model metadata
#'
#' Loads in hub model metadata for all models or a specified subset of models
#' and compiles it into a tibble with one row per model.
#' @param hub_path Either a character string path to a local Modeling Hub directory
#' or an object of class `<SubTreeFileSystem>` created using functions [s3_bucket()]
#' or [gs_bucket()] by providing a string S3 or GCS bucket name or path to a
#' Modeling Hub directory stored in the cloud.
#' For more details consult the
#' [Using cloud storage (S3, GCS)](https://arrow.apache.org/docs/r/articles/fs.html)
#' in the `arrow` package.
#' @param model_ids A vector of character strings of models for which to load
#'   metadata. Defaults to NULL, in which case metadata for all models is loaded.
#'
#' @return `tibble` with model metadata. One row for each model, one column for
#' each top-level field in the metadata file. For metadata files with nested structures,
#' this tibble may contain list-columns where the entries are lists containing the nested metadata values.
#' @export
#'
#' @examples
#' # Load in model metadata from local hub
#' hub_path <- system.file("testhubs/simple", package = "hubUtils")
#' load_model_metadata(hub_path)
#' load_model_metadata(hub_path, model_ids = c("hub-baseline"))
load_model_metadata <- function(hub_path, model_ids = NULL) {
  UseMethod("load_model_metadata")
}

# cyclomatic complexity of 17 instead of 15 acceptable
#' @export
load_model_metadata.default <- function(hub_path, model_ids = NULL) { # nolint: cyclocomp_linter
  if (!dir.exists(hub_path)) {
    cli::cli_abort(c("x" = "{.path {hub_path}} directory does not exist."))
  }
  if (!dir.exists(fs::path(hub_path, "model-metadata"))) {
    cli::cli_abort(c("x" = "{.path model-metadata} directory not found in root of Hub."))
  }

  metadata_paths <- fs::dir_ls(fs::path(hub_path, "model-metadata"),
    glob = "*.y*ml"
  )
  if (!is.null(model_ids)) {
    metadata_ids <- basename(metadata_paths) %>% fs::path_ext_remove()
    if (any(!model_ids %in% metadata_ids)) {
      cli::cli_abort(
        "{.var model_ids} value{?s} {.val {model_ids[!model_ids %in% metadata_ids]}}
      not valid model IDs."
      )
    }
    metadata_paths <- metadata_paths[metadata_ids %in% model_ids]
  }
  if (length(metadata_paths) == 0) {
    cli::cli_abort(c("x" = "{.path model-metadata} directory is empty."))
  }

  meta_l <- purrr::map(
    metadata_paths,
    ~ yaml::read_yaml(.x) %>%
      # Here we add depth to list elements so when the top level is unlisted at
      # the `bind_rows` step below, they do not create a row per list element.
      # Instead the expected single row per model is created.
      purrr::map_if(
        ~ purrr::pluck_depth(.x) > 1L,
        ~ list(.x)
      )
  )

  # Here we are using dplyr's bind_rows because, in contrast to rbind, it ensures
  # row's are bound using shared names and adds NAs where fields are missing by
  # default. We use do.call for compiling data for more than 1 file.
  meta_tbl <- try(
    {
      if (length(meta_l) == 1L) {
        dplyr::bind_rows(meta_l)
      } else {
        do.call(dplyr::bind_rows, meta_l)
      }
    },
    silent = TRUE
  )
  if (inherits(meta_tbl, "try-error")) {
    cli::cli_abort(
      "Could not compile metadata files. Please ensure all hub metadata files are valid."
    )
  }

  meta_names <- names(meta_tbl)
  if (!"model_id" %in% meta_names && all(c("team_abbr", "model_abbr") %in% meta_names)) {
    meta_tbl[["model_id"]] <- paste(meta_tbl[["team_abbr"]],
      meta_tbl[["model_abbr"]],
      sep = "-"
    )
  }
  if (!"team_abbr" %in% meta_names && "model_id" %in% meta_names) {
    meta_tbl[["team_abbr"]] <- gsub("-.*$", "", meta_tbl[["model_id"]])
  }
  if (!"model_abbr" %in% meta_names && "model_id" %in% meta_names) {
    meta_tbl[["model_abbr"]] <- gsub("^.*-", "", meta_tbl[["model_id"]])
  }

  meta_tbl <- arrange_meta_tbl(meta_tbl, hub_path)
  meta_tbl
}

arrange_meta_tbl <- function(meta_tbl, hub_path) {
  schema_names <- hubUtils::read_config(
    hub_path,
    config = "model-metadata-schema"
  ) %>%
    purrr::pluck("properties") %>%
    names()

  meta_names <- names(meta_tbl)
  all_names <- union(schema_names, meta_names)

  # Add columns of missing schema properties
  missing_cols <- setdiff(all_names, meta_names)
  meta_tbl[, missing_cols] <- NA

  meta_names_ordered <- c(
    intersect(c("model_id", "team_abbr", "model_abbr"), all_names),
    setdiff(all_names, c("model_id", "team_abbr", "model_abbr"))
  )
  meta_tbl[meta_names_ordered]
}
