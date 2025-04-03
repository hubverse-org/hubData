# Set up test target data hub
if (curl::has_internet()) {
  tmp_dir <- withr::local_tempdir()
  oo_hub_path <- fs::path(tmp_dir, "oo_file")
  oo_dir_hub_path <- fs::path(tmp_dir, "oo_dir")
  example_hub <- "https://github.com/hubverse-org/example-complex-forecast-hub.git"
  gert::git_clone(url = example_hub, path = oo_hub_path)
  fs::dir_copy(oo_hub_path, oo_dir_hub_path)
}

test_that("connect_target_oracle_output on single file works on local hub", {
  skip_if_offline()
  # Connect to oracle-output data
  oo_con <- connect_target_oracle_output(oo_hub_path)
  expect_s3_class(oo_con,
    c(
      "target_oracle_output", "FileSystemDataset", "Dataset", "ArrowObject",
      "R6"
    ),
    exact = TRUE
  )

  expect_equal(
    basename(attr(oo_con, "oo_path")),
    "oracle-output.csv"
  )
  expect_length(oo_con$files, 1L)
  # For a single file oo_path attribute will be the same as the single file opened by the connection
  expect_equal(basename(oo_con$files), basename(attr(oo_con, "oo_path")))

  expect_equal(
    oo_con$schema$ToString(),
    "location: string\ntarget_end_date: date32[day]\ntarget: string\noutput_type: string\noutput_type_id: string\noracle_value: double" # nolint: line_length_linter
  )

  # Test the collect method
  all <- dplyr::collect(oo_con)

  expect_equal(dim(all), c(200340L, 6L))
  expect_s3_class(all, "tbl_df", exact = FALSE)
  expect_true(all[all$output_type_id == "quantile", ]$output_type_id |> is.na() |> all())
  expect_equal(names(all), c(
    "location", "target_end_date", "target",
    "output_type", "output_type_id", "oracle_value"
  ))
  expect_equal(
    unique(all$location),
    c(
      "US", "01", "02", "04", "05", "06", "08", "09", "10", "11",
      "12", "13", "15", "16", "17", "18", "19", "20", "21", "22", "23",
      "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34",
      "35", "36", "37", "38", "39", "40", "41", "42", "44", "45", "46",
      "47", "48", "49", "50", "51", "53", "54", "55", "56", "72"
    )
  )
  expect_equal(
    unique(all$target), c(
      "wk inc flu hosp",
      "wk flu hosp rate category",
      "wk flu hosp rate"
    )
  )
  expect_equal(
    sapply(all, class),
    c(
      location = "character", target_end_date = "Date", target = "character",
      output_type = "character", output_type_id = "character", oracle_value = "numeric"
    )
  )
  expect_equal(
    sapply(all, typeof),
    c(
      location = "character", target_end_date = "double", target = "character",
      output_type = "character", output_type_id = "character", oracle_value = "double"
    )
  )

  # Filter for a specific date before collecting
  filter_date <- dplyr::filter(oo_con, target_end_date == "2022-11-12") |>
    dplyr::collect()

  expect_equal(dim(filter_date), c(5724L, 6L))
  expect_s3_class(filter_date, "tbl_df", exact = FALSE)
  expect_equal(
    names(filter_date),
    c(
      "location", "target_end_date",
      "target", "output_type", "output_type_id",
      "oracle_value"
    )
  )
  expect_true(
    filter_date[filter_date$output_type_id == "quantile", ]$output_type_id |>
      is.na() |>
      all()
  )
  expect_equal(
    unique(filter_date$location),
    c(
      "US", "01", "02", "04", "05", "06", "08", "09", "10", "11",
      "12", "13", "15", "16", "17", "18", "19", "20", "21", "22", "23",
      "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34",
      "35", "36", "37", "38", "39", "40", "41", "42", "44", "45", "46",
      "47", "48", "49", "50", "51", "53", "54", "55", "56", "72"
    )
  )
  expect_equal(
    unique(filter_date$target), c(
      "wk inc flu hosp",
      "wk flu hosp rate category",
      "wk flu hosp rate"
    )
  )
  expect_equal(as.character(unique(filter_date$target_end_date)), "2022-11-12")
  expect_equal(
    sapply(filter_date, class),
    c(
      location = "character", target_end_date = "Date", target = "character",
      output_type = "character", output_type_id = "character", oracle_value = "numeric"
    )
  )
  expect_equal(
    sapply(filter_date, typeof),
    c(
      location = "character", target_end_date = "double", target = "character",
      output_type = "character", output_type_id = "character", oracle_value = "double"
    )
  )


  # Filter for a specific location before collecting
  filter_location <- dplyr::filter(oo_con, location == "US") |>
    dplyr::collect()

  expect_equal(dim(filter_location), c(3780L, 6L))
  expect_s3_class(filter_location, "tbl_df", exact = FALSE)
  expect_equal(
    names(filter_location),
    c(
      "location", "target_end_date", "target", "output_type",
      "output_type_id", "oracle_value"
    )
  )
  expect_equal(unique(filter_location$location), "US")
  expect_true(
    filter_location[filter_location$output_type_id == "quantile", ]$output_type_id |>
      is.na() |>
      all()
  )
  expect_equal(length(unique(filter_location$target_end_date)), 35L)
  expect_equal(
    sapply(filter_location, class),
    c(
      location = "character", target_end_date = "Date", target = "character",
      output_type = "character", output_type_id = "character", oracle_value = "numeric"
    )
  )
  expect_equal(
    sapply(filter_location, typeof),
    c(
      location = "character", target_end_date = "double", target = "character",
      output_type = "character", output_type_id = "character", oracle_value = "double"
    )
  )
})

test_that("connect_target_oracle_output fails correctly", {
  skip_if_offline()

  # Test that non-existent hub directory is flagged appropriately
  expect_error(
    connect_target_oracle_output("random_path"),
    regexp = "Assertion on 'target_data_path' failed: Directory 'random_path/target-data' does not exist."
  )

  oo_path <- validate_target_data_path(oo_dir_hub_path, "oracle-output")

  # Test that multiple files/directories with oracle-output data are flagged appropriately
  oo_dat <- arrow::read_csv_arrow(oo_path)
  oo_dir <- fs::path(oo_dir_hub_path, "target-data", "oracle-output")

  fs::dir_create(oo_dir)
  split(oo_dat, oo_dat$target) |> purrr::iwalk(
    ~ {
      target <- gsub(" ", "_", .y)
      path <- file.path(oo_dir, paste0("target-", target, ".csv"))
      arrow::write_csv_arrow(.x, file = path)
    }
  )
  expect_error(connect_target_oracle_output(oo_dir_hub_path),
    regexp = "Multiple .*oracle-output.* data found in hub .*oracle-output.csv"
  )

  # TEST that multiple file formats flagged appropriately =====================
  fs::dir_delete(oo_dir)
  fs::dir_create(oo_dir)
  # Delete single oracle-output file to single multiple file/directory error
  fs::file_delete(oo_path)

  # Create two target oracle-output files with diffent formats
  split(oo_dat, oo_dat$target) |> purrr::iwalk(
    ~ {
      target <- gsub(" ", "_", .y)
      ext <- if (target == "wk_flu_hosp_rate") "csv" else "parquet"
      path <- fs::path(oo_dir, paste0("target-", target), ext = ext)
      if (ext == "parquet") {
        arrow::write_parquet(.x, path)
      } else {
        arrow::write_csv_arrow(.x, file = path)
      }
    }
  )
  expect_error(connect_target_oracle_output(oo_dir_hub_path),
    regexp = "Multiple data file formats .*csv.* and .*parquet"
  )

  # TEST when no oracle-output data found in target-data directory ================
  fs::dir_delete(oo_dir)
  expect_error(connect_target_oracle_output(oo_dir_hub_path),
    regexp = "No .*oracle-output.* data found in .*target-data.* directory"
  )
})

test_that("connect_target_oracle_output on multiple non-partitioned files works on local hub", {
  skip_if_offline()
  fs::dir_delete(oo_dir_hub_path)
  fs::dir_copy(oo_hub_path, oo_dir_hub_path)
  oo_path <- validate_target_data_path(oo_dir_hub_path, "oracle-output")
  # Read oracle_output data from single file
  oo_dat <- arrow::read_csv_arrow(oo_path)
  # Delete single oracle-output file in preparation for creating oracle-output directory
  fs::file_delete(oo_path)

  # Create a seperate file for each target in a oracle-output directory
  oo_dir <- fs::path(oo_dir_hub_path, "target-data", "oracle-output")
  fs::dir_create(oo_dir)
  split(oo_dat, oo_dat$target) |> purrr::iwalk(
    ~ {
      target <- gsub(" ", "_", .y)
      path <- file.path(oo_dir, paste0("target-", target, ".csv"))
      arrow::write_csv_arrow(.x, file = path)
    }
  )

  # TESTS ====
  # Connect to oracle-output data
  oo_con <- connect_target_oracle_output(oo_dir_hub_path)
  expect_s3_class(oo_con,
    c(
      "target_oracle_output", "FileSystemDataset", "Dataset", "ArrowObject",
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

  expect_equal(dim(all), c(200340L, 6L))
  expect_s3_class(all, "tbl_df", exact = FALSE)
  expect_equal(names(all), c("location", "target_end_date", "target", "output_type", "output_type_id", "oracle_value"))
  expect_true(all[all$output_type_id == "quantile", ]$output_type_id |> is.na() |> all())
  expect_equal(
    unique(all$location),
    c(
      "US", "01", "02", "04", "05", "06", "08", "09", "10", "11",
      "12", "13", "15", "16", "17", "18", "19", "20", "21", "22", "23",
      "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34",
      "35", "36", "37", "38", "39", "40", "41", "42", "44", "45", "46",
      "47", "48", "49", "50", "51", "53", "54", "55", "56", "72"
    )
  )
  expect_equal(
    unique(all$target), c(
      "wk flu hosp rate",
      "wk flu hosp rate category",
      "wk inc flu hosp"
    )
  )
  expect_equal(
    sapply(all, class),
    c(
      location = "character", target_end_date = "Date", target = "character",
      output_type = "character", output_type_id = "character", oracle_value = "numeric"
    )
  )
  expect_equal(
    sapply(all, typeof),
    c(
      location = "character", target_end_date = "double", target = "character",
      output_type = "character", output_type_id = "character", oracle_value = "double"
    )
  )

  # Filter for a specific oracle_value before collecting
  filter_obs <- dplyr::filter(oo_con, oracle_value < 1L) |>
    dplyr::collect()

  expect_equal(dim(filter_obs), c(19535L, 6L))
  expect_s3_class(filter_obs, "tbl_df", exact = FALSE)
  expect_equal(
    names(filter_obs),
    c(
      "location", "target_end_date", "target", "output_type",
      "output_type_id", "oracle_value"
    )
  )
  expect_true(all(filter_obs$oracle_value < 1L))
  expect_true(
    filter_obs[filter_obs$output_type_id == "quantile", ]$output_type_id |>
      is.na() |>
      all()
  )
  expect_equal(
    sapply(filter_obs, class),
    c(
      location = "character", target_end_date = "Date", target = "character",
      output_type = "character", output_type_id = "character", oracle_value = "numeric"
    )
  )
  expect_equal(
    sapply(filter_obs, typeof),
    c(
      location = "character", target_end_date = "double", target = "character",
      output_type = "character", output_type_id = "character", oracle_value = "double"
    )
  )
})

test_that("connect_target_oracle_output works on local multi-file oracle_output data with sub directory structure", {
  skip_if_offline()
  fs::dir_delete(oo_dir_hub_path)
  fs::dir_copy(oo_hub_path, oo_dir_hub_path)
  oo_path <- validate_target_data_path(oo_dir_hub_path, "oracle-output")
  # Read oracle_output data from single file
  oo_dat <- arrow::read_csv_arrow(oo_path)
  # Delete single oracle-output file in preparation for creating oracle-output directory
  fs::file_delete(oo_path)

  ## Create NON-PARTTIONED oracle_output data with sub directory structure ===========
  oo_dir <- fs::path(oo_dir_hub_path, "target-data", "oracle-output")
  fs::dir_create(oo_dir)

  split(oo_dat, oo_dat$target) |> purrr::iwalk(
    ~ {
      target <- gsub(" ", "_", .y)
      # Create subdirecties within `oracle-output` directory that do not contain
      # data in the directory names, i.e. the data files within them contain all
      # columns
      fs::dir_create(file.path(oo_dir, target))
      path <- file.path(oo_dir, target, paste0("target-", target, ".csv"))
      arrow::write_csv_arrow(.x, file = path)
    }
  )
  expect_equal(
    fs::dir_ls(oo_dir, recurse = TRUE, type = "file") |>
      fs::path_rel(oo_dir_hub_path) |>
      as.character(),
    c(
      "target-data/oracle-output/wk_flu_hosp_rate/target-wk_flu_hosp_rate.csv",
      "target-data/oracle-output/wk_flu_hosp_rate_category/target-wk_flu_hosp_rate_category.csv",
      "target-data/oracle-output/wk_inc_flu_hosp/target-wk_inc_flu_hosp.csv"
    )
  )
  oo_con <- connect_target_oracle_output(oo_dir_hub_path)
  expect_s3_class(oo_con,
    c(
      "target_oracle_output", "FileSystemDataset", "Dataset", "ArrowObject",
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

  expect_equal(dim(all), c(200340L, 6L))
  expect_s3_class(all, "tbl_df", exact = FALSE)
  expect_true(all[all$output_type_id == "quantile", ]$output_type_id |> is.na() |> all())
  expect_equal(names(all), c("location", "target_end_date", "target", "output_type", "output_type_id", "oracle_value"))
  expect_equal(
    sapply(all, typeof),
    c(
      location = "character", target_end_date = "double", target = "character",
      output_type = "character", output_type_id = "character", oracle_value = "double"
    )
  )
  expect_equal(
    sapply(all, class),
    c(
      location = "character", target_end_date = "Date", target = "character",
      output_type = "character", output_type_id = "character", oracle_value = "numeric"
    )
  )
})

test_that("connect_target_oracle_output with HIVE-PARTTIONED data works on local hub", {
  skip_if_offline()
  fs::dir_delete(oo_dir_hub_path)
  fs::dir_copy(oo_hub_path, oo_dir_hub_path)
  oo_path <- validate_target_data_path(oo_dir_hub_path, "oracle-output")
  # Read oracle_output data from single file
  oo_dat <- arrow::read_csv_arrow(oo_path)
  # Delete single oracle-output file in preparation for creating oracle-output directory
  fs::file_delete(oo_path)

  # Create hive partitioned oracle_output data by target
  oo_dir <- fs::path(oo_dir_hub_path, "target-data", "oracle-output")
  fs::dir_create(oo_dir)

  arrow::write_dataset(oo_dat, oo_dir, partitioning = "target", format = "parquet")
  expect_equal(
    fs::dir_ls(oo_dir, recurse = TRUE, type = "file") |>
      fs::path_rel(oo_dir_hub_path) |>
      as.character(),
    c(
      "target-data/oracle-output/target=wk%20flu%20hosp%20rate/part-0.parquet",
      "target-data/oracle-output/target=wk%20flu%20hosp%20rate%20category/part-0.parquet",
      "target-data/oracle-output/target=wk%20inc%20flu%20hosp/part-0.parquet"
    )
  )
  oo_con <- connect_target_oracle_output(oo_dir_hub_path)
  expect_s3_class(oo_con,
    c(
      "target_oracle_output", "FileSystemDataset", "Dataset", "ArrowObject",
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
    "location: string\ntarget_end_date: date32[day]\noutput_type: string\noutput_type_id: string\noracle_value: double\ntarget: string" # nolint: line_length_linter
  )
  # Test the collect method
  all <- dplyr::collect(oo_con)

  expect_equal(dim(all), c(200340L, 6L))
  expect_s3_class(all, "tbl_df", exact = FALSE)
  expect_true(all[all$output_type_id == "quantile", ]$output_type_id |> is.na() |> all())
  expect_equal(names(all), c(
    "location", "target_end_date", "output_type", "output_type_id",
    "oracle_value", "target"
  ))
  expect_equal(
    sapply(all, class),
    c(
      location = "character", target_end_date = "Date", output_type = "character",
      output_type_id = "character", oracle_value = "numeric", target = "character"
    )
  )
  expect_equal(
    sapply(all, typeof),
    c(
      location = "character", target_end_date = "double", output_type = "character",
      output_type_id = "character", oracle_value = "double", target = "character"
    )
  )
})


test_that(
  "connect_target_oracle_output works on single-file S3 SubTreeFileSystem hub",
  {
    skip_if_offline()
    hub_path <- s3_bucket("example-complex-forecast-hub")
    oo_con <- connect_target_oracle_output(hub_path)

    expect_s3_class(oo_con,
      c(
        "target_oracle_output", "FileSystemDataset", "Dataset", "ArrowObject",
        "R6"
      ),
      exact = TRUE
    )

    # Check files opened correctly as oo_path captured correctly
    expect_equal(
      basename(attr(oo_con, "oo_path")),
      "oracle-output.csv"
    )
    expect_equal(
      attr(oo_con, "hub_path"),
      "s3://example-complex-forecast-hub"
    )
    expect_length(oo_con$files, 1L)

    expect_equal(
      oo_con$schema$ToString(),
      "location: string\ntarget_end_date: date32[day]\ntarget: string\noutput_type: string\noutput_type_id: string\noracle_value: double" # nolint: line_length_linter
    )
    # Test the collect method
    all <- dplyr::collect(oo_con)

    expect_equal(dim(all), c(200340L, 6L))
    expect_s3_class(all, "tbl_df", exact = FALSE)
    expect_equal(
      names(all),
      c(
        "location", "target_end_date", "target", "output_type",
        "output_type_id", "oracle_value"
      )
    )
    expect_true(all[all$output_type_id == "quantile", ]$output_type_id |> is.na() |> all())
    expect_equal(
      sapply(all, class),
      c(
        location = "character", target_end_date = "Date", target = "character",
        output_type = "character", output_type_id = "character", oracle_value = "numeric"
      )
    )
    expect_equal(
      sapply(all, typeof),
      c(
        location = "character", target_end_date = "double", target = "character",
        output_type = "character", output_type_id = "character", oracle_value = "double"
      )
    )
  }
)

test_that(
  "connect_target_oracle_output works with multi-file SubTreeFileSystem hub",
  {
    skip_if_offline()
    skip_on_os("windows")
    # Skipping the test on windows because the use of lower level
    # SubTreeFileSystem$create() function on windows is throwing unrelated errors
    # related to local paths on windows which are not guaranteed to work:
    # (see https://arrow.apache.org/docs/cpp/api/filesystem.html#subtree-filesystem-wrapper)
    # We've already shown these tests work on linux and macos and on actual s3 cloud hubs
    # with single files.

    fs::dir_delete(oo_dir_hub_path)
    fs::dir_copy(oo_hub_path, oo_dir_hub_path)
    oo_path <- validate_target_data_path(oo_dir_hub_path, "oracle-output")
    # Read oracle_output data from single file
    oo_dat <- arrow::read_csv_arrow(oo_path)
    # Delete single oracle-output file in preparation for creating oracle-output directory
    fs::file_delete(oo_path)

    # Create a separate file for each target in a oracle-output directory
    oo_dir <- fs::path(oo_dir_hub_path, "target-data", "oracle-output")
    fs::dir_create(oo_dir)
    split(oo_dat, oo_dat$target) |> purrr::iwalk(
      ~ {
        target <- gsub(" ", "_", .y)
        path <- file.path(oo_dir, paste0("target-", target, ".csv"))
        arrow::write_csv_arrow(.x, file = path)
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
    expect_s3_class(oo_con,
      c(
        "target_oracle_output", "FileSystemDataset", "Dataset", "ArrowObject",
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

    expect_equal(dim(all), c(200340L, 6L))
    expect_s3_class(all, "tbl_df", exact = FALSE)
    expect_equal(
      names(all),
      c(
        "location", "target_end_date", "target", "output_type",
        "output_type_id", "oracle_value"
      )
    )
    expect_true(
      all[all$output_type_id == "quantile", ]$output_type_id |>
        is.na() |>
        all()
    )
    expect_setequal(
      unique(all$location),
      c(
        "01", "15", "18", "27", "30", "37", "48", "US", "32", "20",
        "17", "29", "41", "04", "06", "13", "19", "21", "22", "24", "23",
        "26", "28", "38", "31", "34", "39", "40", "42", "72", "45", "51",
        "53", "55", "54", "56", "44", "05", "12", "16", "35", "36", "47",
        "02", "09", "50", "08", "11", "10", "25", "33", "46", "49"
      )
    )
    expect_setequal(
      unique(all$target), c("wk inc flu hosp", "wk flu hosp rate category", "wk flu hosp rate")
    )
    expect_equal(
      sapply(all, class),
      c(
        location = "character", target_end_date = "Date", target = "character",
        output_type = "character", output_type_id = "character", oracle_value = "numeric"
      )
    )
    expect_equal(
      sapply(all, typeof),
      c(
        location = "character", target_end_date = "double", target = "character",
        output_type = "character", output_type_id = "character", oracle_value = "double"
      )
    )

    # Filter for a specific date before collecting
    filter_obs <- dplyr::filter(oo_con, oracle_value < 1L) |>
      dplyr::collect()

    expect_equal(dim(filter_obs), c(19535L, 6L))
    expect_s3_class(filter_obs, "tbl_df", exact = FALSE)
    expect_equal(names(filter_obs), c(
      "location", "target_end_date",
      "target", "output_type", "output_type_id",
      "oracle_value"
    ))
    expect_true(all(filter_obs$oracle_value < 1L))
    expect_equal(
      sapply(filter_obs, class),
      c(
        location = "character", target_end_date = "Date", target = "character",
        output_type = "character", output_type_id = "character", oracle_value = "numeric"
      )
    )
    expect_equal(
      sapply(filter_obs, typeof),
      c(
        location = "character", target_end_date = "double", target = "character",
        output_type = "character", output_type_id = "character", oracle_value = "double"
      )
    )
  }
)

test_that(
  'connect_target_timeseries parses "NA" and "" correctly',
  {
    skip_if_offline()
    oo_na_hub_path <- fs::path(tmp_dir, "oo_na_file")
    fs::dir_copy(oo_hub_path, oo_na_hub_path)
    oo_path <- validate_target_data_path(oo_na_hub_path, "oracle-output")
    # Read oracle_output data from single file
    oo_dat <- arrow::read_csv_arrow(oo_path)

    # Introduce character "NA" value
    oo_dat$location[1] <- "NA"
    # Write NAs out as blank strings
    readr::write_csv(oo_dat, oo_path, na = "")

    oo_con <- connect_target_oracle_output(oo_na_hub_path, na = "")
    expect_equal(
      oo_con$schema$ToString(),
      "location: string\ntarget_end_date: date32[day]\ntarget: string\noutput_type: string\noutput_type_id: string\noracle_value: double" # nolint: line_length_linter
    )
    all <- dplyr::collect(oo_con)
    expect_true(all$location[1] == "NA")
    expect_true(
      all[oo_dat$output_type_id == "", "output_type_id"] |>
        is.na() |>
        all()
    )
  }
)
