# Tests for connect_target_oracle_output using embedded example hubs
# Requires helper-v5-hubs.R with:
# - use_example_hub_readonly()
# - use_example_hub_editable()
# - .local_safe_overwrite()
# - split_csv_by_target()
# - write_hive_parquet_by_target()
# And helper-fixtures.R with:
# - oracle_output_schema_fixture()

test_that("connect_target_oracle_output inference on single file works", {
  hub_path <- use_example_hub_readonly("file")
  con <- connect_target_oracle_output(hub_path)

  expect_s3_class(
    con,
    c(
      "target_oracle_output",
      "FileSystemDataset",
      "Dataset",
      "ArrowObject",
      "R6"
    ),
    exact = TRUE
  )
  expect_equal(basename(attr(con, "oo_path")), "oracle-output.csv")
  expect_equal(
    con$schema$ToString(),
    oracle_output_schema_fixture(
      partition_col = NULL,
      output_type_id = "string"
    )
  )

  all <- dplyr::collect(con)

  # size-agnostic checks
  expect_s3_class(all, "tbl_df", exact = FALSE)
  expect_equal(ncol(all), 6L)
  expect_gt(nrow(all), 0L)

  # names and uniques
  expect_equal(
    sort(names(all)),
    sort(c(
      "location",
      "target_end_date",
      "target",
      "output_type",
      "output_type_id",
      "oracle_value"
    ))
  )
  expect_setequal(unique(all$location), c("US", "01", "02"))
  expect_setequal(
    unique(all$target),
    c("wk inc flu hosp", "wk flu hosp rate", "wk flu hosp rate category")
  )

  # simple filters (no magic counts)
  filter_date <- dplyr::filter(con, target_end_date == "2022-11-12") |>
    dplyr::collect()
  expect_s3_class(filter_date, "tbl_df", exact = FALSE)
  expect_gt(nrow(filter_date), 0L)
  expect_setequal(unique(filter_date$location), c("US", "01", "02"))
  expect_setequal(
    unique(filter_date$target),
    c("wk inc flu hosp", "wk flu hosp rate", "wk flu hosp rate category")
  )
  expect_setequal(
    as.character(unique(filter_date$target_end_date)),
    "2022-11-12"
  )

  filter_us <- dplyr::filter(con, location == "US") |> dplyr::collect()
  expect_s3_class(filter_us, "tbl_df", exact = FALSE)
  expect_gt(nrow(filter_us), 0L)
  expect_setequal(unique(filter_us$location), "US")
})

test_that("connect_target_oracle_output fails correctly", {
  # non-existent hub dir
  expect_error(
    connect_target_oracle_output("random_path"),
    regexp = "Assertion on 'target_data_path' failed: Directory 'random_path/target-data' does not exist."
  )

  # fresh temp copy to edit
  hub_path <- use_example_hub_editable("file")
  ts_path <- validate_target_data_path(hub_path, "oracle-output")

  # Multiple files/directories under oracle-output
  dat <- arrow::read_csv_arrow(ts_path)
  split_csv_by_target(hub_path, dat, target_type = "oracle-output")
  expect_error(
    connect_target_oracle_output(hub_path),
    regexp = "Multiple .*oracle-output.* data found in hub .*oracle-output.csv"
  )

  # Mixed formats
  out_dir <- fs::path(hub_path, "target-data", "oracle-output")
  if (fs::dir_exists(out_dir)) {
    fs::dir_delete(out_dir)
  }
  fs::dir_create(out_dir)
  fs::file_delete(ts_path)

  split(dat, dat$target) |>
    purrr::iwalk(function(df, tgt) {
      tgt <- gsub(" ", "_", tgt, fixed = TRUE)
      if (identical(tgt, "wk_flu_hosp_rate")) {
        out_path <- fs::path(out_dir, paste0("target-", tgt), ext = "csv")
        .local_safe_overwrite(
          function(out_path) arrow::write_csv_arrow(df, file = out_path),
          out_path
        )
      } else {
        out_path <- fs::path(out_dir, paste0("target-", tgt), ext = "parquet")
        .local_safe_overwrite(
          function(out_path) arrow::write_parquet(df, out_path),
          out_path
        )
      }
    })
  expect_error(
    connect_target_oracle_output(hub_path),
    regexp = "Multiple data file formats .*csv.* and .*parquet"
  )

  # No oracle-output data present
  fs::dir_delete(out_dir)
  expect_error(
    connect_target_oracle_output(hub_path),
    regexp = "No .*oracle-output.* data found in .*target-data.* directory"
  )
})

# Although we generally only allow multiple file datasets of parquet files,
# (and validate that restriction in hubValidations), connect_target_* functions
# were written before we set that restriction and at least for now, can handle
# datasets with multiple CSV files.
test_that("connect_target_oracle_output inference on multiple CSVs works", {
  hub_path <- use_example_hub_editable("file")
  ts_path <- validate_target_data_path(hub_path, "oracle-output")
  dat <- arrow::read_csv_arrow(ts_path)
  fs::file_delete(ts_path)

  split_csv_by_target(hub_path, dat, target_type = "oracle-output")
  con <- connect_target_oracle_output(hub_path)

  expect_s3_class(
    con,
    c(
      "target_oracle_output",
      "FileSystemDataset",
      "Dataset",
      "ArrowObject",
      "R6"
    ),
    exact = TRUE
  )
  expect_equal(basename(attr(con, "oo_path")), "oracle-output")
  expect_equal(
    con$schema$ToString(),
    oracle_output_schema_fixture(
      partition_col = NULL,
      output_type_id = "string"
    )
  )

  all <- dplyr::collect(con)
  expect_equal(ncol(all), 6L)
  expect_gt(nrow(all), 0L)
  expect_equal(
    sort(names(all)),
    sort(c(
      "location",
      "target_end_date",
      "target",
      "output_type",
      "output_type_id",
      "oracle_value"
    ))
  )

  # Filter property
  lt1 <- dplyr::filter(con, oracle_value < 1) |> dplyr::collect()
  expect_gt(nrow(lt1), 0L)
  expect_true(all(lt1$oracle_value < 1))

  # ignore_files behavior (content-only assertion)
  con2 <- connect_target_oracle_output(
    hub_path,
    ignore_files = "target-wk_inc_flu_hosp.csv"
  )
  res2 <- dplyr::collect(con2)
  expect_gt(nrow(res2), 0L)
})

# Although we generally only allow multiple file datasets of parquet files,
# (and validate that restriction in hubValidations), connect_target_* functions
# were written before we set that restriction and at least for now, can handle
# datasets with multiple CSV files.
test_that("connect_target_oracle_output inference with CSVs in subdirs works", {
  hub_path <- use_example_hub_editable("file")
  ts_path <- validate_target_data_path(hub_path, "oracle-output")
  dat <- arrow::read_csv_arrow(ts_path)
  fs::file_delete(ts_path)

  # create subdir layout (still non-partitioned)
  out_dir <- fs::path(hub_path, "target-data", "oracle-output")
  if (fs::dir_exists(out_dir)) {
    fs::dir_delete(out_dir)
  }
  fs::dir_create(out_dir)

  split(dat, dat$target) |>
    purrr::iwalk(function(df, tgt) {
      tgt <- gsub(" ", "_", tgt, fixed = TRUE)
      subd <- fs::path(out_dir, tgt)
      fs::dir_create(subd)
      out_path <- fs::path(subd, paste0("target-", tgt), ext = "csv")
      .local_safe_overwrite(
        function(out_path) arrow::write_csv_arrow(df, file = out_path),
        out_path
      )
    })

  con <- connect_target_oracle_output(hub_path)
  expect_equal(
    con$schema$ToString(),
    oracle_output_schema_fixture(
      partition_col = NULL,
      output_type_id = "string"
    )
  )
  res <- dplyr::collect(con)
  expect_equal(ncol(res), 6L)
  expect_gt(nrow(res), 0L)

  # ignore_files smoke test
  con2 <- connect_target_oracle_output(
    hub_path,
    ignore_files = "target-wk_inc_flu_hosp.csv"
  )
  res2 <- dplyr::collect(con2)
  expect_gt(nrow(res2), 0L)
})

test_that("connect_target_oracle_output inference with HIVE partitioned parquet works", {
  hub_path <- use_example_hub_editable("file")
  ts_path <- validate_target_data_path(hub_path, "oracle-output")
  dat <- arrow::read_csv_arrow(ts_path)
  fs::file_delete(ts_path)

  # partitions by 'target'
  write_hive_parquet_by_target(hub_path, dat, target_type = "oracle-output")

  con <- connect_target_oracle_output(hub_path)
  expect_equal(
    con$schema$ToString(),
    oracle_output_schema_fixture(
      partition_col = "target",
      output_type_id = "string"
    )
  )

  all <- dplyr::collect(con)
  expect_equal(ncol(all), 6L)
  expect_gt(nrow(all), 0L)
  expect_equal(
    sort(names(all)),
    sort(c(
      "location",
      "target_end_date",
      "output_type",
      "output_type_id",
      "oracle_value",
      "target"
    ))
  )

  # Demonstrate ignore_files pitfalls with hive partitioning (behavior only)
  con2 <- connect_target_oracle_output(
    hub_path,
    ignore_files = "target=wk%20flu%20hosp%20rate"
  )
  res2 <- dplyr::collect(con2)
  expect_gt(nrow(res2), 0L)

  con3 <- connect_target_oracle_output(
    hub_path,
    ignore_files = "target=wk%20flu%20hosp%20rate/part-0.parquet"
  )
  res3 <- dplyr::collect(con3)
  expect_gt(nrow(res3), 0L)
})

test_that("connect_target_oracle_output inference on single-file SubTreeFileSystem works", {
  skip_on_os("windows") # SubTreeFileSystem lower-level calls are flaky on Windows

  src <- use_example_hub_readonly("file")
  tmp <- withr::local_tempdir("subtree-hub-")
  fs::dir_copy(src, tmp, overwrite = TRUE)
  loc_fs <- arrow::SubTreeFileSystem$create(tmp)

  cfg <- read_config(tmp)
  local_mocked_bindings(read_config = function(...) cfg)

  con <- connect_target_oracle_output(loc_fs)
  expect_s3_class(
    con,
    c(
      "target_oracle_output",
      "FileSystemDataset",
      "Dataset",
      "ArrowObject",
      "R6"
    ),
    exact = TRUE
  )
  expect_equal(basename(attr(con, "oo_path")), "oracle-output.csv")
  expect_equal(
    con$schema$ToString(),
    oracle_output_schema_fixture(
      partition_col = NULL,
      output_type_id = "string"
    )
  )

  res <- dplyr::collect(con)
  expect_equal(ncol(res), 6L)
  expect_gt(nrow(res), 0L)
})

test_that("connect_target_oracle_output inference with multi-file SubTreeFileSystem works", {
  skip_on_os("windows")

  # Start from temp copy to fan out multi-file
  src <- use_example_hub_readonly("file")
  oo_dir_hub_path <- withr::local_tempdir("subtree-hub-mf-")
  fs::dir_copy(src, oo_dir_hub_path, overwrite = TRUE)

  ts_path <- validate_target_data_path(oo_dir_hub_path, "oracle-output")
  dat <- arrow::read_csv_arrow(ts_path)
  fs::file_delete(ts_path)

  split_csv_by_target(oo_dir_hub_path, dat, target_type = "oracle-output")

  # Mirror into SubTreeFileSystem
  hub_root <- withr::local_tempdir()
  loc_fs <- arrow::SubTreeFileSystem$create(hub_root)
  arrow::copy_files(oo_dir_hub_path, loc_fs)
  cfg <- read_config(hub_root)
  local_mocked_bindings(read_config = function(...) cfg)

  con <- connect_target_oracle_output(loc_fs)
  expect_s3_class(
    con,
    c(
      "target_oracle_output",
      "FileSystemDataset",
      "Dataset",
      "ArrowObject",
      "R6"
    ),
    exact = TRUE
  )
  expect_equal(basename(attr(con, "oo_path")), "oracle-output")
  expect_equal(
    con$schema$ToString(),
    oracle_output_schema_fixture(
      partition_col = NULL,
      output_type_id = "string"
    )
  )

  all <- dplyr::collect(con)
  expect_equal(ncol(all), 6L)
  expect_gt(nrow(all), 0L)
  expect_equal(
    sort(names(all)),
    sort(c(
      "location",
      "target_end_date",
      "target",
      "output_type",
      "output_type_id",
      "oracle_value"
    ))
  )

  # simple filter smoke test
  lt1 <- dplyr::filter(con, oracle_value < 1) |> dplyr::collect()
  expect_gt(nrow(lt1), 0L)
  expect_true(all(lt1$oracle_value < 1))
})

test_that('connect_target_oracle_output inference parses "NA" and "" correctly', {
  hub_path <- use_example_hub_editable("file")
  ts_path <- validate_target_data_path(hub_path, "oracle-output")
  dat <- arrow::read_csv_arrow(ts_path)

  # Introduce literal "NA" text in character column; write with safe overwrite
  dat$location[1] <- "NA"
  .local_safe_overwrite(
    function(out_path) arrow::write_csv_arrow(dat, file = out_path),
    ts_path
  )

  con <- connect_target_oracle_output(hub_path, na = "")
  expect_equal(
    con$schema$ToString(),
    oracle_output_schema_fixture(
      partition_col = NULL,
      output_type_id = "string"
    )
  )
  all <- dplyr::collect(con)
  expect_true(all$location[1] == "NA")
  expect_true(
    all[dat$output_type_id == "", "output_type_id"] |> is.na() |> all()
  )
})

test_that("connect_target_oracle_output inference output_type_id_datatype arg works", {
  hub_path <- use_example_hub_editable("file")

  oracle_path <- get_target_path(hub_path, target_type = "oracle-output")

  # Subset oracle output output_type_id to value that can successfully
  # be converted to numeric
  arrow::read_csv_arrow(oracle_path) |>
    dplyr::filter(output_type_id == "1") |>
    arrow::write_csv_arrow(oracle_path)

  con <- connect_target_oracle_output(
    hub_path,
    output_type_id_datatype = "double"
  )
  expect_equal(
    con$schema$ToString(),
    oracle_output_schema_fixture(
      partition_col = NULL,
      output_type_id = "double"
    )
  )

  # Check that data can be collected
  data <- con |>
    utils::head(1L) |>
    dplyr::collect()

  expect_s3_class(data, "tbl_df")
  expect_equal(ncol(data), 6L)
  expect_equal(nrow(data), 1L)
  expect_named(
    data,
    c(
      "location",
      "target_end_date",
      "target",
      "output_type",
      "output_type_id",
      "oracle_value"
    )
  )
})

test_that("partitioning column schema is detected correctly via inference (#89)", {
  hub_path_cloud <- s3_bucket("covid-variant-nowcast-hub")
  # Force inference by mocking has_target_data_config to return FALSE
  local_mocked_bindings(has_target_data_config = function(...) FALSE)
  con <- connect_target_oracle_output(hub_path_cloud)

  expect_s3_class(
    con,
    c(
      "target_oracle_output",
      "FileSystemDataset",
      "Dataset",
      "ArrowObject",
      "R6"
    ),
    exact = TRUE
  )
  expect_equal(
    con$schema$ToString(),
    "location: string\ntarget_date: date32[day]\nclade: string\noracle_value: double\nnowcast_date: date32[day]\nas_of: date32[day]" # nolint: line_length_linter
  )
})

# v6 config-based tests ----

test_that("connect_target_oracle_output config works with v6 CSV hub", {
  hub_path <- use_example_hub_readonly("file", v = 6)

  con <- connect_target_oracle_output(hub_path)
  expect_s3_class(
    con,
    c(
      "target_oracle_output",
      "FileSystemDataset",
      "Dataset",
      "ArrowObject",
      "R6"
    ),
    exact = TRUE
  )
  # Config-based schema in CSVs follows dataset column order
  expect_equal(
    con$schema$ToString(),
    "location: string\ntarget_end_date: date32[day]\ntarget: string\noutput_type: string\noutput_type_id: string\noracle_value: double" # nolint: line_length_linter
  )

  # Check that data can be collected
  data <- con |>
    utils::head(1L) |>
    dplyr::collect()

  expect_s3_class(data, "tbl_df")
  expect_equal(ncol(data), 6L)
  expect_equal(nrow(data), 1L)
  expect_named(
    data,
    c(
      "location",
      "target_end_date",
      "target",
      "output_type",
      "output_type_id",
      "oracle_value"
    )
  )
})

test_that("connect_target_oracle_output config works with v6 parquet partitioned hub", {
  hub_path <- use_example_hub_readonly("dir", v = 6)

  con <- connect_target_oracle_output(hub_path)
  expect_s3_class(
    con,
    c(
      "target_oracle_output",
      "FileSystemDataset",
      "Dataset",
      "ArrowObject",
      "R6"
    ),
    exact = TRUE
  )
  # Config-based schema in parquets follows schema column order, even when
  # partitioned
  expect_equal(
    con$schema$ToString(),
    "target_end_date: date32[day]\ntarget: string\nlocation: string\noutput_type: string\noutput_type_id: string\noracle_value: double" # nolint: line_length_linter
  )

  # Check that data can be collected
  data <- con |>
    utils::head(1L) |>
    dplyr::collect()

  expect_s3_class(data, "tbl_df")
  expect_equal(ncol(data), 6L)
  expect_equal(nrow(data), 1L)
  expect_named(
    data,
    c(
      "target_end_date",
      "target",
      "location",
      "output_type",
      "output_type_id",
      "oracle_value"
    )
  )
})
