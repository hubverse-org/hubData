YYYY_MM_DD_DATE_FORMAT <- '%Y-%m-%d'  # e.g., '2017-01-17'


# todo docs
#
# project_name (character): name of the Zoltar project hosting the hub's data. assumes hosted at zoltardata.com
# models (character vector): which models to query. pass model abbreviations
# timezeros (character vector): which timezeroes to query. pass as dates in yyyy-mm-dd format
# units (character vector): which units to query. pass unit abbreviations
# targets (character vector): which targets to query. pass target names
# types (character vector): which forecast types to query. Choices are bin, named, point, sample, quantile, mean, median, and mode.
# as_of (character): datetime to load forecasts submitted as of this time (i.e., forecast version). It could use the format of one of the three examples: "2021-01-01", "2020-01-01 01:01:01" and "2020-01-01 01:01:01 UTC". If you would like to set a timezone, it has to be UTC now. If not, a helper function will append the default timezone to your input based on hub parameter. Default to NULL to load the latest version.
#
# notes:
# - requires Z_USERNAME and Z_PASSWORD environment vars
# - unsupported zoltar types: "named", "mode"
# - as_of: the datatime eparsing function used below is extremely lenient when it comes to formatting, so please exercise caution
# ...
load_forecasts_zoltar <- function(project_name, models = NULL, timezeros = NULL, units = NULL, targets = NULL,
                                  types = NULL, as_of = NULL) {
  zoltar_connection <- zoltr::new_connection()
  zoltr::zoltar_authenticate(zoltar_connection, Sys.getenv("Z_USERNAME"), Sys.getenv("Z_PASSWORD"))

  project_url <- validate_arguments(zoltar_connection, project_name, models, timezeros, units, targets, types, as_of)
  forecasts <- zoltr::do_zoltar_query(zoltar_connection = zoltar_connection, project_url = project_url,
                                      query_type = "forecasts", units = units, timezeros = timezeros, models = models,
                                      targets = targets, types = types, as_of = as_of)
  if (nrow(forecasts) == 0) {  # special case
    data.frame(model_id = character(), timezero = character(), season = character(), unit = character(),
               horizon = character(), target = character(), output_type = character(), output_type_id = character(),
               value = character())
  } else {
    zoltar_targets_df <- zoltr::targets(zoltar_connection, project_url)
    format_to_hub_model_output(forecasts, zoltar_targets_df)
  }
}

format_to_hub_model_output <- function(forecasts, zoltar_targets_df) {
  # todo:
  # - document kinds of zoltar target names we support. e.g., only one instance of numeric_horizon in target name
  # - require stringr package

  # zoltar_targets_df: data.frame(id, url, name, type, description, outcome_variable, is_step_ahead, numeric_horizon, reference_date_type)
  hub_model_outputs <- forecasts |>
    dplyr::left_join(dplyr::select(zoltar_targets_df, name, numeric_horizon), by = c("target" = "name")) |>
    dplyr::filter(!class %in% c("named", "mode")) |>
    dplyr::mutate(hub_target = stringr::str_replace(target, paste0("\\s*\\b", numeric_horizon, "\\s*\\b"), "")) |>
    dplyr::group_split(class) |>
    purrr::map_dfr(.f = function(split_outputs) {
      class <- split_outputs$class[1]
      if (class == "bin") {
        split_outputs |>
          dplyr::mutate(output_type = "pmf", output_type_id = cat, hub_value = prob)
      } else if (class == "point") {  # todo xx use "point_output_type"
        split_outputs |>
          dplyr::mutate(output_type = "median", output_type_id = NA, hub_value = value)
      } else if (class %in% c("mean", "median")) {
        split_outputs |>
          dplyr::mutate(output_type = class, output_type_id = NA, hub_value = value)
      } else if (class == "quantile") {
        split_outputs |>
          dplyr::mutate(output_type = "quantile", output_type_id = quantile, hub_value = value)
      } else if (class == "sample") {
        split_outputs |>
          dplyr::mutate(output_type = "sample", hub_value = sample) |>
          dplyr::group_by(model, timezero, unit, target) |>
          dplyr::mutate(output_type_id = as.character(dplyr::row_number()), .before = hub_value) |>
          dplyr::ungroup()
      }
    })

  # columns at this point:
  # - model,timezero,season,unit,target,class,value,cat,prob,sample,quantile,family,param1,param2,param3
  # - numeric_horizon
  # - hub_target, output_type, output_type_id, hub_value

  hub_model_outputs |>
    dplyr::select(model, timezero, season, unit, numeric_horizon, hub_target, output_type, output_type_id, hub_value) |>
    dplyr::rename(model_id = model, horizon = numeric_horizon, target = hub_target, value = hub_value)
}

# todo docs
# return: project_url
validate_arguments <- function(zoltar_connection, project_name, models, timezeros, units, targets, types, as_of) {
  the_projects <- zoltr::projects(zoltar_connection)
  project_url <- the_projects[the_projects$name == project_name, "url"]
  if (length(project_url) == 0) {
    cli::cli_abort("invalid project_name: {.val {project_name}}")
  }

  project_models <- zoltr::models(zoltar_connection = zoltar_connection, project_url = project_url)
  if (!all(models %in% project_models)) {
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

  project_units <- zoltr::zoltar_units(zoltar_connection = zoltar_connection, project_url = project_url)
  if (!all(units %in% project_units)) {
    missing_units <- setdiff(units, project_units)
    cli::cli_abort("unit(s) not found in project: {.val {missing_units}}")
  }

  project_targets <- zoltr::targets(zoltar_connection = zoltar_connection, project_url = project_url)
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

  project_url
}