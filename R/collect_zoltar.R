yyyy_mm_dd_date_format <- "%Y-%m-%d"  # e.g., '2017-01-17'

#' Load forecasts from zoltardata.com in hubverse format
#'
#' `collect_zoltar` retrieves data from a \href{https://zoltardata.com/}{zoltardata.com} project and
#' transforms it from Zoltar's native download format into a hubverse one. Zoltar (documentation
#' \href{https://docs.zoltardata.com/}{here}) is a pre-hubverse research project that implements a repository of model
#' forecast results, including tools to administer, query, and visualize uploaded data, along with R and Python APIs to
#' access data programmatically (\href{https://github.com/reichlab/zoltr/}{zoltr} and
#' \href{https://github.com/reichlab/zoltpy/}{zoltpy}, respectively.) (This hubData function is itself implemented using
#' the zoltr package.)
#'
#' @param project_name A string naming the Zoltar project to load forecasts from. Assumes the host is zoltardata.com .
#' @param models A character vector that specifies the models to query. Must be model abbreviations. Defaults to NULL,
#'   which queries all models in the project.
#' @param timezeros A character vector that specifies the timezeros to query. Must be yyyy-mm-dd format. Defaults to
#'   NULL, which queries all timezeros in the project.
#' @param units A character vector that specifies the units to query. Must be unit abbreviations. Defaults to NULL,
#'   which queries all units in the project.
#' @param targets A character vector that specifies the targets to query. Must be target names. Defaults to NULL,
#'   which queries all targets in the project.
#' @param types A character vector that specifies the forecast types to query. Choices are "bin", "point", "sample",
#'   "quantile", "mean", and "median". Defaults to NULL, which queries all types in the project. Note: While Zoltar
#'   supports "named" and "mode" forecasts, this function ignores them.
#' @param as_of A datetime string that specifies the forecast version. The datetime must include timezone information
#'   for disambiguation, without which the query will fail. The datatime parsing function used below (`base::strftime`)
#'   is extremely lenient when it comes to formatting, so please exercise caution. Defaults to NULL to load the latest
#'   version.
#' @param point_output_type A string that specifies how to convert zoltar `point` forecast data to hubverse output type.
#'   Must be either "median" or "mean". Defaults to "median".
#'
#' @details
#' Zoltar's data model differs from that of the hubverse in a few important ways. While Zoltar's model has the
#' concepts of unit, target, and timezero, hubverse projects have hub-configurable columns, which makes the mapping
#' from the former to the latter imperfect. In particular, Zoltar units translate roughly to hubverse task IDs, Zoltar
#' targets include both the target outcome and numeric horizon in the target name, and Zoltar timezeros map to round
#' ids. Finally, Zoltar's forecast types differ from those of the hubverse. Whereas Zoltar has seven types (bin,
#' named, point, sample, quantile, mean, median, and mode), the hubverse has six (cdf, mean, median, pmf, quantile,
#' sample), only some of which overlap.
#'
#' Additional notes:
#' * Requires the user to have a Zoltar account (use the \href{https://zoltardata.com/about}{Zoltar contact page}
#'   to request one).
#' * Requires `Z_USERNAME` and `Z_PASSWORD` environment vars to be set to those of the user's Zoltar account.
#' * While Zoltar supports "named" and "mode" forecasts, this function ignores them.
#' * Rows with non-numeric values are ignored.
#' * This function removes numeric_horizon mentions from zoltar target names. Target names can contain a maximum of
#'   one numeric_horizon. Example: "1 wk ahead inc case" -> "wk ahead inc case".
#' * Querying a large number of rows may cause errors, so we recommend providing one or more filtering arguments
#'   (e.g., models, timezeros, etc.) to limit the result.
#'
#' @return A hubverse model_out_tbl containing the following columns: "model_id", "timezero", "season", "unit",
#'   "horizon", "target", "output_type", "output_type_id", and "value".
#' @export
#'
#' @examples \dontrun{
#' df <- collect_zoltar("Docs Example Project")
#' df <-
#'   collect_zoltar("Docs Example Project", models = c("docs_mod"),
#'                         timezeros = c("2011-10-16"), units = c("loc1", "loc3"),
#'                         targets = c("pct next week", "cases next week"), types = c("point"),
#'                         as_of = NULL, point_output_type = "mean")
#' }
#'
#' @importFrom rlang .data
#' @importFrom zoltr do_zoltar_query
collect_zoltar <- function(project_name, models = NULL, timezeros = NULL, units = NULL, targets = NULL,
                           types = NULL, as_of = NULL, point_output_type = "median") {
  zoltar_connection <- zoltr::new_connection()
  zoltr::zoltar_authenticate(zoltar_connection, Sys.getenv("Z_USERNAME"), Sys.getenv("Z_PASSWORD"))

  project_url <- validate_arguments(zoltar_connection, project_name, models, timezeros, units, targets, types, as_of,
                                    point_output_type)
  forecasts <- zoltr::do_zoltar_query(zoltar_connection = zoltar_connection, project_url = project_url,
                                      query_type = "forecasts", units = units, timezeros = timezeros, models = models,
                                      targets = targets, types = types, as_of = as_of)
  if (nrow(forecasts) == 0) {  # special case
    data.frame(model_id = character(), timezero = character(), season = character(), unit = character(),
               horizon = character(), target = character(), output_type = character(), output_type_id = character(),
               value = numeric()) |>
      hubUtils::as_model_out_tbl()
  } else {
    zoltar_targets_df <- zoltr::targets(zoltar_connection, project_url)
    format_to_hub_model_output(forecasts, zoltar_targets_df, point_output_type) |>
      hubUtils::as_model_out_tbl()
  }
}


#' @importFrom rlang .data
format_to_hub_model_output <- function(forecasts, zoltar_targets_df, point_output_type) {
  hub_model_outputs <- forecasts |>
    dplyr::left_join(zoltar_targets_df[, c("name", "numeric_horizon")], by = c("target" = "name")) |>
    dplyr::mutate(numeric_value = ifelse(!is.na(.data$value),
                                         stringr::str_detect(.data$value, "[^\\d|\\.]", negate = TRUE),
                                         TRUE),
                  numeric_sample = ifelse(!is.na(sample),
                                          stringr::str_detect(sample, "[^\\d|\\.]", negate = TRUE),
                                          TRUE)) |>
    dplyr::filter(.data$numeric_value, .data$numeric_sample, !class %in% c("named", "mode")) |>
    dplyr::mutate(value = as.numeric(.data$value)) |>
    dplyr::mutate(hub_target = stringr::str_squish(stringr::str_remove(.data$target, paste0(.data$numeric_horizon)))) |>
    dplyr::group_split(class) |>
    purrr::map(.f = function(split_outputs) {
      class <- split_outputs$class[1]
      if (class == "bin") {
        split_outputs |>
          dplyr::mutate(output_type = "pmf", output_type_id = cat, hub_value = as.numeric(.data$prob))
      } else if (class == "point") {
        cli::cli_warn(paste0("Passed query includes `point` forecasts, which do not map cleanly to a hubverse output",
                             " type. They were mapped to {.val {point_output_type}}."))
        split_outputs |>
          dplyr::mutate(output_type = point_output_type, output_type_id = NA, hub_value = .data$value)
      } else if (class %in% c("mean", "median")) {
        split_outputs |>
          dplyr::mutate(output_type = class, output_type_id = NA, hub_value = .data$value)
      } else if (class == "quantile") {
        split_outputs |>
          dplyr::mutate(output_type = "quantile", output_type_id = as.character(.data$quantile),
                        hub_value = .data$value)
      } else if (class == "sample") {
        split_outputs |>
          dplyr::mutate(output_type = "sample", hub_value = suppressWarnings(as.numeric(sample))) |>
          dplyr::group_by(.data$model, .data$timezero, .data$unit, .data$target) |>
          dplyr::mutate(output_type_id = as.character(dplyr::row_number()), .before = .data$hub_value) |>
          dplyr::ungroup()
      }
    }) |>
    purrr::list_rbind() |>
    dplyr::filter(!is.na(.data$hub_value))

  # columns at this point:
  # - model,timezero,season,unit,target,class,value,cat,prob,sample,quantile,family,param1,param2,param3
  # - numeric_horizon
  # - hub_target, output_type, output_type_id, hub_value

  hub_model_outputs[, c("model", "timezero", "season", "unit", "numeric_horizon", "hub_target", "output_type",
                        "output_type_id", "hub_value")] |>
    dplyr::rename(model_id = .data$model, horizon = .data$numeric_horizon, target = .data$hub_target,
                  value = .data$hub_value)
}

validate_arguments <- function(zoltar_connection, project_name, models, timezeros, units, targets, types, as_of,
                               point_output_type = "median") {
  the_projects <- zoltr::projects(zoltar_connection)
  project_url <- the_projects[the_projects$name == project_name, "url"]
  if (length(project_url) == 0) {
    cli::cli_abort("invalid project_name: {.val {project_name}}")
  }

  project_models <- zoltr::models(zoltar_connection = zoltar_connection, project_url = project_url)
  if (!all(models %in% project_models$model_abbr)) {
    # nolint start
    missing_models <- setdiff(models, project_models)
    cli::cli_abort("model{?s} not found in project: {.val {missing_models}}")
    # nolint end
  }

  input_timezeros_as_dates <- lapply(timezeros, FUN = function(x) {
    if (stringr::str_length(x) == 10) {
      as.Date(x, yyyy_mm_dd_date_format)  # NA if invalid format
    } else {
      NA
    }
  })
  if (any(is.na(input_timezeros_as_dates))) {
    cli::cli_abort("one or more invalid timezero formats")
  }

  project_timezeros <- zoltr::timezeros(zoltar_connection = zoltar_connection, project_url = project_url)$timezero_date
  if (!all(timezeros %in% project_timezeros)) {
    # nolint start
    missing_timezeros <- setdiff(timezeros, project_timezeros)
    cli::cli_abort("timezero{?s} not found in project: {.val {missing_timezeros}}")
    # nolint end
  }

  project_units <- zoltr::zoltar_units(zoltar_connection = zoltar_connection, project_url = project_url)$abbreviation
  if (!all(units %in% project_units)) {
    # nolint start
    missing_units <- setdiff(units, project_units)
    cli::cli_abort("unit{?s} not found in project: {.val {missing_units}}")
    # nolint end
  }

  project_targets <- zoltr::targets(zoltar_connection = zoltar_connection, project_url = project_url)$name
  if (!all(targets %in% project_targets)) {
    # nolint start
    missing_targets <- setdiff(targets, project_targets)
    cli::cli_abort("target{?s} not found in project: {.val {missing_targets}}")
    # nolint end
  }

  valid_types <- c("bin", "point", "sample", "quantile", "mean", "median")
  if (!all(types %in% valid_types)) {
    # nolint start
    missing_types <- setdiff(types, valid_types)
    cli::cli_abort("invalid type{?s}: {.val {missing_types}}")
    # nolint end
  }

  tryCatch(
    {
      strftime(as_of, format = "%Y-%m-%d %H:%M:%S", tz = "UTC", usetz = TRUE)
    },
    error = function(e) {  # e.g., Error in as.POSIXlt.character(x, tz = tz)
      cli::cli_abort("invalid as_of")
    }
  )

  if (!point_output_type %in% c("median", "mean")) {
    cli::cli_abort("invalid point_output_type")
  }

  project_url
}
