# Tests for connect_target_timeseries using embedded example hubs
# Requires helper-v5-hubs.R with:
# - use_example_hub_readonly()
# - use_example_hub_editable()
# - .local_safe_overwrite()
# - split_csv_by_target()
# - write_hive_parquet_by_target()
# And helper-fixtures.R with:
# - timeseries_schema_fixture()

test_that("connect_target_timeseries on single file works on embedded hub", {
  hub_path <- use_example_hub_readonly("file")

  ts_con <- connect_target_timeseries(hub_path)
  expect_s3_class(
    ts_con,
    c("target_timeseries", "FileSystemDataset", "Dataset", "ArrowObject", "R6"),
    exact = TRUE
  )
  expect_equal(basename(attr(ts_con, "ts_path")), "time-series.csv")
  expect_equal(
    ts_con$schema$ToString(),
    timeseries_schema_fixture(kind = "csv")
  )

  all <- dplyr::collect(ts_con)
  expect_s3_class(all, "tbl_df", exact = FALSE)
  expect_equal(ncol(all), 4L)
  expect_gt(nrow(all), 0L)

  expect_equal(
    sort(names(all)),
    sort(c("target_end_date", "target", "location", "observation"))
  )
  expect_setequal(unique(all$target), c("wk inc flu hosp", "wk flu hosp rate"))

  # simple filters (size-agnostic)
  by_date <- dplyr::filter(ts_con, target_end_date == "2022-10-22") |>
    dplyr::collect()
  expect_s3_class(by_date, "tbl_df", exact = FALSE)
  expect_gt(nrow(by_date), 0L)
  expect_setequal(as.character(unique(by_date$target_end_date)), "2022-10-22")

  us <- dplyr::filter(ts_con, location == "US") |> dplyr::collect()
  expect_s3_class(us, "tbl_df", exact = FALSE)
  expect_gt(nrow(us), 0L)
  expect_setequal(unique(us$location), "US")
})

test_that("connect_target_timeseries fails correctly", {
  # non-existent hub dir
  expect_error(
    connect_target_timeseries("random_path"),
    regexp = "Assertion on 'target_data_path' failed: Directory 'random_path/target-data' does not exist."
  )

  # editable copy to mutate layout
  hub_path <- use_example_hub_editable("file")
  ts_path <- validate_target_data_path(hub_path, "time-series")
  dat <- arrow::read_csv_arrow(ts_path)

  # Multiple files/directories alongside single file
  split_csv_by_target(hub_path, dat, target_type = "time-series")
  expect_error(
    connect_target_timeseries(hub_path),
    regexp = "Multiple .*time-series.* data found in hub .*time-series.csv"
  )

  # Mixed formats in directory
  out_dir <- fs::path(hub_path, "target-data", "time-series")
  if (fs::dir_exists(out_dir)) {
    fs::dir_delete(out_dir)
  }
  fs::dir_create(out_dir)
  fs::file_delete(ts_path)

  split(dat, dat$target) |>
    purrr::iwalk(function(df, tgt) {
      tgt2 <- gsub(" ", "_", tgt, fixed = TRUE)
      if (identical(tgt2, "wk_flu_hosp_rate")) {
        out_path <- fs::path(out_dir, paste0("target-", tgt2), ext = "csv")
        .local_safe_overwrite(
          function(out_path) arrow::write_csv_arrow(df, file = out_path),
          out_path
        )
      } else {
        out_path <- fs::path(out_dir, paste0("target-", tgt2), ext = "parquet")
        .local_safe_overwrite(
          function(out_path) arrow::write_parquet(df, out_path),
          out_path
        )
      }
    })

  expect_error(
    connect_target_timeseries(hub_path),
    regexp = "Multiple data file formats .*csv.* and .*parquet"
  )

  # No time-series data present
  fs::dir_delete(out_dir)
  expect_error(
    connect_target_timeseries(hub_path),
    regexp = "No .*time-series.* data found in .*target-data.* directory"
  )
})

test_that("connect_target_timeseries on multiple non-partitioned CSV files works", {
  hub_path <- use_example_hub_editable("file")
  ts_path <- validate_target_data_path(hub_path, "time-series")
  dat <- arrow::read_csv_arrow(ts_path)
  fs::file_delete(ts_path)

  split_csv_by_target(hub_path, dat, target_type = "time-series")
  ts_con <- connect_target_timeseries(hub_path)

  expect_s3_class(
    ts_con,
    c("target_timeseries", "FileSystemDataset", "Dataset", "ArrowObject", "R6"),
    exact = TRUE
  )
  expect_equal(basename(attr(ts_con, "ts_path")), "time-series")
  expect_equal(
    ts_con$schema$ToString(),
    timeseries_schema_fixture(kind = "csv")
  )

  all <- dplyr::collect(ts_con)
  expect_equal(ncol(all), 4L)
  expect_gt(nrow(all), 0L)
  expect_equal(
    sort(names(all)),
    sort(c("target_end_date", "target", "location", "observation"))
  )

  # simple filter
  lt1 <- dplyr::filter(ts_con, observation < 1) |> dplyr::collect()
  expect_gt(nrow(lt1), 0L)

  # ignore_files behavior (content-only assertion)
  ts_con2 <- connect_target_timeseries(
    hub_path,
    ignore_files = "target-wk_inc_flu_hosp.csv"
  )
  res2 <- dplyr::collect(ts_con2)
  expect_gt(nrow(res2), 0L)
})

test_that("connect_target_timeseries works with non-partitioned CSVs in subdirectories", {
  hub_path <- use_example_hub_editable("file")
  ts_path <- validate_target_data_path(hub_path, "time-series")
  dat <- arrow::read_csv_arrow(ts_path)
  fs::file_delete(ts_path)

  # create subdir layout
  out_dir <- fs::path(hub_path, "target-data", "time-series")
  if (fs::dir_exists(out_dir)) {
    fs::dir_delete(out_dir)
  }
  fs::dir_create(out_dir)

  split(dat, dat$target) |>
    purrr::iwalk(function(df, tgt) {
      tgt2 <- gsub(" ", "_", tgt, fixed = TRUE)
      subd <- fs::path(out_dir, tgt2)
      fs::dir_create(subd)
      out_path <- fs::path(subd, paste0("target-", tgt2), ext = "csv")
      .local_safe_overwrite(
        function(out_path) arrow::write_csv_arrow(df, file = out_path),
        out_path
      )
    })

  ts_con <- connect_target_timeseries(hub_path)
  expect_equal(
    ts_con$schema$ToString(),
    timeseries_schema_fixture(kind = "csv")
  )

  res <- dplyr::collect(ts_con)
  expect_equal(ncol(res), 4L)
  expect_gt(nrow(res), 0L)

  # ignore_files smoke test
  ts_con2 <- connect_target_timeseries(
    hub_path,
    ignore_files = "target-wk_inc_flu_hosp.csv"
  )
  res2 <- dplyr::collect(ts_con2)
  expect_gt(nrow(res2), 0L)
})

test_that("connect_target_timeseries with HIVE-PARTITIONED parquet works", {
  hub_path <- use_example_hub_editable("file")
  ts_path <- validate_target_data_path(hub_path, "time-series")
  dat <- arrow::read_csv_arrow(ts_path)
  fs::file_delete(ts_path)

  write_hive_parquet_by_target(hub_path, dat, target_type = "time-series")

  ts_con <- connect_target_timeseries(hub_path)
  expect_equal(
    ts_con$schema$ToString(),
    timeseries_schema_fixture(kind = "hive")
  )

  all <- dplyr::collect(ts_con)
  expect_equal(ncol(all), 4L)
  expect_gt(nrow(all), 0L)
  expect_equal(
    sort(names(all)),
    sort(c("target_end_date", "location", "observation", "target"))
  )
})

test_that("connect_target_timeseries works on single-file SubTreeFileSystem (local mirror)", {
  skip_on_os("windows") # SubTreeFileSystem lower-level calls are flaky on Windows

  src <- use_example_hub_readonly("file")
  tmp <- withr::local_tempdir("subtree-ts-")
  fs::dir_copy(src, tmp, overwrite = TRUE)
  loc_fs <- arrow::SubTreeFileSystem$create(tmp)

  cfg <- read_config(tmp)
  local_mocked_bindings(read_config = function(...) cfg)

  ts_con <- connect_target_timeseries(loc_fs)
  expect_s3_class(
    ts_con,
    c("target_timeseries", "FileSystemDataset", "Dataset", "ArrowObject", "R6"),
    exact = TRUE
  )
  expect_equal(basename(attr(ts_con, "ts_path")), "time-series.csv")
  expect_equal(
    ts_con$schema$ToString(),
    timeseries_schema_fixture(kind = "csv")
  )

  res <- dplyr::collect(ts_con)
  expect_equal(ncol(res), 4L)
  expect_gt(nrow(res), 0L)
})

test_that("connect_target_timeseries works with multi-file SubTreeFileSystem hub", {
  skip_on_os("windows")

  # fan out to multi-file CSVs
  src <- use_example_hub_readonly("file")
  work <- withr::local_tempdir("ts-mirror-")
  fs::dir_copy(src, work, overwrite = TRUE)

  ts_path <- validate_target_data_path(work, "time-series")
  dat <- arrow::read_csv_arrow(ts_path)
  fs::file_delete(ts_path)
  split_csv_by_target(work, dat, target_type = "time-series")

  # mount via SubTreeFileSystem
  hub_root <- withr::local_tempdir("subtree-ts-mf-")
  loc_fs <- arrow::SubTreeFileSystem$create(hub_root)
  arrow::copy_files(work, loc_fs)

  cfg <- read_config(hub_root)
  local_mocked_bindings(read_config = function(...) cfg)

  ts_con <- connect_target_timeseries(loc_fs)
  expect_s3_class(
    ts_con,
    c("target_timeseries", "FileSystemDataset", "Dataset", "ArrowObject", "R6"),
    exact = TRUE
  )
  expect_equal(basename(attr(ts_con, "ts_path")), "time-series")
  expect_equal(
    ts_con$schema$ToString(),
    timeseries_schema_fixture(kind = "csv")
  )

  all <- dplyr::collect(ts_con)
  expect_equal(ncol(all), 4L)
  expect_gt(nrow(all), 0L)
  expect_equal(
    sort(names(all)),
    sort(c("target_end_date", "target", "location", "observation"))
  )

  # simple filter smoke test
  few <- dplyr::filter(ts_con, observation < 1) |> dplyr::collect()
  expect_gt(nrow(few), 0L)
})
