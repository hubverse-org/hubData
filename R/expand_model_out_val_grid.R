#' Create expanded grid of valid task ID and output type value combinations
#'
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
#' @export
#'
#' @examples
#' hub_con <- hubData::connect_hub(
#'   system.file("testhubs/flusight", package = "hubUtils")
#' )
#' config_tasks <- attr(hub_con, "config_tasks")
#' expand_model_out_val_grid(config_tasks, round_id = "2023-01-02")
#' expand_model_out_val_grid(
#'   config_tasks,
#'   round_id = "2023-01-02",
#'   required_vals_only = TRUE
#' )
#' # Specifying a round in a hub with multiple round configurations.
#' hub_con <- hubData::connect_hub(
#'   system.file("testhubs/simple", package = "hubUtils")
#' )
#' config_tasks <- attr(hub_con, "config_tasks")
#' expand_model_out_val_grid(config_tasks, round_id = "2022-10-01")
#' # Later round_id maps to round config that includes additional task ID 'age_group'.
#' expand_model_out_val_grid(config_tasks, round_id = "2022-10-29")
#' # Coerce all columns to character
#' expand_model_out_val_grid(config_tasks,
#'   round_id = "2022-10-29",
#'   all_character = TRUE
#' )
#' # Return arrow table
#' expand_model_out_val_grid(config_tasks,
#'   round_id = "2022-10-29",
#'   all_character = TRUE,
#'   as_arrow_table = TRUE
#' )
expand_model_out_val_grid <- function(config_tasks,
                                      round_id,
                                      required_vals_only = FALSE,
                                      all_character = FALSE,
                                      as_arrow_table = FALSE,
                                      bind_model_tasks = TRUE) {
  round_idx <- hubUtils::get_round_idx(config_tasks, round_id)

  round_config <- purrr::pluck(
    config_tasks,
    "rounds",
    round_idx
  )

  task_id_l <- purrr::map(
    round_config[["model_tasks"]],
    ~ .x[["task_ids"]] %>%
      null_taskids_to_na()
  ) %>%
    fix_round_id(
      round_id = round_id,
      round_config = round_config,
      round_ids = hubUtils::get_round_ids(config_tasks)
    ) %>%
    process_grid_inputs(required_vals_only = required_vals_only)

  # Get output type id property according to config schema version
  # TODO: remove back-compatibility with schema versions < v2.0.0 when support
  # retired
  config_tid <- hubUtils::get_config_tid(config_tasks = config_tasks)

  output_type_l <- purrr::map(
    round_config[["model_tasks"]],
    function(.x) {
      .x[["output_type"]]
    }
  ) %>%
    purrr::map(function(.x) {
      .x %>%
        purrr::map(function(.x) {
          .x[[config_tid]]
        })
    }) %>%
    process_grid_inputs(required_vals_only = required_vals_only) %>%
    purrr::map(function(.x) {
      purrr::compact(.x)
    })

  # Expand output grid individually for each output type and coerce to hub schema
  # data types.

  purrr::map2(
    task_id_l, output_type_l,
    ~ expand_output_type_grid(
      task_id_values = .x,
      output_type_values = .y
    )
  ) %>%
    process_mt_grid_outputs(
      config_tasks,
      all_character = all_character,
      as_arrow_table = as_arrow_table,
      bind_model_tasks = bind_model_tasks
    )
}

process_grid_inputs <- function(x, required_vals_only = FALSE) {
  if (required_vals_only) {
    purrr::map(x, ~ .x %>% purrr::map(~ .x[["required"]]))
  } else {
    purrr::modify_depth(x, .depth = 2, ~ unlist(.x, use.names = FALSE))
  }
}

expand_output_type_grid <- function(task_id_values,
                                    output_type_values) {
  purrr::imap(
    output_type_values,
    ~ c(task_id_values, list(
      output_type = .y,
      output_type_id = .x
    )) %>%
      purrr::compact() %>%
      expand.grid(stringsAsFactors = FALSE)
  ) %>%
    purrr::list_rbind()
}

fix_round_id <- function(x, round_id, round_config, round_ids) {
  if (round_config[["round_id_from_variable"]] && !is.null(round_id)) {
    round_id <- rlang::arg_match(round_id,
      values = round_ids
    )
    round_id_var <- round_config[["round_id"]]
    purrr::map(
      x,
      function(.x) {
        purrr::imap(
          .x,
          function(.x, .y) {
            if (.y == round_id_var) {
              list(required = round_id, optional = NULL)
            } else {
              .x
            }
          }
        )
      }
    )
  } else {
    x
  }
}


process_mt_grid_outputs <- function(x, config_tasks, all_character,
                                    as_arrow_table = TRUE,
                                    bind_model_tasks = TRUE) {
  if (bind_model_tasks) {
    # To bind multiple modeling task grids together, we need to ensure they contain
    # the same columns. Any missing columns are padded with NAs.
    all_cols <- purrr::map(x, ~ names(.x)) %>%
      unlist() %>%
      unique()

    schema_cols <- names(
      create_hub_schema(
        config_tasks,
        partitions = NULL
      )
    )
    all_cols <- schema_cols[schema_cols %in% all_cols]
    x <- purrr::map(x, ~ pad_missing_cols(.x, all_cols))
  }

  if (all_character) {
    x <- purrr::map(
      x, ~ coerce_to_character(
        .x,
        as_arrow_table = as_arrow_table
      )
    )
  } else {
    x <- purrr::map(
      x,
      ~ coerce_to_hub_schema(
        .x,
        config_tasks,
        as_arrow_table = as_arrow_table
      )
    )
  }
  if (bind_model_tasks) {
    return(do.call(rbind, x))
  } else {
    return(x)
  }
}


pad_missing_cols <- function(x, all_cols) {
  if (inherits(x, "data.frame")) {
    x[, all_cols[!all_cols %in% names(x)]] <- NA
    return(x[, all_cols])
  }
  if (inherits(x, "ArrowTabular")) {
    missing_colnames <- setdiff(all_cols, names(x))
    if (length(missing_colnames) == 0L) {
      return(x)
    }

    missing_cols <- as.list(rep(NA, length(missing_colnames))) %>%
      stats::setNames(missing_colnames) %>%
      as.data.frame() %>%
      arrow::arrow_table()

    return(cbind(x, missing_cols)[, all_cols])
  }
  x
}

# Convert required value to NA in task IDs where both required and optional
#  are  as NA.
null_taskids_to_na <- function(model_task) {
  to_na <- purrr::map_lgl(
    model_task, ~ all(purrr::map_lgl(.x, is.null))
  )
  purrr::modify_if(model_task,
    .p = to_na,
    ~ list(
      required = NA,
      optional = NULL
    )
  )
}
