test_that("create_timeseries_schema works", {
  skip_if_offline()
  tmp_hub_path <- withr::local_tempdir()
  example_hub <- "https://github.com/hubverse-org/example-complex-forecast-hub.git"
  gert::git_clone(url = example_hub, path = tmp_hub_path)
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

  # Create target time-series schema partitioned on the date column which is not
  # a date task ID. date_col needs to be specified for schema to be created successfully.
  ts_dir <- fs::path(tmp_hub_path, "target-data", "time-series")
  fs::dir_create(ts_dir)
  ts_dat <- arrow::read_csv_arrow(ts_path)
  arrow::write_dataset(ts_dat, ts_dir, partitioning = "date", format = "parquet")
  fs::file_delete(ts_path)

  expect_error(
    create_timeseries_schema(tmp_hub_path),
    "No .*date.* type column found in .*time-series.*."
  )
  expect_equal(
    create_timeseries_schema(tmp_hub_path, date_col = "date")$ToString(),
    "target: string\nlocation: string\nobservation: double\nas_of: date32[day]\ndate: date32[day]"
  )

  # Create target time-series schema partitioned on a target_end_date column. As this is
  # a valid date task ID, schema should be created successfully without specifying date_col.
  fs::dir_delete(ts_dir)
  fs::dir_create(ts_dir)
  ts_dat |>
    dplyr::rename(target_end_date = date) |>
    arrow::write_dataset(ts_dir, partitioning = "target_end_date", format = "parquet")

  expect_equal(
    create_timeseries_schema(tmp_hub_path)$ToString(),
    "target: string\nlocation: string\nobservation: double\nas_of: date32[day]\ntarget_end_date: date32[day]"
  )
})

test_that(
  "create_timeseries_schema works on single-file S3 SubTreeFileSystem hub",
  {
    skip_if_offline()
    hub_path <- s3_bucket("example-complex-forecast-hub")
    ts_schema <- create_timeseries_schema(hub_path)

    expect_equal(
      ts_schema$ToString(),
      "date: date32[day]\ntarget: string\nlocation: string\nobservation: double"
    )
  }
)
