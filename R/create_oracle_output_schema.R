#' Create oracle-output target data file schema
#'
#' @inheritParams connect_hub
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
create_oracle_output_schema <- function(hub_path) {
  oo_path <- validate_target_data_path(hub_path, "oracle-output")

  config_tasks <- read_config(hub_path)
  hub_schema <- create_hub_schema(config_tasks)

  oo_ext <- validate_target_file_ext(oo_path, hub_path)
  if (inherits(hub_path, "SubTreeFileSystem")) {
    oo_path <- file_system_path(hub_path, oo_path, uri = TRUE)
  }
  file_schema <- arrow::open_dataset(oo_path, format = oo_ext)$schema

  oo_schema <- hub_schema[hub_schema$names %in% file_schema$names]

  oo_schema[["oracle_value"]] <- hub_schema[["value"]]$type

  missing <- setdiff(file_schema$names, oo_schema$names)
  oo_schema <- arrow::schema(!!!c(oo_schema$fields, file_schema[missing]$fields))

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
  oo_schema[file_schema$names]
}
