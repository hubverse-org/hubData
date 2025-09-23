#' Check whether a path contains Hive-style partitioning
#'
#' This function checks if a given file or directory path includes one or more
#' Hive-style partition segments (i.e., subdirectories formatted as `key=value`).
#' This function can operate in a strict or lenient mode, depending on whether
#' you want to catch malformed partition-like segments.
#'
#' @param path Character string. Path to a
#'   file or directory.
#' @param strict Logical. If `TRUE`, the function will throw an error
#' if any malformed partition segments are found (e.g., `=value`,
#'   missing key, or malformed `=` without a value). If `FALSE`, it simply returns
#'   `TRUE` if any valid `key=value` segments are found.
#'
#' @return A logical value: `TRUE` if the path contains one or more valid Hive-style
#'   partition segments, `FALSE` otherwise.
#'
#' @details
#' A valid partition segment must:
#' - Contain an equals sign (`=`)
#' - Have a non-empty key before the equals sign
#' - May have an empty value (interpreted as `NA` in most Hive/Arrow contexts)
#'
#' In strict mode, the function validates that all `key=value` segments are well-formed
#' and will abort if any are not.
#'
#' @seealso [extract_hive_partitions()] to extract key-value pairs from Hive-style paths.
#'
#' @examples
#' is_hive_partitioned_path("data/country=US/year=2024/file.parquet")
#' is_hive_partitioned_path("data/country=/year=2024/", strict = TRUE)
#' # is_hive_partitioned_path("data/=US/year=2024/", strict = TRUE) # This will error
#'
#' @export
is_hive_partitioned_path <- function(path, strict = TRUE) {
  checkmate::assert_character(path, len = 1)
  # Split into path segments
  parts <- fs::path_split(path)[[1]]

  partition_like <- parts[grepl("=", parts)]
  # Match valid Hive-style partitions
  # Accepts: key=value or key= (missing value → NA)
  valid <- grepl("^[^/]+=[^/]*$", partition_like)

  if (strict && any(!valid)) {
    cli::cli_abort(c(
      "Invalid Hive-style partition segments detected in {.path {path}}:",
      "x" = paste0("{.val ", partition_like[!valid], "}")
    ))
  }

  any(valid)
}
#' Extract Hive-style partition key-value pairs from a path
#'
#' Given a filesystem path, this function extracts Hive-style partition
#' key-value pairs (i.e., path components formatted as `key=value`). It supports
#' decoding URL-encoded values (e.g., `"wk%20flu"` → `"wk flu"`), and handles
#' empty values (e.g., `"key="`) as `NA`, consistent with Hive and Arrow semantics.
#'
#' If `strict = TRUE`, the function will abort with a detailed error message
#' if any malformed partition-like segments are found.
#'
#' @param path A character string of length 1: the path to a file or directory.
#' @param strict Logical. If `TRUE`, invalid partition segments (e.g., `=value`, or just `=`)
#'   will trigger an error. If `FALSE`, only valid `key=value` components are returned.
#'
#' @return A named character vector where the names are partition keys and the values
#'   are decoded values. Returns `NULL` if no valid partitions are found.
#'
#' @examples
#' extract_hive_partitions("data/country=US/year=2024/file.parquet")
#' extract_hive_partitions("data/country=/year=2024/", strict = TRUE)
#' # extract_hive_partitions("data/=US/year=2024/", strict = TRUE) # This will error
#' @seealso [is_hive_partitioned_path()]
#' @export
extract_hive_partitions <- function(path, strict = TRUE) {
  checkmate::assert_character(path, len = 1)
  if (!is_hive_partitioned_path(path, strict = strict)) {
    return(NULL)
  }
  # Split the path
  split_path <- fs::path_split(path)[[1]]

  # Keep only the parts that contain an '=' sign — candidate key=value pairs
  kv_pairs <- split_path[grepl("=", split_path)]

  # Extract key-value pairs safely
  purrr::map(kv_pairs, function(pair) {
    # Split on the first '='
    parts <- utils::strcapture(
      "^([^=]+)=(.*)$",
      pair,
      proto = list(
        key = character(),
        val = character()
      )
    )
    # Sanity check: must have exactly 2 parts, and key must not be empty
    if (anyNA(parts) || parts$key == "") {
      return(NULL) # This should be caught already if strict = TRUE
    }

    # Interpret empty string as missing (NA), which is consistent with Hive/Arrow
    if (parts$val == "" || parts$val == "__HIVE_DEFAULT_PARTITION__") {
      parts$val <- NA
    } else {
      # Decode URL-encoded values
      parts$val <- utils::URLdecode(parts$val)
    }
    stats::setNames(parts$val, parts$key)
  }) |>
    purrr::compact() |> # Drop any NULLs (malformed pairs)
    unlist()
}

get_partition_schema <- function(
  hub_path,
  target_path,
  target_type = c("time-series", "oracle-output"),
  hub_schema = NULL
) {
  if (fs::path_ext(target_path) != "") {
    return(NULL)
  }
  target_type <- rlang::arg_match(target_type)
  files <- list_hub_files(
    hub_path,
    subdir = c(
      "target-data",
      target_type
    )
  )
  files <- grep(pattern = target_type, x = files, value = TRUE) |>
    purrr::keep(
      \(.x) {
        is_hive_partitioned_path(.x) &&
          fs::path_ext(.x) != ""
      }
    )
  if (length(files) == 0L) {
    return(NULL)
  }

  partition_vars <- purrr::map(
    files,
    ~ extract_hive_partitions(.x) |>
      names()
  ) |>
    unlist() |>
    unique()
  if (is.null(hub_schema)) {
    hub_schema <- hubData::create_hub_schema(
      hubUtils::read_config(hub_path)
    )
  }
  hub_schema$as_of <- arrow::date32()

  # Ensure all partition vars are in the schema as utf8 (arrow default) if not
  # defined in the tasks.json config
  non_hub_schema_partitions <- setdiff(partition_vars, names(hub_schema))
  if (length(non_hub_schema_partitions) > 0L) {
    non_hub_part_schema <- arrow::schema(
      purrr::map(non_hub_schema_partitions, ~ arrow::field(.x, arrow::utf8()))
    )
  } else {
    non_hub_part_schema <- arrow::schema()
  }
  hub_schema <- arrow::schema(
    !!!c(hub_schema$fields, non_hub_part_schema$fields)
  )

  hub_schema[partition_vars]
}
