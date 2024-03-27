#' Collect Hub model output data
#'
#' `collect_hub` retrieves data from a `<hub_connection>/<mod_out_connection>` after executing any `<arrow_dplyr_query>` into a local tibble. The function also attempts to convert the output to a `model_out_tbl` class object before returning.
#' @param x a `<hub_connection>/<mod_out_connection>` or `<arrow_dplyr_query>` object.
#' @param silent Logical. Whether to suppress message generated if conversion to `model_out_tbl` fails.
#' @param ... Further argument passed on to [as_model_out_tbl()].
#'
#' @return A `model_out_tbl`, unless conversion to `model_out_tbl` fails in which case a `tibble` is returned.
#' @export
#'
#' @examples
#' hub_path <- system.file("testhubs/simple", package = "hubUtils")
#' hub_con <- connect_hub(hub_path)
#' # Collect all data in a hub
#' hub_con %>% collect_hub()
#' # Filter data before collecting
#' hub_con %>%
#'   dplyr::filter(is.na(output_type_id)) %>%
#'   collect_hub()
#' # Pass arguments to as_model_out_tbl()
#'dplyr::filter(hub_con, is.na(output_type_id)) %>%
#'  collect_hub(remove_empty = TRUE)
collect_hub <- function(x, silent = FALSE, ...) {
  if (inherits(x, "list")) {
    cli::cli_warn("Hub is empty. No data to collect. Returning {.code NULL}")
    return(NULL)
  }

  tbl <- tryCatch(
    dplyr::collect(x),
    error = function(e) {
      cli::cli_abort(e$message,
        call = rlang::expr(collect(x))
      )
    }
  )
  tryCatch(
    if (silent) {
      suppressMessages(as_model_out_tbl(tbl, ...))
    } else {
      as_model_out_tbl(tbl, ...)
    },
    error = function(e) {
      if (!silent) {
        cli::cli_inform(
          c(
            "Cannot coerce to {.cls model_out_tbl}",
            stats::setNames(e$message, "!")
          ),
          call = rlang::expr(
            as_model_out_tbl(x)
          )
        )
      }
      tbl
    }
  )
}
