#' Convert or validate an Arrow schema for compatibility with base R column types
#'
#' These functions help convert or validate an [arrow::Schema] object (typically from a Parquet file
#' or Arrow dataset) by translating Arrow types to R equivalents, extracting type strings,
#' or checking for compatibility.
#'
#' - `as_r_schema()` maps Arrow types to base **R types** (e.g., `"int32"` → `"integer"`).
#' It throws an error if unsupported column types are present.
#' - `arrow_schema_to_string()` returns a named character vector of **raw Arrow
#' type strings** (e.g., `"int64"`, `"date32[day]"`) for schema field.
#' - `is_supported_arrow_type()` returns a named logical vector indicating whether
#' each schema field type is supported.
#' - `validate_arrow_schema()` throws an error if any fields has an unsupported
#' Arrow type.
#'
#' For a full list of supported types and their R mappings, see [arrow_to_r_datatypes()].
#'
#' @param arrow_schema An [arrow::Schema] object, such as one returned by
#'   `arrow::read_parquet(..., as_data_frame = FALSE)$schema` or `arrow::open_dataset(...)$schema`.
#' @param call The calling environment, used for error reporting in `validate_arrow_schema()`
#'   and `as_r_schema()` (default: caller's environment).
#'
#' @return
#' - `as_r_schema()`: A named character vector mapping column names to base R type strings
#'   (e.g., `"integer"`, `"double"`, `"logical"`).
#' - `arrow_schema_to_string()`: A named character vector mapping column names to Arrow type strings.
#' - `is_supported_arrow_type()`: A named logical vector indicating whether each column is supported.
#' - `validate_arrow_schema()`: Returns the original schema (invisibly) if all column types are supported; otherwise throws an error.
#'
#' @export
#'
#' @examples
#' # Path to a single Parquet file
#' file_path <- system.file(
#'   "testhubs/parquet/model-output/hub-baseline/2022-10-01-hub-baseline.parquet",
#'   package = "hubUtils"
#' )
#'
#' # Get schema from the file
#' file_schema <- arrow::read_parquet(file_path, as_data_frame = FALSE)$schema
#'
#' # Convert to R types
#' as_r_schema(file_schema)
#'
#' # Get raw Arrow type strings
#' arrow_schema_to_string(file_schema)
#'
#' # Check which columns are supported
#' is_supported_arrow_type(file_schema)
#'
#' # Validate schema (throws error if any unsupported types are present)
#' validate_arrow_schema(file_schema)
#'
#' # From a multi-file dataset
#' dataset_path <- system.file(
#'   "testhubs/parquet/model-output/hub-baseline",
#'   package = "hubUtils"
#' )
#' ds <- arrow::open_dataset(dataset_path)
#' as_r_schema(ds$schema)
#' arrow_schema_to_string(ds$schema)
#' is_supported_arrow_type(ds$schema)
#' validate_arrow_schema(ds$schema)
as_r_schema <- function(arrow_schema, call = rlang::caller_env()) {
  checkmate::assert_class(arrow_schema, "Schema")

  validate_arrow_schema(arrow_schema, call)

  string_schema <- arrow_schema_to_string(arrow_schema)

  arrow_to_r_datatypes[string_schema] |>
    purrr::set_names(names(arrow_schema))
}

#' @rdname as_r_schema
#' @export
arrow_schema_to_string <- function(arrow_schema) {
  checkmate::assert_class(arrow_schema, "Schema")

  fields <- purrr::set_names(
    arrow_schema$fields,
    names(arrow_schema)
  )

  purrr::map_chr(fields, \(.x) .x$type$ToString())
}

#' @rdname as_r_schema
#' @export
is_supported_arrow_type <- function(arrow_schema) {
  checkmate::assert_class(arrow_schema, "Schema")

  string_schema <- arrow_schema_to_string(arrow_schema)

  purrr::set_names(
    string_schema %in% names(arrow_to_r_datatypes),
    names(arrow_schema)
  )
}

#' @rdname as_r_schema
#' @export
validate_arrow_schema <- function(arrow_schema, call = rlang::caller_env()) {
  checkmate::assert_class(arrow_schema, "Schema")

  if (!all(is_supported_arrow_type(arrow_schema))) {
    cli::cli_abort(
      c(
        "x" = "Unsupported data type in schema: {.val {names(arrow_schema)[!is_supported_arrow_type(arrow_schema)]}}.",
        "i" = "Supported types are: {.val {names(arrow_to_r_datatypes)}}."
      ),
      call = call
    )
  }

  invisible(TRUE)
}
