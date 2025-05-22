test_that("create_oracle_output_schema works", {
  skip_if_offline()
  tmp_hub_path <- withr::local_tempdir()
  example_hub <- "https://github.com/hubverse-org/example-complex-forecast-hub.git"
  gert::git_clone(url = example_hub, path = tmp_hub_path)
  # Create target oracle-output schema
  test_schema <- create_oracle_output_schema(tmp_hub_path)

  expect_equal(
    test_schema$ToString(),
    "location: string\ntarget_end_date: date32[day]\ntarget: string\noutput_type: string\noutput_type_id: string\noracle_value: double" # nolint: line_length_linter
  )

  # Create target oracle-output schema partitioned on a target_end_date column. As this is
  # a valid date task ID, schema should be created successfully without specifying date_col.
  oo_path <- validate_target_data_path(tmp_hub_path, "oracle-output")
  oo_dir <- fs::path(tmp_hub_path, "target-data", "oracle-output")
  fs::dir_create(oo_dir)
  oo_dat <- arrow::read_csv_arrow(oo_path)
  arrow::write_dataset(oo_dat, oo_dir, partitioning = "target_end_date", format = "parquet")
  fs::file_delete(oo_path)

  expect_equal(
    create_oracle_output_schema(tmp_hub_path)$ToString(),
    "location: string\ntarget: string\noutput_type: string\noutput_type_id: string\noracle_value: double\ntarget_end_date: date32[day]" # nolint: line_length_linter
  )

  # Check that ignoring a partition folder returns the same schema
  expect_equal(
    create_oracle_output_schema(tmp_hub_path, ignore_files = "target_end_date=2023-06-17")$ToString(),
    "location: string\ntarget: string\noutput_type: string\noutput_type_id: string\noracle_value: double\ntarget_end_date: date32[day]" # nolint: line_length_linter
  )
})

test_that(
  "create_oracle_output_schema works on single-file S3 SubTreeFileSystem hub",
  {
    skip_if_offline()
    hub_path <- s3_bucket("example-complex-forecast-hub")
    oo_schema <- create_oracle_output_schema(hub_path)

    expect_equal(
      oo_schema$ToString(),
      "location: string\ntarget_end_date: date32[day]\ntarget: string\noutput_type: string\noutput_type_id: string\noracle_value: double" # nolint: line_length_linter
    )
  }
)
