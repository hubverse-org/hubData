library(mockery)

empty_zoltar_df <- data.frame(model = character(), timezero = character(), season = character(), unit = character(),
                              target = character(), class = character(), value = character(), cat = character(),
                              prob = character(), sample = character(), quantile = character(), family = character(),
                              param1 = character(), param2 = character(), param3 = character())

test_that("test that collect_zoltar() calls validate_arguments()", {
  validate_arguments_mock <- mock()
  mockery::stub(collect_zoltar, "zoltr::zoltar_authenticate", NULL)
  mockery::stub(collect_zoltar, "validate_arguments", validate_arguments_mock)
  mockery::stub(collect_zoltar, "zoltr::do_zoltar_query", empty_zoltar_df)
  suppressWarnings(collect_zoltar("project 1"))
  expect_called(validate_arguments_mock, 1)
})

test_that("test that collect_zoltar() calls do_zoltar_query()", {
  do_zoltar_query_mock <- mock(empty_zoltar_df)
  mockery::stub(collect_zoltar, "zoltr::zoltar_authenticate", NULL)
  mockery::stub(collect_zoltar, "validate_arguments", NULL)
  mockery::stub(collect_zoltar, "zoltr::do_zoltar_query", do_zoltar_query_mock)
  suppressWarnings(collect_zoltar("project 1"))
  expect_called(do_zoltar_query_mock, 1)
})

test_that("test that collect_zoltar() calls format_to_hub_model_output()", {
  one_line_zoltar_df <- data.frame(model = NA, timezero = NA, season = NA, unit = NA, target = NA, class = NA,
                                   value = NA, cat = NA, prob = NA, sample = NA, quantile = NA, family = NA,
                                   param1 = NA, param2 = NA, param3 = NA)
  format_to_hub_model_output_df <-
    data.frame(model_id = character(), timezero = character(), season = character(), unit = character(),
               horizon = character(), target = character(), output_type = character(), output_type_id = character(),
               value = numeric())
  format_to_hub_model_out_mock <- mock(format_to_hub_model_output_df)
  mockery::stub(collect_zoltar, "zoltr::zoltar_authenticate", NULL)
  mockery::stub(collect_zoltar, "validate_arguments", NULL)
  mockery::stub(collect_zoltar, "zoltr::do_zoltar_query", one_line_zoltar_df)
  mockery::stub(collect_zoltar, "format_to_hub_model_output", format_to_hub_model_out_mock)
  mockery::stub(collect_zoltar, "zoltr::targets", NULL)
  suppressWarnings(collect_zoltar("project 1"))
  expect_called(format_to_hub_model_out_mock, 1)
})


#
# test format_to_hub_model_output() output
#

test_that("test that collect_zoltar() correctly handles empty forecasts", {
  mockery::stub(collect_zoltar, "zoltr::zoltar_authenticate", NULL)
  mockery::stub(collect_zoltar, "validate_arguments", NULL)
  mockery::stub(collect_zoltar, "zoltr::do_zoltar_query", empty_zoltar_df)
  act_data_frame <- suppressWarnings(collect_zoltar("project 1"))
  exp_data_frame <- data.frame(model_id = character(), timezero = character(), season = character(), unit = character(),
                               horizon = character(), target = character(), output_type = character(),
                               output_type_id = character(), value = numeric()) |>
    tibble::tibble() |>
    hubUtils::as_model_out_tbl() |>
    suppressWarnings()
  expect_equal(act_data_frame, exp_data_frame)
})

test_that("format_to_hub_model_output() expected output, default point_output_type", {
  zoltar_forecast_csv_file <- "testdata/zoltar_data/zoltar_forecasts.csv"
  zoltar_col_types <- c("character", "Date", "character", "character", "character", "character",
                        NA, NA, NA, NA, NA, NA, NA, NA, NA)  # based on "cDcccc????d????" from zoltr::job_data()
  zoltar_forecasts <- utils::read.csv(zoltar_forecast_csv_file, stringsAsFactors = FALSE,
                                      colClasses = zoltar_col_types)  # "NA" -> NA
  zoltar_forecasts["" == zoltar_forecasts] <- NA  # "" -> NA
  zoltar_targets_df <- data.frame(name = c("1 wk ahead inc case", "above baseline", "pct next week", "season severity",
                                           "Season peak week"),
                                  numeric_horizon = c(1, NA, 1, NA, NA))
  expect_warning(
    act_data_frame <- format_to_hub_model_output(zoltar_forecasts, zoltar_targets_df, point_output_type = "median") |>
      dplyr::arrange(unit, target, output_type, output_type_id, value)
  )

  hub_col_types <- c("character", "Date", "character", "character", "numeric", "character", "character", "character",
                     "numeric")
  exp_data_frame <- utils::read.csv("testdata/zoltar_data/hub_model_output_median.csv", stringsAsFactors = FALSE,
                                    colClasses = hub_col_types) |>  # "NA" -> NA
    dplyr::arrange(unit, target, output_type, output_type_id, value) |>
    tibble::tibble()
  expect_equal(act_data_frame, exp_data_frame)
})

test_that("format_to_hub_model_output() outputs warning for point conversions", {
  zoltar_point_forecast <- data.frame(model = "the-model", timezero = "2022-02-01", season = "2011-2012", unit = "US",
                                      target = "1 wk ahead inc case", class = "point", value = "1.1", cat = NA,
                                      prob = NA, sample = NA, quantile = NA, family = NA, param1 = NA, param2 = NA,
                                      param3 = NA)
  zoltar_targets_df <- data.frame(name = "1 wk ahead inc case", numeric_horizon = 1)
  expect_warning(format_to_hub_model_output(zoltar_point_forecast, zoltar_targets_df, point_output_type = "median"),
                 "Passed query includes `point` forecasts, which do not map cleanly to a hubverse output type.",
                 fixed = TRUE)
})


#
# test collect_zoltar() point_output_type argument
#

# allowing the user to specify a "point_output_type" argument as mean or median so it could be returned with
# output_type based on the user specified value. The default is “median”.
test_that("format_to_hub_model_output() expected output, mean point_output_type", {
  zoltar_forecast_csv_file <- "testdata/zoltar_data/zoltar_forecasts.csv"
  zoltar_col_types <- c("character", "Date", "character", "character", "character", "character",
                        NA, NA, NA, NA, NA, NA, NA, NA, NA)  # based on "cDcccc????d????" from zoltr::job_data()
  zoltar_forecasts <- utils::read.csv(zoltar_forecast_csv_file, stringsAsFactors = FALSE,
                                      colClasses = zoltar_col_types)  # "NA" -> NA
  zoltar_forecasts["" == zoltar_forecasts] <- NA  # "" -> NA
  zoltar_targets_df <- data.frame(name = c("1 wk ahead inc case", "above baseline", "pct next week", "season severity",
                                           "Season peak week"),
                                  numeric_horizon = c(1, NA, 1, NA, NA))

  mockery::stub(collect_zoltar, "zoltr::zoltar_authenticate", NULL)
  mockery::stub(collect_zoltar, "validate_arguments", NULL)
  mockery::stub(collect_zoltar, "zoltr::do_zoltar_query", zoltar_forecasts)
  mockery::stub(collect_zoltar, "zoltr::targets", zoltar_targets_df)

  hub_col_types <- c("character", "Date", "character", "character", "numeric", "character", "character", "character",
                     "numeric")
  exp_data_frame <- utils::read.csv("testdata/zoltar_data/hub_model_output_mean.csv", stringsAsFactors = FALSE,
                                    colClasses = hub_col_types) |>  # "NA" -> NA
    dplyr::arrange(unit, target, output_type, output_type_id, value) |>
    tibble::tibble() |>
    hubUtils::as_model_out_tbl()
  expect_warning(
    act_data_frame <- collect_zoltar("project 1", point_output_type = "mean") |>
      dplyr::arrange(unit, target, output_type, output_type_id, value)
  )
  expect_equal(act_data_frame, exp_data_frame)
})


#
# test validate_arguments() individual conditions
#

# test various cases of extracting horizon from zoltar target names, e.g., "1 wk ahead inc case", "wk 1 ahead inc case",
# "wk ahead inc case 1". document limits (one instance of horizon)
test_that("format_to_hub_model_output() correctly parses target", {
  # cases (input, output):
  # - "1 wk ahead inc case"    ->  "wk ahead inc case"    # supported
  # - "wk ahead inc case 1"    ->  "wk ahead inc case"    # ""
  # - "wk 1 ahead inc case"    ->  "wk ahead inc case"    # ""
  # - "1 wk 1 ahead inc case"  ->  "wk 1 ahead inc case"  # unsupported
  # - "1 wk ahead inc case 1"  ->  "wk ahead inc case 1"  # ""
  zoltar_forecasts <- expand.grid(
    model = "the-model", timezero = "2022-02-01", season = "2011-2012", unit = "US",
    target = c("1 wk ahead inc case", "wk 1 ahead inc case", "wk ahead inc case 1", "1 wk 1 ahead inc case",
               "1 wk ahead inc case 1"),
    class = "mean", value = 10, cat = NA, prob = NA, sample = NA, quantile = NA, family = NA, param1 = NA, param2 = NA,
    param3 = NA, stringsAsFactors = FALSE
  )
  zoltar_targets_df <- data.frame(name = c("1 wk ahead inc case", "wk 1 ahead inc case", "wk ahead inc case 1",
                                           "1 wk 1 ahead inc case", "1 wk ahead inc case 1"),
                                  numeric_horizon = c(1, 1, 1, 1, 1))
  act_data_frame <- format_to_hub_model_output(zoltar_forecasts, zoltar_targets_df, point_output_type = "median")
  exp_data_frame <-
    expand.grid(
      model_id = "the-model", timezero = "2022-02-01", season = "2011-2012", unit = "US", horizon = 1,
      target = c("wk ahead inc case", "wk ahead inc case", "wk ahead inc case", "wk 1 ahead inc case",
                 "wk ahead inc case 1"),
      output_type = "mean", output_type_id = NA, value = 10, stringsAsFactors = FALSE
    ) |>
    tibble::tibble() |>
    hubUtils::as_model_out_tbl()
  attributes(act_data_frame) <- NULL  # due to expand.grid()
  attributes(exp_data_frame) <- NULL  # ""
  expect_equal(act_data_frame, exp_data_frame)
})

test_that("invalid project_name throws error", {
  mockery::stub(validate_arguments, "zoltr::projects",
                data.frame(name = c("project 1", "project 2"),
                           url = c("http://example.com/api/project/1/", "http://example.com/api/project/2/")))
  expect_error(
    validate_arguments(NULL, "bad project", NULL, NULL, NULL, NULL, NULL),
    "invalid project_name", fixed = TRUE
  )
})

test_that("missing model names throws error", {
  mockery::stub(validate_arguments, "zoltr::projects",
                data.frame(name = c("project 1", "project 2"),
                           url = c("http://example.com/api/project/1/", "http://example.com/api/project/2/")))
  mockery::stub(validate_arguments, "zoltr::models", data.frame(model_abbr = c("the-model")))
  expect_error(
    validate_arguments(NULL, "project 1", c("the-model", "bad-model"), NULL, NULL, NULL, NULL, NULL),
    regexp = "model not found in project", fixed = TRUE
  )
})

test_that("invalid timezero format throws an error", {
  mockery::stub(validate_arguments, "zoltr::projects",
                data.frame(name = c("project 1", "project 2"),
                           url = c("http://example.com/api/project/1/", "http://example.com/api/project/2/")))
  mockery::stub(validate_arguments, "zoltr::models", data.frame(model_abbr = c("the-model")))
  expect_error(
    validate_arguments(NULL, "project 1", "the-model", "2022-02-01x", NULL, NULL, NULL, NULL),
    "one or more invalid timezero formats", fixed = TRUE
  )
})

test_that("missing timezero throws an error", {
  mockery::stub(validate_arguments, "zoltr::projects",
                data.frame(name = c("project 1", "project 2"),
                           url = c("http://example.com/api/project/1/", "http://example.com/api/project/2/")))
  mockery::stub(validate_arguments, "zoltr::models", data.frame(model_abbr = c("the-model")))
  mockery::stub(validate_arguments, "zoltr::timezeros", data.frame(timezero_date = c("2022-02-01")))
  expect_error(
    validate_arguments(NULL, "project 1", "the-model", "2022-02-02", NULL, NULL, NULL, NULL),
    "timezero not found in project", fixed = TRUE
  )
})

test_that("missing unit throws an error", {
  mockery::stub(validate_arguments, "zoltr::projects",
                data.frame(name = c("project 1", "project 2"),
                           url = c("http://example.com/api/project/1/", "http://example.com/api/project/2/")))
  mockery::stub(validate_arguments, "zoltr::models", data.frame(model_abbr = c("the-model")))
  mockery::stub(validate_arguments, "zoltr::timezeros", data.frame(timezero_date = c("2022-02-01")))
  mockery::stub(validate_arguments, "zoltr::zoltar_units", data.frame(abbreviation = c("US")))
  expect_error(
    validate_arguments(NULL, "project 1", "the-model", "2022-02-01", "00", NULL, NULL, NULL),
    "unit not found in project", fixed = TRUE
  )
})

test_that("missing target throws an error", {
  mockery::stub(validate_arguments, "zoltr::projects",
                data.frame(name = c("project 1", "project 2"),
                           url = c("http://example.com/api/project/1/", "http://example.com/api/project/2/")))
  mockery::stub(validate_arguments, "zoltr::models", data.frame(model_abbr = c("the-model")))
  mockery::stub(validate_arguments, "zoltr::timezeros", data.frame(timezero_date = c("2022-02-01")))
  mockery::stub(validate_arguments, "zoltr::zoltar_units", data.frame(abbreviation = c("US")))
  mockery::stub(validate_arguments, "zoltr::targets", data.frame(name = c("1 wk ahead inc death")))
  expect_error(
    validate_arguments(NULL, "project 1", "the-model", "2022-02-01", "US",
                       "bad target", NULL, NULL),
    "target not found in project", fixed = TRUE
  )
})

test_that("invalid type throws an error", {
  mockery::stub(validate_arguments, "zoltr::projects",
                data.frame(name = c("project 1", "project 2"),
                           url = c("http://example.com/api/project/1/", "http://example.com/api/project/2/")))
  mockery::stub(validate_arguments, "zoltr::models", data.frame(model_abbr = c("the-model")))
  mockery::stub(validate_arguments, "zoltr::timezeros", data.frame(timezero_date = c("2022-02-01")))
  mockery::stub(validate_arguments, "zoltr::zoltar_units", data.frame(abbreviation = c("US")))
  mockery::stub(validate_arguments, "zoltr::targets", data.frame(name = c("1 wk ahead inc death")))
  expect_error(
    validate_arguments(NULL, "project 1", "the-model", "2022-02-01", "US",
                       "1 wk ahead inc death", "bad type", NULL),
    "invalid type", fixed = TRUE
  )
})

test_that("invalid as_of throws an error", {
  mockery::stub(validate_arguments, "zoltr::projects",
                data.frame(name = c("project 1", "project 2"),
                           url = c("http://example.com/api/project/1/", "http://example.com/api/project/2/")))
  mockery::stub(validate_arguments, "zoltr::models", data.frame(model_abbr = c("the-model")))
  mockery::stub(validate_arguments, "zoltr::timezeros", data.frame(timezero_date = c("2022-02-01")))
  mockery::stub(validate_arguments, "zoltr::zoltar_units", data.frame(abbreviation = c("US")))
  mockery::stub(validate_arguments, "zoltr::targets", data.frame(name = c("1 wk ahead inc death")))
  expect_error(
    validate_arguments(NULL, "project 1", "the-model", "2022-02-01", "US",
                       "1 wk ahead inc death", "bin", "2021-05-x10 12:00 UTC"),
    "invalid as_of", fixed = TRUE
  )
})

test_that("invalid point_output_type throws an error", {
  mockery::stub(validate_arguments, "zoltr::projects",
                data.frame(name = c("project 1", "project 2"),
                           url = c("http://example.com/api/project/1/", "http://example.com/api/project/2/")))
  mockery::stub(validate_arguments, "zoltr::models", data.frame(model_abbr = c("the-model")))
  mockery::stub(validate_arguments, "zoltr::timezeros", data.frame(timezero_date = c("2022-02-01")))
  mockery::stub(validate_arguments, "zoltr::zoltar_units", data.frame(abbreviation = c("US")))
  mockery::stub(validate_arguments, "zoltr::targets", data.frame(name = c("1 wk ahead inc death")))

  # case: valid: "median"
  expect_no_error(
    validate_arguments(NULL, "project 1", "the-model", "2022-02-01", "US",
                       "1 wk ahead inc death", "bin", "2021-05-10 12:00 UTC", "median")
  )

  # case: valid: "mean"
  expect_no_error(
    validate_arguments(NULL, "project 1", "the-model", "2022-02-01", "US",
                       "1 wk ahead inc death", "bin", "2021-05-10 12:00 UTC", "mean")
  )

  # case: invalid
  expect_error(
    validate_arguments(NULL, "project 1", "the-model", "2022-02-01", "US",
                       "1 wk ahead inc death", "bin", "2021-05-10 12:00 UTC", "neither median nor mean"),
    "invalid point_output_type", fixed = TRUE
  )
})

test_that("NULL args does not throw error", {
  mockery::stub(validate_arguments, "zoltr::projects",
                data.frame(name = c("project 1", "project 2"),
                           url = c("http://example.com/api/project/1/", "http://example.com/api/project/2/")))
  mockery::stub(validate_arguments, "zoltr::models", data.frame(model_abbr = c("the-model")))
  mockery::stub(validate_arguments, "zoltr::timezeros", data.frame(timezero_date = c("2022-02-01")))
  mockery::stub(validate_arguments, "zoltr::zoltar_units", data.frame(abbreviation = c("US")))
  mockery::stub(validate_arguments, "zoltr::targets", data.frame(name = c("1 wk ahead inc death")))

  # models
  expect_no_error(
    validate_arguments(NULL, "project 1", NULL, "2022-02-01", "US",
                       "1 wk ahead inc death", "bin", "2021-05-10 12:00 UTC")
  )

  # timezeros
  expect_no_error(
    validate_arguments(NULL, "project 1", "the-model", NULL, "US",
                       "1 wk ahead inc death", "bin", "2021-05-10 12:00 UTC")
  )

  # units
  expect_no_error(
    validate_arguments(NULL, "project 1", "the-model", "2022-02-01", NULL,
                       "1 wk ahead inc death", "bin", "2021-05-10 12:00 UTC")
  )

  # targets
  expect_no_error(
    validate_arguments(NULL, "project 1", "the-model", "2022-02-01", "US",
                       NULL, "bin", "2021-05-10 12:00 UTC")
  )

  # types
  expect_no_error(
    validate_arguments(NULL, "project 1", "the-model", "2022-02-01", "US",
                       "1 wk ahead inc death", NULL, "2021-05-10 12:00 UTC")
  )

  # as_of
  expect_no_error(
    validate_arguments(NULL, "project 1", "the-model", "2022-02-01", "US",
                       "1 wk ahead inc death", "bin", NULL)
  )
})
