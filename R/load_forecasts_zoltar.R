YYYY_MM_DD_DATE_FORMAT <- '%Y-%m-%d'  # e.g., '2017-01-17'

#' Load forecasts from zoltardata.com in hubverse format
#'
#' @param project_name a string naming the Zoltar project to load forecasts from. assumes the host is zoltardata.com
#' @param models a character vector that specifies the models to query. must be model abbreviations. defaults to NULL,
#'   which queries all models in the project
#' @param timezeros a character vector that specifies the timezeros to query. must be yyyy-mm-dd format. defaults to
#'   NULL, which queries all timezeros in the project
#' @param units a character vector that specifies the units to query. must be unit abbreviations. defaults to NULL,
#'   which queries all units in the project
#' @param targets a character vector that specifies the targets to query. must be target names. defaults to NULL,
#'   which queries all targets in the project
#' @param types a character vector that specifies the forecast types to query. Choices are "bin", "point", "sample",
#'   "quantile", "mean", and "median". defaults to NULL, which queries all types in the project. note: while Zoltar
#'   supports "named" and "mode" forecasts, this function ignores them
#' @param as_of a datetime string that specifies the forecast version. The as_of field format must be a datetime as
#'   parsed by the \href{https://dateutil.readthedocs.io/}{dateutil python library}, which accepts a variety of styles.
#'   You can find examples \href{https://dateutil.readthedocs.io/en/stable/examples.html#parse-examples}{here}.
#'   importantly, the datetime must include timezone information for disambiguation, without which the query will fail.
#'   also, the datatime parsing function used below is extremely lenient when it comes to formatting, so please exercise
#'   caution. defaults to NULL to load the latest version
#' @param point_output_type a string that specifies how to convert zoltar `point` forecast data to hubverse output type.
#'   must be either "median" or "mean". defaults to "median"
#'
#' @details
#'   notes:
#'     - requires Z_USERNAME and Z_PASSWORD environment vars
#'     - while Zoltar supports "named" and "mode" forecasts, this function ignores them
#'     - rows with non-numeric values are ignored
#'     - this function removes numeric_horizon mentions from zoltar target names. target names can contain a maximum of
#'       one numeric_horizon. example: "1 wk ahead inc case" -> "wk ahead inc case"
#'
#' @return a hubverse model_out_tbl containing the following columns: "model_id", "timezero", "season", "unit",
#'   "horizon", "target", "output_type", "output_type_id", and "value"
#' @export
#'
#' @examples
#' df <- load_forecasts_zoltar("Docs Example Project")
#' df <-
#'   load_forecasts_zoltar("Docs Example Project", models = c("docs_mod"), timezeros = c("2011-10-16"),
#'                         units = c("loc1", "loc3"), targets = c("pct next week", "cases next week"),
#'                         types = c("point"), as_of = NULL, point_output_type = "mean")
load_forecasts_zoltar <- function(project_name, models = NULL, timezeros = NULL, units = NULL, targets = NULL,
                                  types = NULL, as_of = NULL, point_output_type = "median") {
  zoltar_connection <- zoltr::new_connection()
  zoltr::zoltar_authenticate(zoltar_connection, Sys.getenv("Z_USERNAME"), Sys.getenv("Z_PASSWORD"))

  project_url <- validate_arguments(zoltar_connection, project_name, models, timezeros, units, targets, types, as_of, point_output_type)
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

format_to_hub_model_output <- function(forecasts, zoltar_targets_df, point_output_type) {
  hub_model_outputs <- forecasts |>
    dplyr::left_join(dplyr::select(zoltar_targets_df, name, numeric_horizon), by = c("target" = "name")) |>
    dplyr::mutate(numeric_value = ifelse(!is.na(value), stringr::str_detect(value, "[^\\d|\\.]", negate = TRUE), TRUE),
                  numeric_sample = ifelse(!is.na(sample), stringr::str_detect(sample, "[^\\d|\\.]", negate = TRUE), TRUE)) |>
    dplyr::filter(numeric_value, numeric_sample, !class %in% c("named", "mode")) |>
    dplyr::mutate(value = as.numeric(value)) |>
    dplyr::mutate(hub_target = stringr::str_squish(stringr::str_remove(target, paste0(numeric_horizon)))) |>
    dplyr::group_split(class) |>
    purrr::map_dfr(.f = function(split_outputs) {
      class <- split_outputs$class[1]
      if (class == "bin") {
        split_outputs |>
          dplyr::mutate(output_type = "pmf", output_type_id = cat, hub_value = as.numeric(prob))
      } else if (class == "point") {
        cli::cli_warn(paste0("Passed query includes `point` forecasts, which do not map cleanly to a hubverse output",
                             " type. They were mapped to {.val {point_output_type}}."))
        split_outputs |>
          dplyr::mutate(output_type = point_output_type, output_type_id = NA, hub_value = value)
      } else if (class %in% c("mean", "median")) {
        split_outputs |>
          dplyr::mutate(output_type = class, output_type_id = NA, hub_value = value)
      } else if (class == "quantile") {
        split_outputs |>
          dplyr::mutate(output_type = "quantile", output_type_id = as.character(quantile), hub_value = value)
      } else if (class == "sample") {
        split_outputs |>
          dplyr::mutate(output_type = "sample", hub_value = suppressWarnings(as.numeric(sample))) |>
          dplyr::group_by(model, timezero, unit, target) |>
          dplyr::mutate(output_type_id = as.character(dplyr::row_number()), .before = hub_value) |>
          dplyr::ungroup()
      }
    }) |>
    dplyr::filter(!is.na(hub_value))

  # columns at this point:
  # - model,timezero,season,unit,target,class,value,cat,prob,sample,quantile,family,param1,param2,param3
  # - numeric_horizon
  # - hub_target, output_type, output_type_id, hub_value

  hub_model_outputs |>
    dplyr::select(model, timezero, season, unit, numeric_horizon, hub_target, output_type, output_type_id, hub_value) |>
    dplyr::rename(model_id = model, horizon = numeric_horizon, target = hub_target, value = hub_value)
}

validate_arguments <- function(zoltar_connection, project_name, models, timezeros, units, targets, types, as_of, point_output_type = "median") {
  the_projects <- zoltr::projects(zoltar_connection)
  project_url <- the_projects[the_projects$name == project_name, "url"]
  if (length(project_url) == 0) {
    cli::cli_abort("invalid project_name: {.val {project_name}}")
  }

  project_models <- zoltr::models(zoltar_connection = zoltar_connection, project_url = project_url)
  if (!all(models %in% project_models$model_abbr)) {
    missing_models <- setdiff(models, project_models)
    cli::cli_abort("model(s) not found in project: {.val {missing_models}}")
  }

  input_timezeros_as_dates <- lapply(timezeros, FUN = function(x) {
    if (stringr::str_length(x) == 10) {
      as.Date(x, YYYY_MM_DD_DATE_FORMAT)  # NA if invalid format
    } else { NA }
  })
  if (any(is.na(input_timezeros_as_dates))) {
    cli::cli_abort("one or more invalid timezero formats")
  }

  project_timezeros <- zoltr::timezeros(zoltar_connection = zoltar_connection, project_url = project_url)$timezero_date
  if (!all(timezeros %in% project_timezeros)) {
    missing_timezeros <- setdiff(timezeros, project_timezeros)
    cli::cli_abort("timezero(s) not found in project: {.val {missing_timezeros}}")
  }

  project_units <- zoltr::zoltar_units(zoltar_connection = zoltar_connection, project_url = project_url)$abbreviation
  if (!all(units %in% project_units)) {
    missing_units <- setdiff(units, project_units)
    cli::cli_abort("unit(s) not found in project: {.val {missing_units}}")
  }

  project_targets <- zoltr::targets(zoltar_connection = zoltar_connection, project_url = project_url)$name
  if (!all(targets %in% project_targets)) {
    missing_targets <- setdiff(targets, project_targets)
    cli::cli_abort("target(s) not found in project: {.val {missing_targets}}")
  }

  valid_types <- c("bin", "point", "sample", "quantile", "mean", "median")
  if (!all(types %in% valid_types)) {
    missing_types <- setdiff(types, valid_types)
    cli::cli_abort("invalid type(s): {.val {missing_types}}")
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
