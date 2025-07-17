#' Create oracle-output target data file schema
#'
#' @inheritParams connect_hub
#' @inheritParams create_hub_schema
#'
#' @return an arrow `<schema>` class object
#' @export
#' @importFrom rlang !!!
#' @importFrom hubUtils read_config
#' @examples
#' #' # Clone example hub
#' tmp_hub_path <- withr::local_tempdir()
#' example_hub <- "https://github.com/hubverse-org/example-complex-forecast-hub.git"
#' gert::git_clone(url = example_hub, path = tmp_hub_path)
#' # Create target oracle-output schema
#' create_oracle_output_schema(tmp_hub_path)
#' #  target oracle-output schema from a cloud hub
#' s3_hub_path <- s3_bucket("example-complex-forecast-hub")
#' create_oracle_output_schema(s3_hub_path)
create_oracle_output_schema <- function(
  hub_path,
  na = c("NA", ""),
  ignore_files = NULL,
  r_schema = FALSE
) {
  ignore_files <- unique(c(ignore_files, "README", ".DS_Store"))
  oo_path <- validate_target_data_path(hub_path, "oracle-output")

  config_tasks <- read_config(hub_path)
  hub_schema <- create_hub_schema(config_tasks)

  oo_ext <- validate_target_file_ext(oo_path, hub_path)
  if (inherits(hub_path, "SubTreeFileSystem")) {
    oo_path <- file_system_path(hub_path, oo_path, uri = TRUE)
  }

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
    ignore_files = ignore_files
  )

  oo_schema <- hub_schema[hub_schema$names %in% file_schema$names]
  oo_schema[["oracle_value"]] <- hub_schema[["value"]]$type

  missing <- setdiff(file_schema$names, oo_schema$names)
  oo_schema <- arrow::schema(
    !!!c(oo_schema$fields, file_schema[missing]$fields)
  )

  has_date_col <- any(
    purrr::map_lgl(
      oo_schema$fields,
      ~ .x$type == arrow::date32()
    )
  )
  if (!has_date_col) {
    cli::cli_abort(
      c(
        "x" = "No {.cls date} type column found in {.path {basename(oo_path)}}.",
        "i" = "Must contain at least one column interprettable as {.cls date}."
      )
    )
  }
  oo_schema <- oo_schema[file_schema$names]

  if (r_schema) {
    oo_schema <- as_r_schema(oo_schema)
  }
  oo_schema
}
