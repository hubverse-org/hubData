# Tests for create_timeseries_schema using embedded example hubs
# Requires helper-v5-hubs.R with:
# - use_example_hub_readonly()
# - use_example_hub_editable()
# And helper-fixtures.R with:
# - timeseries_schema_fixture()

test_that("create_timeseries_schema inference works on single-file hub", {
  hub_path <- use_example_hub_readonly("file")

  sch <- create_timeseries_schema(hub_path)
  expect_equal(
    sch$ToString(),
    timeseries_schema_fixture(partition_col = NULL, include_as_of = FALSE)
  )
})

test_that("create_timeseries_schema inference handles extra columns and HIVE partitioning", {
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

test_that("create_timeseries_schema inference works on SubTreeFileSystem", {
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

test_that("create_timeseries_schema inference returns R datatypes", {
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

test_that("create_timeseries_schema inference detects non-task ID partition columns", {
  # editable copy to partition and remove the single file
  hub_path <- use_example_hub_editable("file")
  ts_path <- validate_target_data_path(hub_path, "time-series")
  dat <- arrow::read_csv_arrow(ts_path)
  dat$extra_col <- "extra"

  out_dir <- fs::path(hub_path, "target-data", "time-series")
  if (fs::dir_exists(out_dir)) {
    fs::dir_delete(out_dir)
  }
  fs::dir_create(out_dir)

  arrow::write_dataset(
    dat,
    out_dir,
    partitioning = c("target_end_date", "extra_col"),
    format = "parquet"
  )
  fs::file_delete(ts_path)

  sch_extra <- create_timeseries_schema(hub_path)
  expect_equal(
    sch_extra$extra_col$ToString(),
    "extra_col: string"
  )
})

# v6 config-based tests ----

test_that("create_timeseries_schema config works with basic v6 hub", {
  hub_path <- use_example_hub_readonly("file", v = 6)

  sch <- create_timeseries_schema(hub_path)

  # Check schema matches expected
  expect_equal(
    sch$ToString(),
    timeseries_schema_fixture(partition_col = NULL, include_as_of = FALSE)
  )

  # Check column ordering matches config observable_unit
  expect_equal(
    names(sch),
    c("target_end_date", "target", "location", "observation")
  )
})

test_that("create_timeseries_schema config handles versioned data", {
  hub_path <- use_example_hub_editable("file", v = 6)

  # Modify config to set versioned = true
  config_path <- fs::path(hub_path, "hub-config", "target-data.json")
  config <- hubUtils::read_config_file(config_path)
  config$versioned <- TRUE
  hubAdmin::write_config(
    config,
    config_path = config_path,
    overwrite = TRUE,
    silent = TRUE
  )

  sch <- create_timeseries_schema(hub_path)
  expect_equal(
    sch$ToString(),
    timeseries_schema_fixture(partition_col = NULL, include_as_of = TRUE)
  )

  # Check column ordering: as_of should be last
  expect_equal(
    names(sch),
    c("target_end_date", "target", "location", "observation", "as_of")
  )
})

test_that("create_timeseries_schema config handles non_task_id_schema", {
  hub_path <- use_example_hub_editable("file", v = 6)

  # Add non_task_id_schema to config
  config_path <- fs::path(hub_path, "hub-config", "target-data.json")
  config <- hubUtils::read_config_file(config_path)
  config$`time-series`$non_task_id_schema <- list(
    extra_col = "character",
    count_col = "integer"
  )
  hubAdmin::write_config(
    config,
    config_path = config_path,
    overwrite = TRUE,
    silent = TRUE
  )

  sch <- create_timeseries_schema(hub_path)

  # Check non-task ID columns are added with correct types
  expect_equal(sch$extra_col$ToString(), "extra_col: string")
  expect_equal(sch$count_col$ToString(), "count_col: int32")

  # Check column ordering: task IDs, non-task IDs, observation
  expect_equal(
    names(sch),
    c(
      "target_end_date",
      "target",
      "location",
      "extra_col",
      "count_col",
      "observation"
    )
  )
})

test_that("create_timeseries_schema config handles versioned + non_task_id_schema", {
  hub_path <- use_example_hub_editable("file", v = 6)

  # Set both versioned and non_task_id_schema
  config_path <- fs::path(hub_path, "hub-config", "target-data.json")
  config <- hubUtils::read_config_file(config_path)
  config$versioned <- TRUE
  config$`time-series`$non_task_id_schema <- list(region = "character")
  hubAdmin::write_config(
    config,
    config_path = config_path,
    overwrite = TRUE,
    silent = TRUE
  )

  sch <- create_timeseries_schema(hub_path)

  # Check types
  expect_equal(sch$as_of$ToString(), "as_of: date32[day]")
  expect_equal(sch$region$ToString(), "region: string")

  # Check column ordering: task IDs, non-task IDs, observation, as_of
  expect_equal(
    names(sch),
    c("target_end_date", "target", "location", "region", "observation", "as_of")
  )
})

test_that("create_timeseries_schema config returns R datatypes", {
  hub_path <- use_example_hub_readonly("file", v = 6)
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

  # Check ordering is preserved
  expect_equal(
    names(sch_r),
    c("target_end_date", "target", "location", "observation")
  )
})

test_that("create_timeseries_schema config ignores date_col parameter", {
  hub_path <- use_example_hub_readonly("file", v = 6)

  # date_col parameter should be ignored when config exists
  sch <- create_timeseries_schema(hub_path, date_col = "ignored_col")

  # Should use date_col from config (target_end_date)
  expect_equal(
    sch$ToString(),
    timeseries_schema_fixture(partition_col = NULL, include_as_of = FALSE)
  )
  expect_true("target_end_date" %in% names(sch))
})

test_that("create_timeseries_schema inference warns when no date column found", {
  # Create editable hub and modify data to have no date column
  hub_path <- use_example_hub_editable("file")
  ts_path <- validate_target_data_path(hub_path, "time-series")
  dat <- arrow::read_csv_arrow(ts_path)

  # Remove the date column
  dat_no_date <- dat |>
    dplyr::select(-target_end_date)

  .local_safe_overwrite(
    function(out_path) arrow::write_csv_arrow(dat_no_date, file = out_path),
    ts_path
  )

  # Should warn (not error) about missing date column
  expect_warning(
    sch <- create_timeseries_schema(hub_path),
    "No.*date.*type column found"
  )

  # Schema should still be created
  expect_s3_class(sch, "Schema")
})
