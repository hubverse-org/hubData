# Tests for create_timeseries_schema using embedded example hubs
# Requires helper-v5-hubs.R with:
# - use_example_hub_readonly()
# - use_example_hub_editable()
# And helper-fixtures.R with:
# - timeseries_schema_fixture()

test_that("create_timeseries_schema works on embedded single-file hub", {
  hub_path <- use_example_hub_readonly("file")

  sch <- create_timeseries_schema(hub_path)
  expect_equal(
    sch$ToString(),
    timeseries_schema_fixture(partition_col = NULL, include_as_of = FALSE)
  )
})

test_that("create_timeseries_schema handles extra columns and HIVE partitioning", {
  # editable copy so we can modify/write files
  hub_path <- use_example_hub_editable("file")
  ts_path <- validate_target_data_path(hub_path, "time-series")
  dat <- arrow::read_csv_arrow(ts_path)

  # 1) Add an as_of column (still single-file CSV)
  dat_asof <- dat |> dplyr::mutate(as_of = as.Date("2025-02-28"))
  .local_safe_overwrite(
    function(out_path) arrow::write_csv_arrow(dat_asof, file = out_path),
    ts_path
  )

  sch_asof <- create_timeseries_schema(hub_path)
  expect_equal(
    sch_asof$ToString(),
    timeseries_schema_fixture(partition_col = NULL, include_as_of = TRUE)
  )

  # 2) HIVE-partition by 'target' (non-date), delete the single CSV
  out_dir <- fs::path(hub_path, "target-data", "time-series")
  if (fs::dir_exists(out_dir)) {
    fs::dir_delete(out_dir)
  }
  fs::dir_create(out_dir)

  arrow::write_dataset(
    dat_asof,
    out_dir,
    partitioning = "target",
    format = "parquet"
  )
  fs::file_delete(ts_path)

  # partitioning by 'target' should place 'target' last
  sch_hive_target <- create_timeseries_schema(hub_path)
  expect_equal(
    sch_hive_target$ToString(),
    timeseries_schema_fixture(partition_col = "target", include_as_of = TRUE)
  )

  # 3) Repartition by 'target_end_date' (date-like task id), expect success without date_col
  if (fs::dir_exists(out_dir)) {
    fs::dir_delete(out_dir)
  }
  fs::dir_create(out_dir)

  arrow::write_dataset(
    dat_asof,
    out_dir,
    partitioning = "target_end_date",
    format = "parquet"
  )

  sch_hive_ted <- create_timeseries_schema(hub_path)
  expect_equal(
    sch_hive_ted$ToString(),
    timeseries_schema_fixture(
      partition_col = "target_end_date",
      include_as_of = TRUE
    )
  )

  # 4) Ignoring a specific partition folder yields the same schema
  sch_ign <- create_timeseries_schema(
    hub_path,
    ignore_files = "target_end_date=2025-02-28"
  )
  expect_equal(
    sch_ign$ToString(),
    timeseries_schema_fixture(
      partition_col = "target_end_date",
      include_as_of = TRUE
    )
  )
})

test_that("create_timeseries_schema works on single-file SubTreeFileSystem (local mirror)", {
  skip_on_os("windows")
  # SubTreeFileSystem lower-level calls are flaky on Windows and can emit
  # UNC-like paths (//C/...) that Arrow fails to stat; we already cover
  # SubTreeFileSystem on Linux/macOS and real S3 in other tests.

  # Mirror the embedded hub into a temp FS and mount via SubTreeFileSystem
  src <- use_example_hub_readonly("file")
  tmp <- withr::local_tempdir("subtree-ts-")
  fs::dir_copy(src, tmp, overwrite = TRUE)
  loc_fs <- arrow::SubTreeFileSystem$create(tmp)

  cfg <- read_config(tmp)
  local_mocked_bindings(read_config = function(...) cfg)

  sch <- create_timeseries_schema(loc_fs)
  expect_equal(
    sch$ToString(),
    timeseries_schema_fixture(partition_col = NULL, include_as_of = FALSE)
  )
})

test_that("create_timeseries_schema returns R datatypes", {
  hub_path <- use_example_hub_readonly("file")
  sch_r <- create_timeseries_schema(hub_path, r_schema = TRUE)

  expect_equal(
    sch_r,
    c(
      target_end_date = "Date",
      target = "character",
      location = "character",
      observation = "double"
    )
  )
})
