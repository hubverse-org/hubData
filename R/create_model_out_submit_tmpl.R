#' Create a model output submission file template
#'
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
#'
#' @examples
#' hub_con <- hubData::connect_hub(
#'   system.file("testhubs/flusight", package = "hubUtils")
#' )
#' create_model_out_submit_tmpl(hub_con, round_id = "2023-01-02")
#' create_model_out_submit_tmpl(
#'   hub_con,
#'   round_id = "2023-01-02",
#'   required_vals_only = TRUE
#' )
#' create_model_out_submit_tmpl(
#'   hub_con,
#'   round_id = "2023-01-02",
#'   required_vals_only = TRUE,
#'   complete_cases_only = FALSE
#' )
#' # Specifying a round in a hub with multiple rounds
#' hub_con <- hubData::connect_hub(
#'   system.file("testhubs/simple", package = "hubUtils")
#' )
#' create_model_out_submit_tmpl(hub_con, round_id = "2022-10-01")
#' create_model_out_submit_tmpl(hub_con, round_id = "2022-10-29")
#' create_model_out_submit_tmpl(hub_con,
#'   round_id = "2022-10-29",
#'   required_vals_only = TRUE
#' )
#' create_model_out_submit_tmpl(hub_con,
#'   round_id = "2022-10-29",
#'   required_vals_only = TRUE,
#'   complete_cases_only = FALSE
#' )
#' # Hub with sample output type
#' config_tasks <- read_config_file(system.file("config", "tasks.json",
#'   package = "hubData"
#' ))
#' create_model_out_submit_tmpl(
#'   config_tasks = config_tasks,
#'   round_id = "2022-12-26"
#' )
#' # Hub with sample output type and compound task ID structure
#' config_tasks <- read_config_file(system.file("config", "tasks-comp-tid.json",
#'   package = "hubData"
#' ))
#' create_model_out_submit_tmpl(
#'   config_tasks = config_tasks,
#'   round_id = "2022-12-26"
#' )
create_model_out_submit_tmpl <- function(hub_con, config_tasks, round_id,
                                         required_vals_only = FALSE,
                                         complete_cases_only = TRUE) {
  switch(rlang::check_exclusive(hub_con, config_tasks),
    hub_con = {
      checkmate::assert_class(hub_con, classes = "hub_connection")
      config_tasks <- attr(hub_con, "config_tasks")
    },
    config_tasks = checkmate::assert_list(config_tasks)
  )

  tmpl_df <- expand_model_out_val_grid(config_tasks,
    round_id = round_id,
    required_vals_only = required_vals_only,
    include_sample_ids = TRUE
  )

  tmpl_cols <- c(
    hubUtils::get_round_task_id_names(
      config_tasks,
      round_id
    ),
    hubUtils::std_colnames[names(hubUtils::std_colnames) != "model_id"]
  )

  # Add NA columns for value and all optional cols
  na_cols <- tmpl_cols[!tmpl_cols %in% names(tmpl_df)]
  tmpl_df[, na_cols] <- NA
  tmpl_df <- coerce_to_hub_schema(tmpl_df, config_tasks)[, tmpl_cols]

  if (complete_cases_only) {
    subset_complete_cases(tmpl_df)
  } else {
    # We only need to notify of added `NA` columns when we are not subsetting
    # for complete cases only as `NA`s will only show up when
    # complete_cases_only == FALSE
    if (any(na_cols != hubUtils::std_colnames["value"])) {
      message_opt_tasks(
        na_cols, n_model_tasks(config_tasks, round_id)
      )
    }
    tmpl_df
  }
}

n_model_tasks <- function(config_tasks, round_id) {
  length(hubUtils::get_round_model_tasks(config_tasks, round_id))
}

message_opt_tasks <- function(na_cols, n_mt) {
  na_cols <- na_cols[na_cols != "value"]
  msg <- c("!" = "{cli::qty(length(na_cols))}Column{?s} {.val {na_cols}}
           whose values are all optional included as all {.code NA} column{?s}.")
  if (n_mt > 1L) {
    msg <- c(
      msg,
      "!" = "Round contains more than one modeling task ({.val {n_mt}})"
    )
  }
  msg <- c(
    msg,
    "i" = "See Hub's {.path tasks.json} file or {.cls hub_connection} attribute
          {.val config_tasks} for details of optional
    task ID/output_type/output_type ID value combinations."
  )
  cli::cli_bullets(msg)
}

subset_complete_cases <- function(tmpl_df) {
  # get complete cases across all columns except 'value'
  cols <- !names(tmpl_df) %in% hubUtils::std_colnames[c("value", "model_id")]
  compl_cases <- stats::complete.cases(tmpl_df[, cols])

  # As 'mean' and 'median' output types have valid 'NA' entries in 'output_type_id'
  # column when they are required, ovewrite the initial check for
  # complete cases by performing the check again only on rows where output type is
  # mean/median and using all columns except 'value' and 'output_type'.
  na_output_type_idx <- which(
    tmpl_df[[hubUtils::std_colnames["output_type"]]] %in% c("mean", "median")
  )
  cols <- !names(tmpl_df) %in% hubUtils::std_colnames[c(
    "output_type_id",
    "value",
    "model_id"
  )]
  compl_cases[na_output_type_idx] <- stats::complete.cases(
    tmpl_df[na_output_type_idx, cols]
  )
  tmpl_df[compl_cases, ]
}
