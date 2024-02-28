#' Print a `<hub_connection>` or `<mod_out_connection>` S3 class object
#'
#' @param x A `<hub_connection>` or `<mod_out_connection>` S3 class object.
#'
#' @param verbose Logical. Whether to print the full structure of the object.
#' Defaults to `FALSE`.
#' @param ... Further arguments passed to or from other methods.
#'
#' @export
#' @describeIn print.hub_connection print a `<hub_connection>` object.
#' @examples
#' hub_path <- system.file("testhubs/simple", package = "hubUtils")
#' hub_con <- connect_hub(hub_path)
#' hub_con
#' print(hub_con)
#' print(hub_con, verbose = TRUE)
#' mod_out_path <- system.file("testhubs/simple/model-output", package = "hubUtils")
#' mod_out_con <- connect_model_output(mod_out_path)
#' print(mod_out_con)
print.hub_connection <- function(x, verbose = FALSE, ...) {
  cli::cli_h2("{.cls {class(x)[1:2]}}")

  print_msg <- NULL


  if (!is.null(attr(x, "hub_path"))) {
    print_msg <- c(print_msg,
      "*" = "hub_name: {.val {attr(x, 'hub_name')}}",
      "*" = "hub_path: {.file {attr(x, 'hub_path')}}"
    )
  }
  if (!is.null(attr(x, "file_format"))) {
    print_msg <- c(print_msg,
      "*" = "file_format: {.val {print_file_format_meta(x)}}"
    )
  }
  if (!is.null(attr(x, "file_system"))) {
    print_msg <- c(print_msg,
      "*" = "file_system: {.val {attr(x, 'file_system')[1]}}"
    )
  }
  print_msg <- c(print_msg,
    "*" = "model_output_dir: {.val {attr(x, 'model_output_dir')}}"
  )

  if (!is.null(attr(x, "config_admin"))) {
    print_msg <- c(print_msg,
      "*" = "config_admin: {.path hub-config/admin.json}"
    )
  }
  if (!is.null(attr(x, "config_tasks"))) {
    print_msg <- c(print_msg,
      "*" = "config_tasks: {.path hub-config/tasks.json}"
    )
  }

  cli::cli_bullets(print_msg)

  if (inherits(x, "ArrowObject")) {
    cli::cli_h3("Connection schema")
    x$print()
  }

  if (verbose) {
    utils::str(x)
  }
  invisible(x)
}

#' @export
#' @describeIn print.hub_connection print a `<mod_out_connection>` object.
print.mod_out_connection <- function(x, verbose = FALSE, ...) {
  cli::cli_h2("{.cls {class(x)[1:2]}}")

  print_msg <- NULL

  if (!is.null(attr(x, "file_format"))) {
    print_msg <- c(print_msg,
      "*" = "file_format: {.val {print_file_format_meta(x)}}"
    )
  }
  if (!is.null(attr(x, "file_system"))) {
    print_msg <- c(print_msg,
      "*" = "file_system: {.val {attr(x, 'file_system')}}"
    )
  }
  print_msg <- c(print_msg,
    "*" = "model_output_dir: {.val {attr(x, 'model_output_dir')}}"
  )

  cli::cli_bullets(print_msg)

  if (inherits(x, "ArrowObject")) {
    cli::cli_h3("Connection schema")
    x$print()
  }

  if (verbose) {
    utils::str(x)
  }
  invisible(x)
}

print_file_format_meta <- function(x) {
  meta_tbl <- as.data.frame(attr(x, "file_format"))
  paste0(
    names(meta_tbl),
    "(", purrr::map_chr(meta_tbl, ~ sprintf("%s/%s", .x[1], .x[2])), ")"
  )
}
