#' Create time-series target data file schema
#'
#' @inheritParams connect_hub
#' @inheritParams create_hub_schema
#' @param date_col Optional column name to be interpreted as date. Default is `NULL`.
#' Useful when the required date column is a partitioning column in the target data
#' and does not have the same name as a date typed task ID variable in the config.
#' **Note**: Ignored when `target-data.json` exists (v6+); date column is read from config.
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
#' # Create target time-series schema
#' create_timeseries_schema(hub_path)
#' #  target time-series schema from a cloud hub
#' s3_hub_path <- s3_bucket("example-complex-forecast-hub")
#' create_timeseries_schema(s3_hub_path)
create_timeseries_schema <- function(
  hub_path,
  date_col = NULL,
  na = c("NA", ""),
  ignore_files = NULL,
  r_schema = FALSE
) {
  # Detect if target-data.json exists
  use_config <- hubUtils::has_target_data_config(hub_path)

  if (use_config) {
    # Use config-based deterministic schema creation
    config_target_data <- hubUtils::read_config(hub_path, "target-data")
    create_timeseries_schema_from_config(
      hub_path = hub_path,
      config_target_data = config_target_data,
      r_schema = r_schema
    )
  } else {
    # Use existing inference-based schema creation
    create_timeseries_schema_from_inference(
      hub_path = hub_path,
      date_col = date_col,
      na = na,
      ignore_files = ignore_files,
      r_schema = r_schema
    )
  }
}

# Internal helper: Config-based schema creation
#' @noRd
# nolint start: object_length_linter
create_timeseries_schema_from_config <- function(
  # nolint end
  hub_path,
  config_target_data,
  r_schema = FALSE
) {
  # Use hubUtils getters to extract config properties
  config_date_col <- hubUtils::get_date_col(config_target_data)
  observable_unit <- hubUtils::get_observable_unit(
    config_target_data,
    dataset = "time-series"
  )
  versioned <- hubUtils::get_versioned(
    config_target_data,
    dataset = "time-series"
  )
  non_task_id_schema <- hubUtils::get_non_task_id_schema(config_target_data)

  # Get task IDs from tasks config
  config_tasks <- hubUtils::read_config(hub_path, "tasks")

  # 1. Start with hub_schema subset for task ID columns
  hub_schema <- create_hub_schema(config_tasks)
  ts_schema <- hub_schema[hub_schema$names %in% observable_unit]

  # 2. Add date column (Date type)
  ts_schema[[config_date_col]] <- arrow::date32()

  # 3. Add non-task ID columns from config
  if (!is.null(non_task_id_schema) && length(non_task_id_schema) > 0) {
    # Convert R types to Arrow types
    r_to_arrow <- r_to_arrow_datatypes()
    # non_task_id_schema is a named list: list(col1 = "character", col2 = "integer")
    # Add each column one by one
    for (col_name in names(non_task_id_schema)) {
      r_type <- non_task_id_schema[[col_name]]
      ts_schema[[col_name]] <- r_to_arrow[[r_type]]
    }
  }
  # 4. Add observation column (from hub_schema's value type)
  ts_schema[["observation"]] <- hub_schema[["value"]]$type

  # 5. Add as_of column if versioned
  if (versioned) {
    ts_schema[["as_of"]] <- arrow::date32()
  }

  # 6. Reorder columns to match expected order
  expected_colnames <- get_target_data_colnames(
    config_target_data,
    target_type = "time-series"
  )
  ts_schema <- ts_schema[expected_colnames]

  if (r_schema) {
    ts_schema <- as_r_schema(ts_schema)
  }
  ts_schema
}

# Internal helper: Inference-based schema creation (existing logic)
#' @noRd
# nolint start: object_length_linter
create_timeseries_schema_from_inference <- function(
  # nolint end
  hub_path,
  date_col = NULL,
  na = c("NA", ""),
  ignore_files = NULL,
  r_schema = FALSE
) {
  ignore_files <- unique(c(ignore_files, "README", ".DS_Store"))
  ts_path <- validate_target_data_path(hub_path, "time-series")

  config_tasks <- read_config(hub_path)
  hub_schema <- create_hub_schema(config_tasks)

  ts_ext <- validate_target_file_ext(ts_path, hub_path)
  if (inherits(hub_path, "SubTreeFileSystem")) {
    ts_path <- file_system_path(hub_path, ts_path, uri = TRUE)
  }

  partition_schema <- get_partition_schema(
    hub_path,
    ts_path,
    target_type = "time-series",
    hub_schema = hub_schema
  )

  file_schema <- get_target_schema(
    ts_path,
    ext = ts_ext,
    na = na,
    ignore_files = ignore_files,
    partition_schema = partition_schema
  )

  ts_schema <- hub_schema[hub_schema$names %in% file_schema$names]
  ts_schema[["as_of"]] <- arrow::date32()
  ts_schema[["observation"]] <- hub_schema[["value"]]$type

  missing <- setdiff(file_schema$names, ts_schema$names)
  ts_schema <- arrow::schema(
    !!!c(ts_schema$fields, file_schema[missing]$fields)
  )

  if (!is.null(date_col)) {
    checkmate::assert_character(date_col, len = 1L)
    if (!date_col %in% ts_schema$names) {
      cli::cli_abort(
        c(
          "x" = "Column {.arg {date_col}} not found in {.path {basename(ts_path)}} file(s).",
          "i" = "Column must be present in the file or partition to be used as the date column."
        )
      )
    }
    ts_schema[[date_col]] <- arrow::date32()
  }

  has_date_col <- any(
    purrr::map_lgl(
      ts_schema[ts_schema$names != "as_of"]$fields,
      ~ .x$type == arrow::date32()
    )
  )
  if (!has_date_col) {
    cli::cli_abort(
      c(
        "x" = "No {.cls date} type column found in {.path {basename(ts_path)}}.",
        "i" = "Must contain at least one column other than optional {.arg as_of}
        column interprettable as {.cls date}."
      )
    )
  }
  ts_schema <- ts_schema[file_schema$names]

  if (r_schema) {
    ts_schema <- as_r_schema(ts_schema)
  }
  ts_schema
}
