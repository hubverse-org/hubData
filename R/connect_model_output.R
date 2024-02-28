#' @export
#' @param schema An [arrow::Schema] object for the Dataset.
#' If NULL (the default), the schema will be inferred from the data sources.
#' @param partition_names character vector that defines the field names to which
#' recursive directory names correspond to. Defaults to a single `model_id` field
#' which reflects the standard expected structure of a `model-output` directory.
#' @describeIn connect_hub connect directly to a `model-output` directory. This
#' function can be used to access data directly from an appropriately set up
#' model output directory which is not part of a fully configured hub.
connect_model_output <- function(model_output_dir,
                                 file_format = c("csv", "parquet", "arrow"),
                                 partition_names = "model_id",
                                 schema = NULL) {
  UseMethod("connect_model_output")
}

#' @export
connect_model_output.default <- function(model_output_dir,
                                         file_format = c("csv", "parquet", "arrow"),
                                         partition_names = "model_id",
                                         schema = NULL) {
  rlang::check_required(model_output_dir)
  if (!dir.exists(model_output_dir)) {
    cli::cli_abort(c("x" = "Directory {.path {model_output_dir}} does not exist."))
  }
  file_format <- rlang::arg_match(file_format)
  # Only keep file formats of which files actually exist in model_output_dir.
  file_format <- check_file_format(model_output_dir, file_format, error = TRUE)

  if (file_format == "csv") {
    dataset <- arrow::open_dataset(
      model_output_dir,
      format = file_format,
      partitioning = partition_names,
      col_types = schema,
      unify_schemas = TRUE,
      strings_can_be_null = TRUE,
      factory_options = list(exclude_invalid_files = TRUE)
    )
  } else {
    dataset <- arrow::open_dataset(
      model_output_dir,
      format = file_format,
      partitioning = partition_names,
      schema = schema,
      unify_schemas = TRUE,
      factory_options = list(exclude_invalid_files = TRUE)
    )
  }

  file_format <- get_file_format_meta(dataset, model_output_dir, file_format)
  # warn of any discrepancies between expected files in dir and successfully opened
  # files in dataset
  warn_unopened_files(file_format, dataset, model_output_dir)
  structure(dataset,
    class = c("mod_out_connection", class(dataset)),
    file_format = file_format,
    file_system = class(dataset$filesystem)[1],
    model_output_dir = model_output_dir
  )
}

#' @export
connect_model_output.SubTreeFileSystem <- function(model_output_dir,
                                                   file_format = c("csv", "parquet", "arrow"),
                                                   partition_names = "model_id",
                                                   schema = NULL) {
  rlang::check_required(model_output_dir)
  file_format <- rlang::arg_match(file_format)
  # Only keep file formats of which files actually exist in model_output_dir.
  file_format <- check_file_format(model_output_dir, file_format, error = TRUE)

  if (file_format == "csv") {
    dataset <- arrow::open_dataset(
      model_output_dir,
      format = file_format,
      partitioning = partition_names,
      schema = schema,
      unify_schemas = TRUE,
      strings_can_be_null = TRUE,
      factory_options = list(exclude_invalid_files = TRUE)
    )
  } else {
    dataset <- arrow::open_dataset(
      model_output_dir,
      format = file_format,
      partitioning = partition_names,
      schema = schema,
      unify_schemas = TRUE,
      factory_options = list(exclude_invalid_files = TRUE)
    )
  }

  file_format <- get_file_format_meta(dataset, model_output_dir, file_format)
  # warn of any discrepancies between expected files in dir and successfully opened
  # files in dataset
  warn_unopened_files(file_format, dataset, model_output_dir)

  structure(dataset,
    class = c("mod_out_connection", class(dataset)),
    file_format = file_format,
    file_system = class(dataset$filesystem$base_fs)[1],
    model_output_dir = model_output_dir$base_path
  )
}
