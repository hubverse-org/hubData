#' Create a Hub arrow schema
#'
#' Create an arrow schema from a `tasks.json` config file. For use when
#' opening an arrow dataset.
#'
#' @param config_tasks a list version of the content's of a hub's `tasks.json`
#' config file created using function [hubUtils::read_config()].
#' @param partitions a named list specifying the arrow data types of any
#' partitioning column.
#' @param output_type_id_datatype character string. One of `"from_config"`, `"auto"`,
#' `"character"`, `"double"`, `"integer"`, `"logical"`, `"Date"`.
#' Defaults to `"from_config"` which uses the setting in the `output_type_id_datatype`
#' property in the `tasks.json` config file if available. If the property is
#' not set in the config, the argument falls back to `"auto"` which determines
#' the  `output_type_id` data type automatically from the `tasks.json`
#' config file as the simplest data type required to represent all output
#' type ID values across all output types in the hub.
#' Other data type values can be used to override automatic determination.
#' Note that attempting to coerce `output_type_id` to a data type that is
#' not valid for the data (e.g. trying to coerce`"character"` values to
#' `"double"`) will likely result in an error or potentially unexpected
#' behaviour so use with care.
#' @param r_schema Logical. If `FALSE` (default), return an [arrow::schema()] object.
#' If `TRUE`, return a character vector of R data types.
#'
#' @return an arrow schema object that can be used to define column datatypes when
#' opening model output data. If `r_schema = TRUE`, a character vector of R data types.
#' @export
#'
#' @examples
#' hub_path <- system.file("testhubs/simple", package = "hubUtils")
#' config_tasks <- hubUtils::read_config(hub_path, "tasks")
#' schema <- create_hub_schema(config_tasks)
create_hub_schema <- function(config_tasks,
                              partitions = list(model_id = arrow::utf8()),
                              output_type_id_datatype = c(
                                "from_config", "auto", "character",
                                "double", "integer",
                                "logical", "Date"
                              ), r_schema = FALSE) {
  output_type_id_datatype <- rlang::arg_match(output_type_id_datatype)
  if (output_type_id_datatype == "from_config") {
    output_type_id_datatype <- config_tasks$output_type_id_datatype
    if (is.null(output_type_id_datatype)) {
      output_type_id_datatype <- "auto"
    } else {
      output_type_id_datatype <- rlang::arg_match(output_type_id_datatype)
    }
  }

  task_id_names <- hubUtils::get_task_id_names(config_tasks)

  task_id_types <- purrr::map_chr(
    purrr::set_names(task_id_names),
    ~ get_task_id_type(
      config_tasks,
      .x
    )
  )

  arrow_datatypes <- list(
    character = arrow::utf8(),
    double = arrow::float64(),
    integer = arrow::int32(),
    logical = arrow::boolean(),
    Date = arrow::date32()
  )

  if (output_type_id_datatype == "auto") {
    output_type_id_type <- get_output_type_id_type(config_tasks)
  } else {
    output_type_id_type <- output_type_id_datatype
  }

  hub_datatypes <- c(task_id_types,
    output_type = "character",
    output_type_id = output_type_id_type,
    value = get_value_type(config_tasks)
  )

  if (r_schema) {
    return(
      c(
        hub_datatypes,
        get_partition_r_datatype(partitions, arrow_datatypes)
      )
    )
  }

  c(
    purrr::set_names(
      arrow_datatypes[hub_datatypes],
      names(hub_datatypes)
    ),
    partitions
  ) %>%
    arrow::schema()
}

get_task_id_values <- function(config_tasks,
                               task_id_name,
                               round = "all") {
  if (round == "all") {
    model_tasks <- purrr::map(
      config_tasks[["rounds"]],
      ~ .x[["model_tasks"]]
    )
  } else if (is.integer(round)) {
    model_tasks <- purrr::map(
      config_tasks[["rounds"]][round],
      ~ .x[["model_tasks"]]
    )
  } else {
    round_idx <- which(
      purrr::map_chr(
        config_tasks[["rounds"]],
        ~ .x$round_id
      ) == round
    )
    model_tasks <- purrr::map(
      config_tasks[["rounds"]][round_idx],
      ~ .x[["model_tasks"]]
    )
  }

  model_tasks %>%
    purrr::map(~ .x %>%
      purrr::map(~ .x[["task_ids"]][[task_id_name]])) %>% # nolint: indentation_linter
    unlist(recursive = FALSE)
}

get_task_id_type <- function(config_tasks,
                             task_id_name,
                             round = "all") {
  values <- get_task_id_values(
    config_tasks,
    task_id_name,
    round
  ) %>%
    unlist()

  get_data_type(values)
}


get_output_type_id_type <- function(config_tasks) {
  # Get output type id property according to config schema version
  # TODO: remove back-compatibility with schema versions < v2.0.0 when support
  # retired
  config_tid <- hubUtils::get_config_tid(config_tasks = config_tasks)

  values <- purrr::map(
    config_tasks[["rounds"]],
    function(x) {
      x[["model_tasks"]]
    }
  ) %>%
    unlist(recursive = FALSE) %>%
    purrr::map(
      function(x) {
        x[["output_type"]]
      }
    ) %>%
    unlist(recursive = FALSE) %>%
    purrr::map(
      function(x) {
        purrr::pluck(x, config_tid) %>%
          purrr::modify_if(~ inherits(.x, "Date"), as.character)
      }
    ) %>%
    unlist()

  sample_values <- purrr::map(
    config_tasks[["rounds"]],
    function(x) {
      x[["model_tasks"]]
    }
  ) %>%
    unlist(recursive = FALSE) %>%
    purrr::map(
      function(x) {
        x[["output_type"]][["sample"]]
      }
    ) %>%
    purrr::map(
      function(x) {
        purrr::pluck(x, "output_type_id_params", "type")
      }
    ) %>%
    unlist() %>%
    # Instead of using R data type coercion by combining vectors of output type
    # id values, create length 1 vectors of sample output type id types
    # using the function specified by output_type_id_params type.
    # Get the appropriate function using `get`.
    purrr::map(~ get(.x)(length = 1L)) %>%
    unlist()

  get_data_type(c(values, sample_values))
}


get_value_type <- function(config_tasks) {
  types <- purrr::map(
    config_tasks[["rounds"]],
    ~ .x[["model_tasks"]]
  ) %>%
    unlist(recursive = FALSE) %>%
    purrr::map(~ .x[["output_type"]]) %>%
    purrr::flatten() %>%
    purrr::map(~ purrr::pluck(.x, "value", "type")) %>%
    unlist() %>%
    unique()

  coerce_datatype(types)
}

get_data_type <- function(x) {
  type <- typeof(x)

  if (type == "character" && test_iso_date(x)) {
    type <- "Date"
  }
  return(type)
}

coerce_datatype <- function(types) {
  if ("character" %in% types) {
    return("character")
  }
  if ("double" %in% types) {
    return("double")
  }
  if ("integer" %in% types) {
    return("integer")
  }
  if ("logical" %in% types) {
    return("logical")
  }
}

test_iso_date <- function(x) {
  to_date <- try(as.Date(x), silent = TRUE)
  isFALSE(inherits(to_date, "try-error")) &&
    isTRUE(all.equal(which(is.na(x)), which(is.na(to_date))))
}

get_partition_r_datatype <- function(partitions, arrow_datatypes) {
  if (is.null(partitions)) {
    return(NULL)
  }

  str_arrow_datatypes <- purrr::map_chr(
    arrow_datatypes,
    function(x) {
      x$ToString()
    }
  )
  str_partitions <- purrr::map(
    partitions,
    function(x) {
      x$ToString()
    }
  )
  purrr::map_chr(
    str_partitions,
    function(x) {
      names(str_arrow_datatypes)[x == str_arrow_datatypes]
    }
  )
}
