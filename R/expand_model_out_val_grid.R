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
#' # Hub with sample output type
#' config_tasks <- hubUtils::read_config_file(system.file("config", "tasks.json",
#'   package = "hubData"
#' ))
#' expand_model_out_val_grid(config_tasks,
#'   round_id = "2022-12-26"
#' )
#' # Include sample IDS
#' expand_model_out_val_grid(config_tasks,
#'   round_id = "2022-12-26",
#'   include_sample_ids = TRUE
#' )
#' # Hub with sample output type and compound task ID structure
#' config_tasks <- hubUtils::read_config_file(system.file("config", "tasks-comp-tid.json",
#'   package = "hubData"
#' ))
#' expand_model_out_val_grid(config_tasks,
#'   round_id = "2022-12-26",
#'   include_sample_ids = TRUE
#' )
expand_model_out_val_grid <- function(config_tasks,
                                      round_id,
                                      required_vals_only = FALSE,
                                      all_character = FALSE,
                                      as_arrow_table = FALSE,
                                      bind_model_tasks = TRUE,
                                      include_sample_ids = FALSE) {
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
    # Fix round_id value to current round_id in round_id variable column
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
    purrr::map(
      ~ extract_mt_output_type_ids(.x, config_tid)
    ) %>%
    process_grid_inputs(required_vals_only = required_vals_only) %>%
    purrr::map(function(.x) {
      purrr::compact(.x)
    })

  # Expand output grid individually for each modeling task and output type.
  grid <- purrr::map2(
    task_id_l, output_type_l,
    ~ expand_output_type_grid(
      task_id_values = .x,
      output_type_values = .y
    )
  )

  if (include_sample_ids) {
    grid <- add_sample_idx(grid, round_config, config_tid)
  }

  process_mt_grid_outputs(
    grid,
    config_tasks,
    all_character = all_character,
    as_arrow_table = as_arrow_table,
    bind_model_tasks = bind_model_tasks
  )
}

# Extracts/collapses individual task ID values depending on whether all or just required
# values are needed.
process_grid_inputs <- function(x, required_vals_only = FALSE) {
  if (required_vals_only) {
    purrr::map(x, ~ .x %>% purrr::map(~ .x[["required"]]))
  } else {
    purrr::modify_depth(x, .depth = 2, ~ unlist(.x, use.names = FALSE))
  }
}

# Function that expands modeling task level lists of task IDs and output type
# values into a grid and combines them into a single tibble.
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

# Given expanded grids are constructed for specific rounds, this functions fixes
# the round_id in the any round_id variable column (if round_id_from_variable = TRUE)
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

# Function that processes lists of modeling tasks grids of output type values
# and task IDs by (depending on settings):
# - padding with NA columns.
# - applying the required schema and converting to arrow tables.
# - binding multiple modeling task grids together.
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

# Pad any columns in all_cols missing in x of with new NA columns
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

# Adds example sample ids to the output type id column which are unique
# across multiple modeling task groups. Only apply to v3 and above sample output
# type configurations.
add_sample_idx <- function(x, round_config, config_tid) {
  spl_idx_0 <- 0L
  for (i in seq_along(x)) {
    # Check that the modeling task config has a v3 sample configuration
    config_has_v3_spl <- purrr::pluck(
      round_config[["model_tasks"]][[i]],
      "output_type", "sample", "output_type_id_params"
    ) %>%
      is.null() %>%
      isFALSE()

    # Check that x (the output df) has a sample output type (e.g. samples could be
    # missing where only required values are requested but samples are optional)
    x_has_spl <- "sample" %in% x[[i]][["output_type"]]
    if (all(config_has_v3_spl, x_has_spl)) {
      x[[i]] <- add_mt_sample_idx(
        x = x[[i]],
        config = round_config[["model_tasks"]][[i]],
        start_idx = spl_idx_0,
        config_tid
      )
      spl_idx_0 <- spl_idx_0 + get_sample_n(x[[i]], config_tid)
    }
  }
  x
}

# Add sample index to output type data frame of a single modeling task group
# according the the compound task ID set.
add_mt_sample_idx <- function(x, config, start_idx = 0L, config_tid) {
  x_names <- names(x)

  spl <- x[
    x[["output_type"]] == "sample",
    setdiff(names(x), hubUtils::std_colnames)
  ]

  comp_tids <- purrr::pluck(
    config,
    "output_type",
    "sample",
    "output_type_id_params",
    "compound_taskid_set"
  )

  type <- purrr::pluck(
    config,
    "output_type",
    "sample",
    "output_type_id_params",
    "type"
  )

  if (is.null(comp_tids)) {
    comp_tids <- names(spl)
  } else {
    # Check whether some compound task IDs have only optional values
    # (i.e. the columns are missing in spl) and warn.
    # Only do so though if a specific compound task ID set is provided in the config.
    opt_comp_tids <- setdiff(comp_tids, names(spl))
    if (length(opt_comp_tids) > 0) {
      cli::cli_warn(
        "The compound task ID{?s} {.field {opt_comp_tids}} ha{?s/ve} all optional values.
      Representation of compound sample modeling tasks is not fully specified."
      )
    }
    # subset to compound task IDs that are present in spl
    comp_tids <- intersect(comp_tids, names(spl))
  }

  spl <- unique(spl[, comp_tids]) %>%
    dplyr::mutate(
      output_type = "sample",
      output_type_id = seq_len(nrow(.)) + start_idx
    ) %>%
    dplyr::left_join(spl, by = comp_tids)

  if (!is.null(type) && type == "character") {
    spl[[config_tid]] <- sprintf("s%s", spl[[config_tid]])
  }

  x[x[["output_type"]] != "sample", ] %>%
    rbind(spl[, x_names])
}

get_sample_n <- function(x, config_tid) {
  x[x[["output_type"]] == "sample", config_tid, drop = TRUE] %>%
    unique() %>%
    length()
}

extract_mt_output_type_ids <- function(x, config_tid) {
  purrr::map(
    x,
    function(.x) {
      if (config_tid %in% names(.x)) {
        .x[[config_tid]]
      } else if ("output_type_id_params" %in% names(.x)) {
        if (.x[["output_type_id_params"]][["is_required"]]) {
          list(required = NA, optional = NULL)
        } else {
          list(required = NULL, optional = NA)
        }
      } else {
        NULL
      }
    }
  )
}
