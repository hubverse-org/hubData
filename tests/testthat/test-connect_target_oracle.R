# Tests for connect_target_oracle_output using embedded example hubs
# Requires helper-hubs.R with:
# - use_example_hub_readonly()
# - use_example_hub_editable()
# - .local_safe_overwrite()

test_that("connect_target_oracle_output on single file works on embedded hub", {
  hub_path <- use_example_hub_readonly("file")

  # Connect to oracle-output data
  oo_con <- connect_target_oracle_output(hub_path)
  expect_s3_class(
    oo_con,
    c(
      "target_oracle_output",
      "FileSystemDataset",
      "Dataset",
      "ArrowObject",
      "R6"
    ),
    exact = TRUE
  )

  expect_equal(basename(attr(oo_con, "oo_path")), "oracle-output.csv")
  expect_length(oo_con$files, 1L)
  expect_equal(basename(oo_con$files), basename(attr(oo_con, "oo_path")))

  expect_equal(
    oo_con$schema$ToString(),
    "location: string\ntarget_end_date: date32[day]\ntarget: string\noutput_type: string\noutput_type_id: string\noracle_value: double"
  )

  all <- dplyr::collect(oo_con)
  expect_equal(dim(all), c(627L, 6L))
  expect_s3_class(all, "tbl_df", exact = FALSE)
  expect_true(
    all[all$output_type_id == "quantile", ]$output_type_id |> is.na() |> all()
  )
  expect_equal(
    names(all),
    c(
      "location",
      "target_end_date",
      "target",
      "output_type",
      "output_type_id",
      "oracle_value"
    )
  )
  expect_equal(unique(all$location), c("US", "01", "02"))
  expect_equal(
    unique(all$target),
    c("wk flu hosp rate", "wk flu hosp rate category", "wk inc flu hosp")
  )
  expect_equal(
    sapply(all, class),
    c(
      location = "character",
      target_end_date = "Date",
      target = "character",
      output_type = "character",
      output_type_id = "character",
      oracle_value = "numeric"
    )
  )
  expect_equal(
    sapply(all, typeof),
    c(
      location = "character",
      target_end_date = "double",
      target = "character",
      output_type = "character",
      output_type_id = "character",
      oracle_value = "double"
    )
  )

  # Filter before collect
  filter_date <- dplyr::filter(oo_con, target_end_date == "2022-11-12") |>
    dplyr::collect()
  expect_equal(dim(filter_date), c(57L, 6L))
  expect_s3_class(filter_date, "tbl_df", exact = FALSE)
  expect_true(
    filter_date[filter_date$output_type_id == "quantile", ]$output_type_id |>
      is.na() |>
      all()
  )
  expect_equal(unique(filter_date$location), c("US", "01", "02"))
  expect_equal(
    unique(filter_date$target),
    c("wk flu hosp rate", "wk flu hosp rate category", "wk inc flu hosp")
  )
  expect_equal(as.character(unique(filter_date$target_end_date)), "2022-11-12")
  expect_equal(
    sapply(filter_date, class),
    c(
      location = "character",
      target_end_date = "Date",
      target = "character",
      output_type = "character",
      output_type_id = "character",
      oracle_value = "numeric"
    )
  )
  expect_equal(
    sapply(filter_date, typeof),
    c(
      location = "character",
      target_end_date = "double",
      target = "character",
      output_type = "character",
      output_type_id = "character",
      oracle_value = "double"
    )
  )

  # Filter by location
  filter_location <- dplyr::filter(oo_con, location == "US") |> dplyr::collect()
  expect_equal(dim(filter_location), c(209L, 6L))
  expect_s3_class(filter_location, "tbl_df", exact = FALSE)
  expect_equal(unique(filter_location$location), "US")
  expect_true(
    filter_location[
      filter_location$output_type_id == "quantile",
    ]$output_type_id |>
      is.na() |>
      all()
  )
  expect_equal(length(unique(filter_location$target_end_date)), 11L)
  expect_equal(
    sapply(filter_location, class),
    c(
      location = "character",
      target_end_date = "Date",
      target = "character",
      output_type = "character",
      output_type_id = "character",
      oracle_value = "numeric"
    )
  )
  expect_equal(
    sapply(filter_location, typeof),
    c(
      location = "character",
      target_end_date = "double",
      target = "character",
      output_type = "character",
      output_type_id = "character",
      oracle_value = "double"
    )
  )
})

test_that("connect_target_oracle_output fails correctly", {
  # non-existent hub dir
  expect_error(
    connect_target_oracle_output("random_path"),
    regexp = "Assertion on 'target_data_path' failed: Directory 'random_path/target-data' does not exist."
  )

  # fresh temp copy to edit
  hub_path <- use_example_hub_editable("file")
  oo_path <- validate_target_data_path(hub_path, "oracle-output")

  # Multiple files/directories under oracle-output
  oo_dat <- arrow::read_csv_arrow(oo_path)
  oo_dir <- fs::path(hub_path, "target-data", "oracle-output")
  fs::dir_create(oo_dir)
  split(oo_dat, oo_dat$target) |>
    purrr::iwalk(
      ~ {
        target <- gsub(" ", "_", .y, fixed = TRUE)
        path <- fs::path(oo_dir, paste0("target-", target), ext = "csv")
        .local_safe_overwrite(
          function(path_out) arrow::write_csv_arrow(.x, file = path_out),
          path
        )
      }
    )
  expect_error(
    connect_target_oracle_output(hub_path),
    regexp = "Multiple .*oracle-output.* data found in hub .*oracle-output.csv"
  )

  # Mixed formats
  fs::dir_delete(oo_dir)
  fs::dir_create(oo_dir)
  fs::file_delete(oo_path)
  split(oo_dat, oo_dat$target) |>
    purrr::iwalk(
      ~ {
        target <- gsub(" ", "_", .y, fixed = TRUE)
        if (identical(target, "wk_flu_hosp_rate")) {
          path <- fs::path(oo_dir, paste0("target-", target), ext = "csv")
          .local_safe_overwrite(
            function(path_out) arrow::write_csv_arrow(.x, file = path_out),
            path
          )
        } else {
          path <- fs::path(oo_dir, paste0("target-", target), ext = "parquet")
          .local_safe_overwrite(
            function(path_out) arrow::write_parquet(.x, path_out),
            path
          )
        }
      }
    )
  expect_error(
    connect_target_oracle_output(hub_path),
    regexp = "Multiple data file formats .*csv.* and .*parquet"
  )

  # No oracle-output data present
  fs::dir_delete(oo_dir)
  expect_error(
    connect_target_oracle_output(hub_path),
    regexp = "No .*oracle-output.* data found in .*target-data.* directory"
  )
})

test_that("connect_target_oracle_output on multiple non-partitioned files works (editable copy)", {
  hub_path <- use_example_hub_editable("file")
  oo_path <- validate_target_data_path(hub_path, "oracle-output")
  oo_dat <- arrow::read_csv_arrow(oo_path)
  fs::file_delete(oo_path)

  # Create separate CSV by target
  oo_dir <- fs::path(hub_path, "target-data", "oracle-output")
  fs::dir_create(oo_dir)
  split(oo_dat, oo_dat$target) |>
    purrr::iwalk(
      ~ {
        target <- gsub(" ", "_", .y, fixed = TRUE)
        path <- fs::path(oo_dir, paste0("target-", target), ext = "csv")
        .local_safe_overwrite(
          function(path_out) arrow::write_csv_arrow(.x, file = path_out),
          path
        )
      }
    )

  oo_con <- connect_target_oracle_output(hub_path)
  expect_s3_class(
    oo_con,
    c(
      "target_oracle_output",
      "FileSystemDataset",
      "Dataset",
      "ArrowObject",
      "R6"
    ),
    exact = TRUE
  )
  expect_equal(basename(attr(oo_con, "oo_path")), "oracle-output")
  expect_length(oo_con$files, 3L)
  expect_equal(
    basename(oo_con$files),
    basename(fs::dir_ls(oo_dir, recurse = TRUE, type = "file"))
  )
  expect_equal(
    oo_con$schema$ToString(),
    "location: string\ntarget_end_date: date32[day]\ntarget: string\noutput_type: string\noutput_type_id: string\noracle_value: double"
  )

  all <- dplyr::collect(oo_con)
  expect_equal(dim(all), c(627L, 6L))
  expect_true(
    all[all$output_type_id == "quantile", ]$output_type_id |> is.na() |> all()
  )
  expect_equal(
    unique(all$target),
    c("wk flu hosp rate", "wk flu hosp rate category", "wk inc flu hosp")
  )
  expect_equal(
    sapply(all, class),
    c(
      location = "character",
      target_end_date = "Date",
      target = "character",
      output_type = "character",
      output_type_id = "character",
      oracle_value = "numeric"
    )
  )
  expect_equal(
    sapply(all, typeof),
    c(
      location = "character",
      target_end_date = "double",
      target = "character",
      output_type = "character",
      output_type_id = "character",
      oracle_value = "double"
    )
  )

  # Filter before collect
  filter_obs <- dplyr::filter(oo_con, oracle_value < 1L) |> dplyr::collect()
  expect_equal(dim(filter_obs), c(239L, 6L))
  expect_true(all(filter_obs$oracle_value < 1L))

  # Ignoring a file works
  oo_con2 <- connect_target_oracle_output(
    hub_path,
    ignore_files = "target-wk_inc_flu_hosp.csv"
  )
  expect_length(oo_con2$files, 2L)
  expect_false("target-wk_inc_flu_hosp.csv" %in% basename(oo_con2$files))
})

test_that("connect_target_oracle_output works on non-partitioned files in subdirectories (editable copy)", {
  hub_path <- use_example_hub_editable("file")
  oo_path <- validate_target_data_path(hub_path, "oracle-output")
  oo_dat <- arrow::read_csv_arrow(oo_path)
  fs::file_delete(oo_path)

  # Create subdir structure (still non-partitioned)
  oo_dir <- fs::path(hub_path, "target-data", "oracle-output")
  fs::dir_create(oo_dir)
  split(oo_dat, oo_dat$target) |>
    purrr::iwalk(
      ~ {
        target <- gsub(" ", "_", .y, fixed = TRUE)
        fs::dir_create(fs::path(oo_dir, target))
        path <- fs::path(oo_dir, target, paste0("target-", target), ext = "csv")
        .local_safe_overwrite(
          function(path_out) arrow::write_csv_arrow(.x, file = path_out),
          path
        )
      }
    )

  expect_equal(
    fs::dir_ls(oo_dir, recurse = TRUE, type = "file") |>
      fs::path_rel(hub_path) |>
      as.character(),
    c(
      "target-data/oracle-output/wk_flu_hosp_rate/target-wk_flu_hosp_rate.csv",
      "target-data/oracle-output/wk_flu_hosp_rate_category/target-wk_flu_hosp_rate_category.csv",
      "target-data/oracle-output/wk_inc_flu_hosp/target-wk_inc_flu_hosp.csv"
    )
  )

  oo_con <- connect_target_oracle_output(hub_path)
  expect_s3_class(
    oo_con,
    c(
      "target_oracle_output",
      "FileSystemDataset",
      "Dataset",
      "ArrowObject",
      "R6"
    ),
    exact = TRUE
  )
  expect_equal(basename(attr(oo_con, "oo_path")), "oracle-output")
  expect_length(oo_con$files, 3L)
  expect_equal(
    basename(oo_con$files),
    basename(fs::dir_ls(oo_dir, recurse = TRUE, type = "file"))
  )
  expect_equal(
    oo_con$schema$ToString(),
    "location: string\ntarget_end_date: date32[day]\ntarget: string\noutput_type: string\noutput_type_id: string\noracle_value: double"
  )

  all <- dplyr::collect(oo_con)
  expect_equal(dim(all), c(627L, 6L))
  expect_true(
    all[all$output_type_id == "quantile", ]$output_type_id |> is.na() |> all()
  )

  # ignore works
  oo_con2 <- connect_target_oracle_output(
    hub_path,
    ignore_files = "target-wk_inc_flu_hosp.csv"
  )
  expect_length(oo_con2$files, 2L)
  expect_false("target-wk_inc_flu_hosp.csv" %in% basename(oo_con2$files))
})

test_that("connect_target_oracle_output with HIVE-PARTITIONED parquet works (editable copy)", {
  hub_path <- use_example_hub_editable("file")
  oo_path <- validate_target_data_path(hub_path, "oracle-output")
  oo_dat <- arrow::read_csv_arrow(oo_path)
  fs::file_delete(oo_path)

  # Write hive-partitioned by target to parquet
  oo_dir <- fs::path(hub_path, "target-data", "oracle-output")
  fs::dir_create(oo_dir)
  arrow::write_dataset(
    oo_dat,
    oo_dir,
    partitioning = "target",
    format = "parquet"
  )

  expect_equal(
    fs::dir_ls(oo_dir, recurse = TRUE, type = "file") |>
      fs::path_rel(hub_path) |>
      as.character(),
    c(
      "target-data/oracle-output/target=wk%20flu%20hosp%20rate/part-0.parquet",
      "target-data/oracle-output/target=wk%20flu%20hosp%20rate%20category/part-0.parquet",
      "target-data/oracle-output/target=wk%20inc%20flu%20hosp/part-0.parquet"
    )
  )

  oo_con <- connect_target_oracle_output(hub_path)
  expect_s3_class(
    oo_con,
    c(
      "target_oracle_output",
      "FileSystemDataset",
      "Dataset",
      "ArrowObject",
      "R6"
    ),
    exact = TRUE
  )
  expect_equal(basename(attr(oo_con, "oo_path")), "oracle-output")
  expect_length(oo_con$files, 3L)
  expect_equal(
    basename(oo_con$files),
    basename(fs::dir_ls(oo_dir, recurse = TRUE, type = "file"))
  )
  expect_equal(
    oo_con$schema$ToString(),
    "location: string\ntarget_end_date: date32[day]\noutput_type: string\noutput_type_id: string\noracle_value: double\ntarget: string"
  )

  all <- dplyr::collect(oo_con)
  expect_equal(dim(all), c(627L, 6L))
  expect_true(
    all[all$output_type_id == "quantile", ]$output_type_id |> is.na() |> all()
  )
  expect_equal(
    names(all),
    c(
      "location",
      "target_end_date",
      "output_type",
      "output_type_id",
      "oracle_value",
      "target"
    )
  )

  # Demonstrate ignore_files pitfalls with hive partitioning
  oo_con2 <- connect_target_oracle_output(
    hub_path,
    ignore_files = "target=wk%20flu%20hosp%20rate"
  )
  expect_length(oo_con2$files, 1L)

  oo_con3 <- connect_target_oracle_output(
    hub_path,
    ignore_files = "target=wk%20flu%20hosp%20rate/part-0.parquet"
  )
  expect_length(oo_con3$files, 3L)
})

test_that("connect_target_oracle_output works on single-file SubTreeFileSystem (local mirror)", {
  skip_on_os("windows") # SubTreeFileSystem lower-level calls are flaky on Windows

  # Mirror the embedded hub into a temp FS and mount via SubTreeFileSystem
  src <- use_example_hub_readonly("file")
  tmp <- withr::local_tempdir("subtree-hub-")
  fs::dir_copy(src, tmp, overwrite = TRUE)
  loc_fs <- arrow::SubTreeFileSystem$create(tmp)

  # read_config() may expect a standard path; capture and reuse it
  cfg <- read_config(tmp)
  local_mocked_bindings(read_config = function(...) cfg)

  oo_con <- connect_target_oracle_output(loc_fs)
  expect_s3_class(
    oo_con,
    c(
      "target_oracle_output",
      "FileSystemDataset",
      "Dataset",
      "ArrowObject",
      "R6"
    ),
    exact = TRUE
  )
  expect_equal(basename(attr(oo_con, "oo_path")), "oracle-output.csv")
  expect_length(oo_con$files, 1L)
  expect_equal(
    oo_con$schema$ToString(),
    "location: string\ntarget_end_date: date32[day]\ntarget: string\noutput_type: string\noutput_type_id: string\noracle_value: double"
  )

  all <- dplyr::collect(oo_con)
  expect_equal(dim(all), c(627L, 6L))
  expect_true(
    all[all$output_type_id == "quantile", ]$output_type_id |> is.na() |> all()
  )
})

test_that("connect_target_oracle_output works with multi-file SubTreeFileSystem hub", {
  skip_on_os("windows")
  # Skipping the test on windows because the use of lower level
  # SubTreeFileSystem$create() function on windows is throwing unrelated errors
  # related to local paths on windows which are not guaranteed to work:
  # (see https://arrow.apache.org/docs/cpp/api/filesystem.html#subtree-filesystem-wrapper)
  # We've already shown these tests work on linux and macos and on actual s3 cloud hubs
  # with single files.
  # Mirror the embedded hub into a temp FS and mount via SubTreeFileSystem

  # Start from temp copy to fan out multi-file
  src <- system.file("testhubs/v5/target_file", package = "hubUtils")
  tmp_dir <- withr::local_tempdir()
  oo_dir_hub_path <- withr::local_tempdir("subtree-hub-mf-")
  fs::dir_copy(src, oo_dir_hub_path, overwrite = TRUE)

  oo_path <- validate_target_data_path(oo_dir_hub_path, "oracle-output")
  oo_dat <- arrow::read_csv_arrow(oo_path)
  fs::file_delete(oo_path)

  oo_dir <- fs::path(oo_dir_hub_path, "target-data", "oracle-output")
  fs::dir_create(oo_dir)
  split(oo_dat, oo_dat$target) |>
    purrr::iwalk(
      ~ {
        target <- gsub(" ", "_", .y, fixed = TRUE)
        path <- fs::path(oo_dir, paste0("target-", target), ext = "csv")
        .local_safe_overwrite(
          function(path_out) arrow::write_csv_arrow(.x, file = path_out),
          path
        )
      }
    )

  hub_path <- withr::local_tempdir()
  # Create a SubTreeFileSystem hub to mimic cloud hub and copy example hub contents
  # into it
  loc_fs <- arrow::SubTreeFileSystem$create(hub_path)
  arrow::copy_files(oo_dir_hub_path, loc_fs)
  config_tasks <- read_config(hub_path)

  # mock read_config function as it assumes any SubTreeFileSystem hub is an s3 bucket
  # and creates `s3` prefixed paths to URIs.
  local_mocked_bindings(
    read_config = function(...) {
      config_tasks
    }
  )

  # TESTS ====
  # Connect to oracle-output data
  oo_con <- connect_target_oracle_output(loc_fs)
  expect_s3_class(
    oo_con,
    c(
      "target_oracle_output",
      "FileSystemDataset",
      "Dataset",
      "ArrowObject",
      "R6"
    ),
    exact = TRUE
  )

  # Check files opened correctly as oo_path captured correctly
  expect_equal(
    basename(attr(oo_con, "oo_path")),
    "oracle-output"
  )
  expect_length(oo_con$files, 3L)
  expect_equal(
    basename(oo_con$files),
    basename(fs::dir_ls(oo_dir, recurse = TRUE, type = "file"))
  )

  expect_equal(
    oo_con$schema$ToString(),
    "location: string\ntarget_end_date: date32[day]\ntarget: string\noutput_type: string\noutput_type_id: string\noracle_value: double" # nolint: line_length_linter
  )

  # Test the collect method
  all <- dplyr::collect(oo_con)

  expect_equal(dim(all), c(627L, 6L))
  expect_s3_class(all, "tbl_df", exact = FALSE)
  expect_equal(
    names(all),
    c(
      "location",
      "target_end_date",
      "target",
      "output_type",
      "output_type_id",
      "oracle_value"
    )
  )
  expect_true(
    all[all$output_type_id == "quantile", ]$output_type_id |>
      is.na() |>
      all()
  )
  expect_setequal(
    unique(all$location),
    c("US", "01", "02")
  )
  expect_setequal(
    unique(all$target),
    c("wk inc flu hosp", "wk flu hosp rate category", "wk flu hosp rate")
  )
  expect_equal(
    sapply(all, class),
    c(
      location = "character",
      target_end_date = "Date",
      target = "character",
      output_type = "character",
      output_type_id = "character",
      oracle_value = "numeric"
    )
  )
  expect_equal(
    sapply(all, typeof),
    c(
      location = "character",
      target_end_date = "double",
      target = "character",
      output_type = "character",
      output_type_id = "character",
      oracle_value = "double"
    )
  )

  # Filter for a specific date before collecting
  filter_obs <- dplyr::filter(oo_con, oracle_value < 1L) |>
    dplyr::collect()

  expect_equal(dim(filter_obs), c(239L, 6L))
  expect_s3_class(filter_obs, "tbl_df", exact = FALSE)
  expect_equal(
    names(filter_obs),
    c(
      "location",
      "target_end_date",
      "target",
      "output_type",
      "output_type_id",
      "oracle_value"
    )
  )
  expect_true(all(filter_obs$oracle_value < 1L))
  expect_equal(
    sapply(filter_obs, class),
    c(
      location = "character",
      target_end_date = "Date",
      target = "character",
      output_type = "character",
      output_type_id = "character",
      oracle_value = "numeric"
    )
  )
  expect_equal(
    sapply(filter_obs, typeof),
    c(
      location = "character",
      target_end_date = "double",
      target = "character",
      output_type = "character",
      output_type_id = "character",
      oracle_value = "double"
    )
  )
})

test_that('connect_target_oracle_output parses "NA" and "" correctly (editable copy)', {
  hub_path <- use_example_hub_editable("file")
  oo_path <- validate_target_data_path(hub_path, "oracle-output")
  oo_dat <- arrow::read_csv_arrow(oo_path)

  # Introduce literal "NA" text in character column
  oo_dat$location[1] <- "NA"
  .local_safe_overwrite(
    function(path_out) arrow::write_csv_arrow(oo_dat, file = path_out),
    oo_path
  )

  oo_con <- connect_target_oracle_output(hub_path, na = "")
  expect_equal(
    oo_con$schema$ToString(),
    "location: string\ntarget_end_date: date32[day]\ntarget: string\noutput_type: string\noutput_type_id: string\noracle_value: double"
  )
  all <- dplyr::collect(oo_con)
  expect_true(all$location[1] == "NA")
  expect_true(
    all[oo_dat$output_type_id == "", "output_type_id"] |> is.na() |> all()
  )
})

test_that("connect_target_oracle_output output_type_id_datatype arg works", {
  hub_path <- use_example_hub_readonly("file")
  oo_con <- connect_target_oracle_output(
    hub_path,
    output_type_id_datatype = "double"
  )
  expect_equal(
    oo_con$schema$ToString(),
    "location: string\ntarget_end_date: date32[day]\ntarget: string\noutput_type: string\noutput_type_id: double\noracle_value: double"
  )
})
