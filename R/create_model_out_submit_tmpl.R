#' Create a model output submission file template
#'
#' `r lifecycle::badge("defunct")` This function has been moved to the `hubValidations`
#' package and renamed to `submission_tmpl()`.
#' @param hub_con A `⁠<hub_connection`>⁠ class object.
#' @inheritParams expand_model_out_val_grid
#' @param complete_cases_only Logical. If `TRUE` (default) and `required_vals_only = TRUE`,
#' only rows with complete cases of combinations of required values are returned.
#' If `FALSE`, rows with incomplete cases of combinations of required values
#' are included in the output.
#'
#' @return a tibble template containing an expanded grid of valid task ID and
#' output type ID value combinations for a given submission round
#' and output type.
#' If `required_vals_only = TRUE`, values are limited to the combination of required
#' values only.
#'
#' @details
#' For task IDs or output_type_ids where all values are optional, by default, columns
#' are included as columns of `NA`s when `required_vals_only = TRUE`.
#' When such columns exist, the function returns a tibble with zero rows, as no
#' complete cases of required value combinations exists.
#' _(Note that determination of complete cases does excludes valid `NA`
#' `output_type_id` values in `"mean"` and `"median"` output types)._
#' To return a template of incomplete required cases, which includes `NA` columns, use
#' `complete_cases_only = FALSE`.
#'
#' When sample output types are included in the output, the `output_type_id`
#' column contains example sample indexes which are useful for identifying the
#' compound task ID structure of multivariate sampling distributions in particular,
#' i.e. which combinations of task ID values represent individual samples.
#'
#' When a round is set to `round_id_from_variable: true`,
#' the value of the task ID from which round IDs are derived (i.e. the task ID
#' specified in `round_id` property of `config_tasks`) is set to the value of the
#' `round_id` argument in the returned output.
#' @export
create_model_out_submit_tmpl <- function(
  hub_con,
  config_tasks,
  round_id,
  required_vals_only = FALSE,
  complete_cases_only = TRUE
) {
  lifecycle::deprecate_stop(
    when = "1.0.0",
    what = "create_model_out_submit_tmpl()",
    with = "hubValidations::submission_tmpl()"
  )
}
