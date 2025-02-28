test_that("create_timeseries_schema works", {
  skip_if_offline()
  tmp_hub_path <- withr::local_tempdir()
  example_hub <- "https://github.com/hubverse-org/example-complex-forecast-hub.git"
  git2r::clone(url = example_hub, local_path = tmp_hub_path, progress = FALSE)
  # Create target time-series schema
  test_schema <- create_timeseries_schema(tmp_hub_path)

  expect_equal(
    test_schema$ToString(),
    "date: date32[day]\ntarget: string\nlocation: string\nobservation: double"
  )

  # Create target time-series schema with as_of column and test schema create successfully
  ts_path <- validate_target_data_path(tmp_hub_path)
  arrow::read_csv_arrow(ts_path) |>
    dplyr::mutate(as_of = "2025-02-28") |>
    arrow::write_csv_arrow(ts_path)

  test_as_of_schema <- create_timeseries_schema(tmp_hub_path)

  expect_equal(
    test_as_of_schema$ToString(),
    "date: date32[day]\ntarget: string\nlocation: string\nobservation: double\nas_of: date32[day]"
  )
  expect_equal(
    test_as_of_schema$as_of$type$ToString(),
    "date32[day]"
  )
})
