#' Create expanded grid of valid task ID and output type value combinations
#'
#' `r lifecycle::badge("defunct")` This function has been moved to the `hubValidations`
#' package and renamed to `expand_model_out_grid()`.
#' @param config_tasks a list version of the content's of a hub's `tasks.json`
#' config file, accessed through the `"config_tasks"` attribute of a `<hub_connection>`
#' object or function [hubUtils::read_config()].
#' @param round_id Character string. Round identifier. If the round is set to
#' `round_id_from_variable: true`, IDs are values of the task ID defined in the round's
#' `round_id` property of `config_tasks`.
#' Otherwise should match round's `round_id` value in config. Ignored if hub
#' contains only a single round.
#' @param required_vals_only Logical. Whether to return only combinations of
#' Task ID and related output type ID required values.
#' @param all_character Logical. Whether to return all character column.
#' @param bind_model_tasks Logical. Whether to bind expanded grids of
#' values from multiple modeling tasks into a single tibble/arrow table or
#' return a list.
#' @param include_sample_ids Logical. Whether to include sample identifiers in
#' the `output_type_id` column.
#'
#' @return If `bind_model_tasks = TRUE` (default) a tibble or arrow table
#' containing all possible task ID and related output type ID
#' value combinations. If `bind_model_tasks = FALSE`, a list containing a
#' tibble or arrow table for each round modeling task.
#'
#' Columns are coerced to data types according to the hub schema,
#' unless `all_character = TRUE`. If `all_character = TRUE`, all columns are returned as
#' character which can be faster when large expanded grids are expected.
#' If `required_vals_only = TRUE`, values are limited to the combinations of required
#' values only.
#' @inheritParams coerce_to_hub_schema
#' @details
#' When a round is set to `round_id_from_variable: true`,
#' the value of the task ID from which round IDs are derived (i.e. the task ID
#' specified in `round_id` property of `config_tasks`) is set to the value of the
#' `round_id` argument in the returned output.
#'
#' When sample output types are included in the output and `include_sample_ids = TRUE`,
#' the `output_type_id` column contains example sample indexes which are useful
#' for identifying the compound task ID structure of multivariate sampling
#' distributions in particular, i.e. which combinations of task ID values
#' represent individual samples.
#' @export
expand_model_out_val_grid <- function(
  config_tasks,
  round_id,
  required_vals_only = FALSE,
  all_character = FALSE,
  as_arrow_table = FALSE,
  bind_model_tasks = TRUE,
  include_sample_ids = FALSE
) {
  lifecycle::deprecate_stop(
    when = "1.0.0",
    what = "expand_model_out_val_grid()",
    with = "hubValidations::expand_model_out_grid()"
  )
}
