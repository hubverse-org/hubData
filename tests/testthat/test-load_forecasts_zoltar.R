library(mockery)

empty_zoltar_df <- data.frame(model = character(), timezero = character(), season = character(), unit = character(),
                              target = character(), class = character(), value = character(), cat = character(),
                              prob = character(), sample = character(), quantile = character(), family = character(),
                              param1 = character(), param2 = character(), param3 = character())

test_that("test that load_forecasts_zoltar() calls validate_arguments()", {
  validate_arguments_mock <- mock()
  mockery::stub(load_forecasts_zoltar, 'zoltr::zoltar_authenticate', NULL)
  mockery::stub(load_forecasts_zoltar, "validate_arguments", validate_arguments_mock)
  mockery::stub(load_forecasts_zoltar, "zoltr::do_zoltar_query", empty_zoltar_df)
  load_forecasts_zoltar("project 1")
  expect_called(validate_arguments_mock, 1)
})

test_that("test that load_forecasts_zoltar() calls do_zoltar_query()", {
  do_zoltar_query_mock <- mock(empty_zoltar_df)
  mockery::stub(load_forecasts_zoltar, 'zoltr::zoltar_authenticate', NULL)
  mockery::stub(load_forecasts_zoltar, "validate_arguments", NULL)
  mockery::stub(load_forecasts_zoltar, "zoltr::do_zoltar_query", do_zoltar_query_mock)
  load_forecasts_zoltar("project 1")
  expect_called(do_zoltar_query_mock, 1)
})

test_that("test that load_forecasts_zoltar() calls format_to_hub_model_output()", {
  one_line_zoltar_df <- data.frame(model = NA, timezero = NA, season = NA, unit = NA, target = NA, class = NA,
                                   value = NA, cat = NA, prob = NA, sample = NA, quantile = NA, family = NA,
                                   param1 = NA, param2 = NA, param3 = NA)
  format_to_hub_model_output_mock <- mock()
  mockery::stub(load_forecasts_zoltar, 'zoltr::zoltar_authenticate', NULL)
  mockery::stub(load_forecasts_zoltar, "validate_arguments", NULL)
  mockery::stub(load_forecasts_zoltar, "zoltr::do_zoltar_query", one_line_zoltar_df)
  mockery::stub(load_forecasts_zoltar, "format_to_hub_model_output", format_to_hub_model_output_mock)
  mockery::stub(load_forecasts_zoltar, 'zoltr::targets', NULL)
  load_forecasts_zoltar("project 1")
  expect_called(format_to_hub_model_output_mock, 1)
})


#
# test format_to_hub_model_output() individual output conditions
#

test_that("test that load_forecasts_zoltar() correctly handles empty forecasts", {
  format_to_hub_model_output_mock <- mock()
  mockery::stub(load_forecasts_zoltar, 'zoltr::zoltar_authenticate', NULL)
  mockery::stub(load_forecasts_zoltar, "validate_arguments", NULL)
  mockery::stub(load_forecasts_zoltar, "zoltr::do_zoltar_query", empty_zoltar_df)
  act_data_frame <- load_forecasts_zoltar("project 1")
  exp_data_frame <- data.frame(model_id = character(), timezero = character(), season = character(), unit = character(),
                               horizon = character(), target = character(), output_type = character(),
                               output_type_id = character(), value = character())
  expect_equal(act_data_frame, exp_data_frame)
})

test_that("format_to_hub_model_output() expected output", {
  zoltar_forecast_csv_file <- "testdata/zoltar_data/zoltar_forecasts.csv"
  zoltar_forecasts <- utils::read.csv(zoltar_forecast_csv_file, stringsAsFactors = FALSE, colClasses = 'character')  # "NA" -> NA
  zoltar_forecasts["" == zoltar_forecasts] <- NA  # "" -> NA
  zoltar_targets_df <- data.frame(name = c("1 wk ahead inc case", "above baseline", "pct next week", "season severity", "Season peak week"),
                                  numeric_horizon = c(1, NA, 1, NA, NA))
  act_data_frame <- format_to_hub_model_output(zoltar_forecasts, zoltar_targets_df) |>
    dplyr::arrange(target, output_type, output_type_id, value)
  exp_data_frame <- utils::read.csv("testdata/zoltar_data/hub_model_output.csv", stringsAsFactors = FALSE,
                                    colClasses = 'character') |>  # "NA" -> NA
    dplyr::arrange(target, output_type, output_type_id, value) |>
    dplyr::mutate(horizon = as.numeric(horizon)) |>
    tibble()
  View(act_data_frame)
  View(exp_data_frame)
  expect_equal(act_data_frame, exp_data_frame)
})


# todo: test these cases:
# adding a warning whenever "points" are extracted from Zoltar. e.g. "The query you passed includes point forecasts which do not map cleanly to a hubverse output type."
# allowing the user to specify a "point_output_type" argument as mean or median so it could be returned with output_type based on the user specified value.
# test various cases of extracting horizon from zoltar target names, e.g., "1 wk ahead inc case", "wk 1 ahead inc case", "wk ahead inc case 1". document limits (one instance of horizon)

#
# test validate_arguments() individual conditions
#

test_that("invalid project_name throws error", {
  mockery::stub(validate_arguments, 'zoltr::projects',
                data.frame(name = c("project 1", "project 2"),
                           url = c("http://example.com/api/project/1/", "http://example.com/api/project/2/")))
  expect_error(
    validate_arguments(NULL, "bad project", NULL, NULL, NULL, NULL, NULL),
    "invalid project_name", fixed = TRUE
  )
})

test_that("missing model names throws error", {
  mockery::stub(validate_arguments, 'zoltr::projects',
                data.frame(name = c("project 1", "project 2"),
                           url = c("http://example.com/api/project/1/", "http://example.com/api/project/2/")))
  mockery::stub(validate_arguments, 'zoltr::models', "the-model")
  expect_error(
    validate_arguments(NULL, "project 1", c("the-model", "bad-model"), NULL, NULL, NULL, NULL, NULL),
    regexp = "model(s) not found in project", fixed = TRUE
  )
})

test_that("invalid timezero format throws an error", {
  mockery::stub(validate_arguments, 'zoltr::projects',
                data.frame(name = c("project 1", "project 2"),
                           url = c("http://example.com/api/project/1/", "http://example.com/api/project/2/")))
  mockery::stub(validate_arguments, 'zoltr::models', "the-model")
  expect_error(
    validate_arguments(NULL, "project 1", "the-model", "2022-02-01x", NULL, NULL, NULL, NULL),
    "one or more invalid timezero formats", fixed = TRUE
  )
})

test_that("missing timezero throws an error", {
  mockery::stub(validate_arguments, 'zoltr::projects',
                data.frame(name = c("project 1", "project 2"),
                           url = c("http://example.com/api/project/1/", "http://example.com/api/project/2/")))
  mockery::stub(validate_arguments, 'zoltr::models', "the-model")
  mockery::stub(validate_arguments, 'zoltr::timezeros', data.frame(timezero_date = c("2022-02-01")))
  expect_error(
    validate_arguments(NULL, "project 1", "the-model", "2022-02-02", NULL, NULL, NULL, NULL),
    "timezero(s) not found in project", fixed = TRUE
  )
})

test_that("missing unit throws an error", {
  mockery::stub(validate_arguments, 'zoltr::projects',
                data.frame(name = c("project 1", "project 2"),
                           url = c("http://example.com/api/project/1/", "http://example.com/api/project/2/")))
  mockery::stub(validate_arguments, 'zoltr::models', "the-model")
  mockery::stub(validate_arguments, 'zoltr::timezeros', data.frame(timezero_date = c("2022-02-01")))
  mockery::stub(validate_arguments, 'zoltr::zoltar_units', data.frame(name = c("US")))
  expect_error(
    validate_arguments(NULL, "project 1", "the-model", "2022-02-01", "00", NULL, NULL, NULL),
    "unit(s) not found in project", fixed = TRUE
  )
})

test_that("missing target throws an error", {
  mockery::stub(validate_arguments, 'zoltr::projects',
                data.frame(name = c("project 1", "project 2"),
                           url = c("http://example.com/api/project/1/", "http://example.com/api/project/2/")))
  mockery::stub(validate_arguments, 'zoltr::models', "the-model")
  mockery::stub(validate_arguments, 'zoltr::timezeros', data.frame(timezero_date = c("2022-02-01")))
  mockery::stub(validate_arguments, 'zoltr::zoltar_units', data.frame(name = c("US")))
  mockery::stub(validate_arguments, 'zoltr::targets', data.frame(name = c("1 wk ahead inc death")))
  expect_error(
    validate_arguments(NULL, "project 1", "the-model", "2022-02-01", "US",
                       "bad target", NULL, NULL),
    "target(s) not found in project", fixed = TRUE
  )
})

test_that("invalid type throws an error", {
  mockery::stub(validate_arguments, 'zoltr::projects',
                data.frame(name = c("project 1", "project 2"),
                           url = c("http://example.com/api/project/1/", "http://example.com/api/project/2/")))
  mockery::stub(validate_arguments, 'zoltr::models', "the-model")
  mockery::stub(validate_arguments, 'zoltr::timezeros', data.frame(timezero_date = c("2022-02-01")))
  mockery::stub(validate_arguments, 'zoltr::zoltar_units', data.frame(name = c("US")))
  mockery::stub(validate_arguments, 'zoltr::targets', data.frame(name = c("1 wk ahead inc death")))
  expect_error(
    validate_arguments(NULL, "project 1", "the-model", "2022-02-01", "US",
                       "1 wk ahead inc death", "bad type", NULL),
    "invalid type(s)", fixed = TRUE
  )
})

test_that("invalid as_of throws an error", {
  mockery::stub(validate_arguments, 'zoltr::projects',
                data.frame(name = c("project 1", "project 2"),
                           url = c("http://example.com/api/project/1/", "http://example.com/api/project/2/")))
  mockery::stub(validate_arguments, 'zoltr::models', "the-model")
  mockery::stub(validate_arguments, 'zoltr::timezeros', data.frame(timezero_date = c("2022-02-01")))
  mockery::stub(validate_arguments, 'zoltr::zoltar_units', data.frame(name = c("US")))
  mockery::stub(validate_arguments, 'zoltr::targets', data.frame(name = c("1 wk ahead inc death")))
  expect_error(
    validate_arguments(NULL, "project 1", "the-model", "2022-02-01", "US",
                       "1 wk ahead inc death", "bin", "2021-05-x10 12:00 UTC"),
    "invalid as_of", fixed = TRUE
  )
})

test_that("NULL args does not throw error", {
  mockery::stub(validate_arguments, 'zoltr::projects',
                data.frame(name = c("project 1", "project 2"),
                           url = c("http://example.com/api/project/1/", "http://example.com/api/project/2/")))
  mockery::stub(validate_arguments, 'zoltr::models', "the-model")
  mockery::stub(validate_arguments, 'zoltr::timezeros', data.frame(timezero_date = c("2022-02-01")))
  mockery::stub(validate_arguments, 'zoltr::zoltar_units', data.frame(name = c("US")))
  mockery::stub(validate_arguments, 'zoltr::targets', data.frame(name = c("1 wk ahead inc death")))

  # models
  expect_no_error(
    validate_arguments(NULL, "project 1", NULL, "2022-02-01", "US",
                       "1 wk ahead inc death", "bin", "2021-05-10 12:00 UTC"))

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
