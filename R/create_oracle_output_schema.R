#' Create oracle-output target data file schema
#'
#' @inheritParams connect_hub
#' @inheritParams create_hub_schema
#' @inheritParams create_timeseries_schema
#'
#' @details
#' When `target-data.json` (v6.0.0+) is present, schema is created directly from config
#' without reading target data files. Otherwise, schema is inferred by reading the dataset.
#' Config-based approach avoids file I/O (especially beneficial for cloud storage) and
#' provides deterministic schema creation.
#'
#' @return an arrow `<schema>` class object
#' @export
#' @importFrom rlang !!!
#' @importFrom hubUtils read_config has_target_data_config
#' @examples
#' hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
#' # Create target oracle-output schema
#' create_oracle_output_schema(hub_path)
#' #  target oracle-output schema from a cloud hub
#' s3_hub_path <- s3_bucket("example-complex-forecast-hub")
#' create_oracle_output_schema(s3_hub_path)
create_oracle_output_schema <- function(
  hub_path,
  date_col = NULL,
  na = c("NA", ""),
  ignore_files = NULL,
  r_schema = FALSE,
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

  # Detect if target-data.json exists
  use_config <- hubUtils::has_target_data_config(hub_path)

  if (use_config) {
    # Use config-based deterministic schema creation
    config_target_data <- hubUtils::read_config(hub_path, "target-data")
    create_oracle_output_schema_from_config(
      hub_path = hub_path,
      config_target_data = config_target_data,
      r_schema = r_schema,
      output_type_id_datatype = output_type_id_datatype
    )
  } else {
    # Use existing inference-based schema creation
    create_oracle_output_schema_from_inference(
      hub_path = hub_path,
      date_col = date_col,
      na = na,
      ignore_files = ignore_files,
      r_schema = r_schema,
      output_type_id_datatype = output_type_id_datatype
    )
  }
}

# Internal helper: Config-based schema creation
#' @noRd
# nolint start: object_length_linter
create_oracle_output_schema_from_config <- function(
  # nolint end
  hub_path,
  config_target_data,
  r_schema = FALSE,
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
  # Use hubUtils getters to extract config properties
  config_date_col <- hubUtils::get_date_col(config_target_data)
  observable_unit <- hubUtils::get_observable_unit(
    config_target_data,
    dataset = "oracle-output"
  )
  versioned <- hubUtils::get_versioned(
    config_target_data,
    dataset = "oracle-output"
  )
  has_output_type_ids <- hubUtils::get_has_output_type_ids(config_target_data)

  # Get task IDs from tasks config
  config_tasks <- hubUtils::read_config(hub_path, "tasks")

  # 1. Build hub schema with output_type_id datatype handling
  hub_schema <- create_hub_schema(
    config_tasks,
    output_type_id_datatype = output_type_id_datatype
  )

  # 2. Start with subset for task ID columns
  oo_schema <- hub_schema[hub_schema$names %in% observable_unit]

  # 3. Assign date column (Date type)
  oo_schema[[config_date_col]] <- arrow::date32()

  # 4. Add output_type and output_type_id if present
  if (has_output_type_ids) {
    oo_schema[["output_type"]] <- hub_schema[["output_type"]]$type
    oo_schema[["output_type_id"]] <- hub_schema[["output_type_id"]]$type
  }

  # 5. Add oracle_value column (from hub_schema's value type)
  oo_schema[["oracle_value"]] <- hub_schema[["value"]]$type

  # 6. Add as_of column if versioned
  if (versioned) {
    oo_schema[["as_of"]] <- arrow::date32()
  }

  # 7. Reorder columns to match expected order
  expected_colnames <- get_target_data_colnames(
    config_target_data,
    target_type = "oracle-output"
  )
  oo_schema <- oo_schema[expected_colnames]

  if (r_schema) {
    oo_schema <- as_r_schema(oo_schema)
  }
  oo_schema
}

# Internal helper: Inference-based schema creation (existing logic)
#' @noRd
# nolint start: object_length_linter
create_oracle_output_schema_from_inference <- function(
  # nolint end
  hub_path,
  date_col = NULL,
  na = c("NA", ""),
  ignore_files = NULL,
  r_schema = FALSE,
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
  ignore_files <- unique(c(ignore_files, "README", ".DS_Store"))
  oo_path <- validate_target_data_path(hub_path, "oracle-output")

  config_tasks <- read_config(hub_path)
  hub_schema <- create_hub_schema(
    config_tasks,
    output_type_id_datatype = output_type_id_datatype
  )

  oo_ext <- validate_target_file_ext(oo_path, hub_path)
  if (inherits(hub_path, "SubTreeFileSystem")) {
    oo_path <- file_system_path(hub_path, oo_path, uri = TRUE)
  }

  partition_schema <- get_partition_schema(
    hub_path,
    oo_path,
    target_type = "oracle-output",
    hub_schema = hub_schema
  )

  # Although technically this is not required for validating
  # oracle output schema as all column data-types can be determined
  # from the config, we include the step of accessing the schema
  #  of the dataset itself for two reasons:
  #  1. although the config is the source of truth, this ensures
  #   opening data that for some reason has an added column doesn't
  #   fail. Catching this is the job of validation not schema
  #    creation.
  # 2. It allows us to subset for and order the schema to match the
  # columns and order of the columns in the dataset itself.
  file_schema <- get_target_schema(
    oo_path,
    ext = oo_ext,
    na = na,
    ignore_files = ignore_files,
    partition_schema = partition_schema
  )

  oo_schema <- hub_schema[hub_schema$names %in% file_schema$names]
  oo_schema[["oracle_value"]] <- hub_schema[["value"]]$type

  missing <- setdiff(file_schema$names, oo_schema$names)
  oo_schema <- arrow::schema(
    !!!c(oo_schema$fields, file_schema[missing]$fields)
  )

  if (!is.null(date_col)) {
    checkmate::assert_character(date_col, len = 1L)
    if (!date_col %in% oo_schema$names) {
      cli::cli_abort(
        c(
          "x" = "Column {.arg {date_col}} not found in {.path {basename(oo_path)}} file(s).",
          "i" = "Column must be present in the file or partition to be used as the date column."
        )
      )
    }
    oo_schema[[date_col]] <- arrow::date32()
  }

  has_date_col <- any(
    purrr::map_lgl(
      oo_schema$fields,
      ~ .x$type == arrow::date32()
    )
  )
  if (!has_date_col) {
    cli::cli_warn(
      c(
        "!" = "No {.cls date} type column found in {.path {basename(oo_path)}}.",
        "i" = "A {.cls date} column that represents the date observations actually
        occurred is required for target data to be useful."
      )
    )
  }
  oo_schema <- oo_schema[file_schema$names]

  if (r_schema) {
    oo_schema <- as_r_schema(oo_schema)
  }
  oo_schema
}
