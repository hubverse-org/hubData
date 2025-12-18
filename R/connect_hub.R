#' Connect to model output data.
#'
#' Connect to data in a model output directory through a Modeling Hub or directly.
#' Data can be stored in a local directory or in the cloud on AWS or GCS.
#' @param hub_path Either a character string path to a local Modeling Hub directory
#' or an object of class `<SubTreeFileSystem>` created using functions [s3_bucket()]
#' or [gs_bucket()] by providing a string S3 or GCS bucket name or path to a
#' Modeling Hub directory stored in the cloud.
#' For more details consult the
#' [Using cloud storage (S3, GCS)](https://arrow.apache.org/docs/r/articles/fs.html)
#' in the `arrow` package.
#' The hub must be fully configured with valid `admin.json` and `tasks.json`
#' files within the `hub-config` directory.
#' @param model_output_dir Either a character string path to a local directory
#' containing model output data
#' or an object of class `<SubTreeFileSystem>` created using functions [s3_bucket()]
#' or [gs_bucket()] by providing a string S3 or GCS bucket name or path to a
#' directory containing model output data stored in the cloud.
#' For more details consult the
#' [Using cloud storage (S3, GCS)](https://arrow.apache.org/docs/r/articles/fs.html)
#' in the `arrow` package.
#' @param file_format The file format model output files are stored in.
#' For connection to a fully configured hub, accessed through `hub_path`,
#' `file_format` is inferred from the hub's `file_format` configuration in
#' `admin.json` and is ignored by default.
#' If supplied, it will override hub configuration setting. Multiple formats can
#' be supplied to `connect_hub` but only a single file format can be supplied to
#' `connect_model_output`.
#' @param skip_checks Logical. If `TRUE` (default), skip validation checks when
#' opening hub datasets, providing optimal performance especially for large cloud
#' hubs (AWS S3, GCS) by minimizing I/O operations. However, this will result in
#' an error if the model output directory contains files that cannot be opened as
#' part of the dataset.
#' Setting to `FALSE` will attempt to open and exclude any invalid files that
#' cannot be read as part of the dataset. This results in slower performance due to
#' increased I/O operations but provides more robustness when working with directories
#' that may contain invalid files.
#' Note that hubs validated through the hubValidations package should not require
#' these additional checks. If invalid (non-model output) files are present in the
#' model output directory, use the `ignore_files` argument to exclude them.
#' @param na A character vector of strings to interpret as missing values. Only
#' applies to CSV files. The default is `c("NA", "")`. Useful when actual character
#' string `"NA"` values are used in the data. In such a case, use empty cells to
#' indicate missing values in your files and set `na = ""`.
#' @param ignore_files A character vector of file **names** (not paths) or
#'  file **prefixes** to ignore when discovering model output files to
#'  include in dataset connections.
#'  Parent directory names should not be included.
#'  Common non-data files such as `"README"` and `".DS_Store"` are ignored automatically,
#'  but additional files can be excluded by specifying them here.
#' @inheritParams create_hub_schema
#' @details
#' By default, common non-data files that may be present in model output directories
#' (e.g. `"README"`, `".DS_Store"`) are excluded automatically to prevent errors
#' when connecting via Arrow. Additional files can be excluded using the `ignore_files`
#' parameter.
#' @return
#' - `connect_hub` returns an S3 object of class `<hub_connection>`.
#' - `connect_model_output` returns an S3 object of class `<mod_out_connection>`.
#'
#' Both objects are connected to the data in the model-output directory via an
#' Apache arrow `FileSystemDataset` connection.
#' The connection can be used to extract data using `dplyr` custom queries. The
#' `<hub_connection>` class also contains modeling hub metadata.
#' @export
#' @describeIn connect_hub connect to a fully configured Modeling Hub directory.
#' @examples
#' # Connect to a local simple forecasting Hub.
#' hub_path <- system.file("testhubs/simple", package = "hubUtils")
#' hub_con <- connect_hub(hub_path)
#' hub_con
#' hub_con <- connect_hub(hub_path, output_type_id_datatype = "character")
#' hub_con
#' # Connect directly to a local `model-output` directory
#' mod_out_path <- system.file("testhubs/simple/model-output", package = "hubUtils")
#' mod_out_con <- connect_model_output(mod_out_path)
#' mod_out_con
#' # Query hub_connection for data
#' library(dplyr)
#' hub_con %>%
#'   filter(
#'     origin_date == "2022-10-08",
#'     horizon == 2
#'   ) %>%
#'   collect_hub()
#' mod_out_con %>%
#'   filter(
#'     origin_date == "2022-10-08",
#'     horizon == 2
#'   ) %>%
#'   collect_hub()
#' # Ignore a file
#' connect_hub(hub_path, ignore_files = c("README", "2022-10-08-team1-goodmodel.csv"))
#' # Connect to a simple forecasting Hub stored in an AWS S3 bucket.
#' \dontrun{
#' hub_path <- s3_bucket("hubverse/hubutils/testhubs/simple/")
#' hub_con <- connect_hub(hub_path)
#' hub_con
#' }
connect_hub <- function(
  hub_path,
  file_format = c("csv", "parquet", "arrow"),
  output_type_id_datatype = c(
    "from_config",
    "auto",
    "character",
    "double",
    "integer",
    "logical",
    "Date"
  ),
  partitions = list(model_id = arrow::utf8()),
  skip_checks = TRUE,
  na = c("NA", ""),
  ignore_files = NULL
) {
  UseMethod("connect_hub")
}


#' @export
connect_hub.default <- function(
  hub_path,
  file_format = c("csv", "parquet", "arrow"),
  output_type_id_datatype = c(
    "from_config",
    "auto",
    "character",
    "double",
    "integer",
    "logical",
    "Date"
  ),
  partitions = list(model_id = arrow::utf8()),
  skip_checks = TRUE,
  na = c("NA", ""),
  ignore_files = NULL
) {
  rlang::check_required(hub_path)
  output_type_id_datatype <- rlang::arg_match(output_type_id_datatype)

  # Ignore common non-data files that may be present in model output directories:
  # - "README" is typically a text/markdown file.
  # - ".DS_Store" is a macOS system file.
  # These are not valid Arrow data files and can cause read errors if not excluded.
  ignore_files <- unique(c(ignore_files, "README", ".DS_Store"))

  if (!dir.exists(hub_path)) {
    cli::cli_abort(c("x" = "Directory {.path {hub_path}} does not exist."))
  }
  if (!dir.exists(fs::path(hub_path, "hub-config"))) {
    cli::cli_abort(c(
      "x" = "{.path hub-config} directory not found in root of Hub."
    ))
  }

  config_admin <- hubUtils::read_config(hub_path, "admin")
  config_tasks <- hubUtils::read_config(hub_path, "tasks")

  model_output_dir <- model_output_dir_path(hub_path, config_admin)

  if (missing(file_format)) {
    file_format <- rlang::missing_arg()
    file_format <- get_file_format(config_admin, file_format)
  } else {
    file_format <- rlang::arg_match(file_format, multiple = TRUE)
  }
  hub_name <- config_admin$name

  # Only include files. Ignoring directories prevents unintentionally excluding
  # all files within them
  model_out_files <- list_model_out_files(model_output_dir, type = "file")
  file_format <- check_file_format(model_out_files, file_format, skip_checks)

  # Based on skip_checks param, set a flag that determines whether or not to
  # check for invalid files when opening model output data.
  if (isTRUE(skip_checks)) {
    exclude_invalid_files <- FALSE
  } else {
    exclude_invalid_files <- TRUE
  }

  if (length(file_format) == 0L) {
    dataset <- list()
  } else {
    dataset <- open_hub_datasets(
      model_output_dir = model_output_dir,
      model_out_files = model_out_files,
      file_format = file_format,
      config_tasks = config_tasks,
      output_type_id_datatype = output_type_id_datatype,
      partitions = partitions,
      exclude_invalid_files = exclude_invalid_files,
      na = na,
      ignore_files = ignore_files
    )
  }
  if (inherits(dataset, "UnionDataset")) {
    file_system <- purrr::map_chr(
      dataset$children,
      ~ class(.x$filesystem)[1]
    ) %>%
      unique()
  } else {
    file_system <- class(dataset$filesystem)[1]
    if (file_system == "NULL") file_system <- "local"
  }
  file_format <- get_file_format_meta(dataset, model_out_files, file_format)
  # warn of any discrepancies between expected files in dir and successfully opened
  # files in dataset
  warn_unopened_files(file_format, dataset, model_out_files, ignore_files)

  structure(
    dataset,
    class = c("hub_connection", class(dataset)),
    hub_name = hub_name,
    file_format = file_format,
    checks = exclude_invalid_files,
    file_system = file_system,
    hub_path = hub_path,
    model_output_dir = model_output_dir,
    config_admin = config_admin,
    config_tasks = config_tasks
  )
}

#' @export
connect_hub.SubTreeFileSystem <- function(
  hub_path,
  file_format = c("csv", "parquet", "arrow"),
  output_type_id_datatype = c(
    "from_config",
    "auto",
    "character",
    "double",
    "integer",
    "logical",
    "Date"
  ),
  partitions = list(model_id = arrow::utf8()),
  skip_checks = TRUE,
  na = c("NA", ""),
  ignore_files = NULL
) {
  rlang::check_required(hub_path)
  output_type_id_datatype <- rlang::arg_match(output_type_id_datatype)

  # Ignore common non-data files that may be present in model output directories:
  # - "README" is typically a text/markdown file.
  # - ".DS_Store" is a macOS system file.
  # These are not valid Arrow data files and can cause read errors if not excluded.
  ignore_files <- unique(c(ignore_files, "README", ".DS_Store"))

  hub_files <- list_hub_files(hub_path)

  if (!"hub-config" %in% hub_files) {
    cli::cli_abort(
      "{.path hub-config} not a directory in bucket
                       {.path {hub_path$base_path}}"
    )
  }

  config_admin <- hubUtils::read_config(hub_path, "admin")
  config_tasks <- hubUtils::read_config(hub_path, "tasks")

  model_output_dir <- model_output_dir_path(hub_path, config_admin, hub_files)

  if (missing(file_format)) {
    file_format <- rlang::missing_arg()
    file_format <- get_file_format(config_admin, file_format)
  } else {
    file_format <- rlang::arg_match(file_format, multiple = TRUE)
  }
  hub_name <- config_admin$name

  # Only include files. Ignoring directories prevents unintentionally excluding
  # all files within them
  model_out_files <- list_model_out_files(
    model_output_dir,
    hub_files,
    type = "file"
  )
  file_format <- check_file_format(model_out_files, file_format, skip_checks)

  # Based on skip_checks param, set a flag that determines whether or not to
  # check for invalid files when opening model output data.
  if (isTRUE(skip_checks)) {
    exclude_invalid_files <- FALSE
  } else {
    exclude_invalid_files <- TRUE
  }

  if (length(file_format) == 0L) {
    dataset <- list()
  } else {
    dataset <- open_hub_datasets(
      model_output_dir = model_output_dir,
      model_out_files = model_out_files,
      file_format = file_format,
      config_tasks = config_tasks,
      output_type_id_datatype = output_type_id_datatype,
      partitions = partitions,
      exclude_invalid_files = exclude_invalid_files,
      na = na,
      ignore_files = ignore_files
    )
  }

  if (inherits(dataset, "UnionDataset")) {
    file_system <- purrr::map_chr(
      dataset$children,
      ~ class(.x$filesystem$base_fs)[1]
    ) %>%
      unique()
  } else {
    file_system <- class(dataset$filesystem$base_fs)[1]
    if (file_system == "NULL") file_system <- hub_path$url_scheme
  }
  file_format <- get_file_format_meta(dataset, model_out_files, file_format)
  # warn of any discrepancies between expected files in dir and successfully opened
  # files in dataset
  warn_unopened_files(file_format, dataset, model_out_files, ignore_files)

  structure(
    dataset,
    class = c("hub_connection", class(dataset)),
    hub_name = hub_name,
    file_format = file_format,
    checks = exclude_invalid_files,
    file_system = file_system,
    hub_path = hub_path$base_path,
    model_output_dir = model_output_dir$base_path,
    config_admin = config_admin,
    config_tasks = config_tasks
  )
}

open_hub_dataset <- function(
  model_output_dir,
  model_out_files,
  file_format = c("csv", "parquet", "arrow"),
  config_tasks,
  output_type_id_datatype = c(
    "from_config",
    "auto",
    "character",
    "double",
    "integer",
    "logical",
    "Date"
  ),
  partitions = list(model_id = arrow::utf8()),
  exclude_invalid_files,
  na = c("NA", ""),
  ignore_files = c("README", ".DS_Store")
) {
  file_format <- rlang::arg_match(file_format)
  schema <- create_hub_schema(
    config_tasks,
    partitions = partitions,
    output_type_id_datatype = output_type_id_datatype
  )

  # Ignoring files that do not have the right file_format extension makes
  # opening datasets faster, even when skip_checks = FALSE.
  ignore_files <- c(
    ignore_files,
    list_invalid_format_files(
      model_out_files,
      file_format
    )
  )

  switch(
    file_format,
    csv = arrow::open_dataset(
      model_output_dir,
      format = "csv",
      partitioning = "model_id",
      col_types = schema,
      unify_schemas = FALSE,
      strings_can_be_null = TRUE,
      factory_options = list(
        exclude_invalid_files = exclude_invalid_files,
        selector_ignore_prefixes = ignore_files
      ),
      na = na
    ),
    parquet = arrow::open_dataset(
      model_output_dir,
      format = "parquet",
      partitioning = "model_id",
      schema = schema,
      unify_schemas = FALSE,
      factory_options = list(
        exclude_invalid_files = exclude_invalid_files,
        selector_ignore_prefixes = ignore_files
      )
    ),
    arrow = arrow::open_dataset(
      model_output_dir,
      format = "arrow",
      partitioning = "model_id",
      schema = schema,
      unify_schemas = FALSE,
      factory_options = list(
        exclude_invalid_files = exclude_invalid_files,
        selector_ignore_prefixes = ignore_files
      )
    )
  )
}

open_hub_datasets <- function(
  model_output_dir,
  model_out_files,
  file_format = c("csv", "parquet", "arrow"),
  config_tasks,
  output_type_id_datatype = c(
    "from_config",
    "auto",
    "character",
    "double",
    "integer",
    "logical",
    "Date"
  ),
  partitions = list(model_id = arrow::utf8()),
  exclude_invalid_files,
  na = c("NA", ""),
  ignore_files = c("README", ".DS_Store"),
  call = rlang::caller_env()
) {
  if (length(file_format) == 1L) {
    open_hub_dataset(
      model_output_dir = model_output_dir,
      model_out_files = model_out_files,
      file_format = file_format,
      config_tasks = config_tasks,
      output_type_id_datatype,
      partitions = partitions,
      exclude_invalid_files,
      na = na,
      ignore_files = ignore_files
    )
  } else {
    cons <- purrr::map(
      file_format,
      ~ open_hub_dataset(
        model_output_dir = model_output_dir,
        model_out_files = model_out_files,
        file_format = .x,
        config_tasks = config_tasks,
        output_type_id_datatype = output_type_id_datatype,
        partitions = partitions,
        exclude_invalid_files,
        na = na,
        ignore_files = ignore_files
      )
    )

    arrow::open_dataset(cons)
  }
}
