# Set up test target data hub
if (curl::has_internet()) {
  tmp_dir <- withr::local_tempdir()
  ts_hub_path <- fs::path(tmp_dir, "ts_file")
  ts_dir_hub_path <- fs::path(tmp_dir, "ts_dir")
  example_hub <- "https://github.com/hubverse-org/example-complex-forecast-hub.git"
  gert::git_clone(url = example_hub, path = ts_hub_path)
  fs::dir_copy(ts_hub_path, ts_dir_hub_path)
}

test_that("connect_target_timeseries on single file works on local hub", {
  skip_if_offline()
  # Connect to time-series data
  ts_con <- connect_target_timeseries(ts_hub_path)
  expect_s3_class(ts_con,
    c(
      "target_timeseries", "FileSystemDataset", "Dataset", "ArrowObject",
      "R6"
    ),
    exact = TRUE
  )

  expect_equal(
    basename(attr(ts_con, "ts_path")),
    "time-series.csv"
  )
  expect_length(ts_con$files, 1L)
  # For a single file ts_path attribute will be the same as the single file opened by the connection
  expect_equal(basename(ts_con$files), basename(attr(ts_con, "ts_path")))

  expect_equal(
    ts_con$schema$ToString(),
    "date: date32[day]\ntarget: string\nlocation: string\nobservation: double"
  )

  # Test the collect method
  all <- dplyr::collect(ts_con)

  expect_equal(dim(all), c(20510L, 4L))
  expect_s3_class(all, "tbl_df", exact = FALSE)
  expect_equal(names(all), c("date", "target", "location", "observation"))
  expect_equal(
    unique(all$location),
    c(
      "01", "15", "18", "27", "30", "37", "48", "US", "32", "20",
      "17", "29", "41", "04", "06", "13", "19", "21", "22", "24", "23",
      "26", "28", "38", "31", "34", "39", "40", "42", "72", "45", "51",
      "53", "55", "54", "56", "44", "05", "12", "16", "35", "36", "47",
      "02", "09", "50", "08", "11", "10", "25", "33", "46", "49"
    )
  )
  expect_equal(
    unique(all$target), c("wk inc flu hosp", "wk flu hosp rate")
  )
  expect_equal(
    sapply(all, class),
    c(
      date = "Date", target = "character", location = "character",
      observation = "numeric"
    )
  )
  expect_equal(
    sapply(all, typeof),
    c(
      date = "double", target = "character", location = "character",
      observation = "double"
    )
  )

  # Filter for a specific date before collecting
  filter_date <- dplyr::filter(ts_con, date == "2020-01-11") |>
    dplyr::collect()

  expect_equal(dim(filter_date), c(16L, 4L))
  expect_s3_class(filter_date, "tbl_df", exact = FALSE)
  expect_equal(names(filter_date), c("date", "target", "location", "observation"))
  expect_equal(
    unique(filter_date$location),
    c("01", "15", "18", "27", "30", "37", "48", "US")
  )
  expect_equal(
    unique(filter_date$target), c("wk inc flu hosp", "wk flu hosp rate")
  )
  expect_equal(as.character(unique(filter_date$date)), "2020-01-11")
  expect_equal(
    sapply(filter_date, class),
    c(
      date = "Date", target = "character", location = "character",
      observation = "numeric"
    )
  )
  expect_equal(
    sapply(filter_date, typeof),
    c(
      date = "double", target = "character", location = "character",
      observation = "double"
    )
  )


  # Filter for a specific location before collecting
  filter_location <- dplyr::filter(ts_con, location == "US") |>
    dplyr::collect()

  expect_equal(dim(filter_location), c(402L, 4L))
  expect_s3_class(filter_location, "tbl_df", exact = FALSE)
  expect_equal(names(filter_location), c("date", "target", "location", "observation"))
  expect_equal(unique(filter_location$location), "US")
  expect_equal(length(unique(filter_location$date)), 201L)
  expect_equal(
    sapply(filter_location, class),
    c(
      date = "Date", target = "character", location = "character",
      observation = "numeric"
    )
  )
  expect_equal(
    sapply(filter_location, typeof),
    c(
      date = "double", target = "character", location = "character",
      observation = "double"
    )
  )
})

test_that("connect_target_timeseries fails correctly", {
  skip_if_offline()

  # Test that non-existent hub directory is flagged appropriately
  expect_error(
    connect_target_timeseries("random_path"),
    regexp = "Assertion on 'hub_path' failed: Directory 'random_path' does not exist."
  )

  ts_path <- validate_target_data_path(ts_dir_hub_path, "time-series")

  # Test that multiple files/directories with time-series data are flagged appropriately
  ts_dat <- arrow::read_csv_arrow(ts_path)
  ts_dir <- fs::path(ts_dir_hub_path, "target-data", "time-series")

  fs::dir_create(ts_dir)
  split(ts_dat, ts_dat$target) |> purrr::iwalk(
    ~ {
      target <- gsub(" ", "_", .y)
      path <- file.path(ts_dir, paste0("target-", target, ".csv"))
      arrow::write_csv_arrow(.x, file = path)
    }
  )
  expect_error(connect_target_timeseries(ts_dir_hub_path),
    regexp = "Multiple .*time-series.* data found in hub .*time-series.csv"
  )

  # TEST that multiple file formats flagged appropriately =====================
  fs::dir_delete(ts_dir)
  fs::dir_create(ts_dir)
  # Delete single time-series file to single multiple file/directory error
  fs::file_delete(ts_path)

  # Create two target time-series files with diffent formats
  split(ts_dat, ts_dat$target) |> purrr::iwalk(
    ~ {
      target <- gsub(" ", "_", .y)
      ext <- if (target == "wk_flu_hosp_rate") "csv" else "parquet"
      path <- fs::path(ts_dir, paste0("target-", target), ext = ext)
      if (ext == "parquet") {
        arrow::write_parquet(.x, path)
      } else {
        arrow::write_csv_arrow(.x, file = path)
      }
    }
  )
  expect_error(connect_target_timeseries(ts_dir_hub_path),
    regexp = "Multiple data file formats .*csv.* and .*parquet"
  )

  # TEST when no time-series data found in target-data directory ================
  fs::dir_delete(ts_dir)
  expect_error(connect_target_timeseries(ts_dir_hub_path),
    regexp = "No .*time-series.* data found in .*target-data.* directory"
  )
})

test_that("connect_target_timeseries on multiple non-partitioned files works on local hub", {
  skip_if_offline()
  fs::dir_delete(ts_dir_hub_path)
  fs::dir_copy(ts_hub_path, ts_dir_hub_path)
  ts_path <- validate_target_data_path(ts_dir_hub_path, "time-series")
  # Read timeseries data from single file
  ts_dat <- arrow::read_csv_arrow(ts_path)
  # Delete single time-series file in preparation for creating time-series directory
  fs::file_delete(ts_path)

  # Create a seperate file for each target in a time-series directory
  ts_dir <- fs::path(ts_dir_hub_path, "target-data", "time-series")
  fs::dir_create(ts_dir)
  split(ts_dat, ts_dat$target) |> purrr::iwalk(
    ~ {
      target <- gsub(" ", "_", .y)
      path <- file.path(ts_dir, paste0("target-", target, ".csv"))
      arrow::write_csv_arrow(.x, file = path)
    }
  )

  # TESTS ====
  # Connect to time-series data
  ts_con <- connect_target_timeseries(ts_dir_hub_path)
  expect_s3_class(ts_con,
    c(
      "target_timeseries", "FileSystemDataset", "Dataset", "ArrowObject",
      "R6"
    ),
    exact = TRUE
  )

  # Check files opened correctly as ts_path captured correctly
  expect_equal(
    basename(attr(ts_con, "ts_path")),
    "time-series"
  )
  expect_length(ts_con$files, 2L)
  expect_equal(
    basename(ts_con$files),
    basename(fs::dir_ls(ts_dir, recurse = TRUE, type = "file"))
  )

  expect_equal(
    ts_con$schema$ToString(),
    "date: date32[day]\ntarget: string\nlocation: string\nobservation: double"
  )

  # Test the collect method
  all <- dplyr::collect(ts_con)

  expect_equal(dim(all), c(20510L, 4L))
  expect_s3_class(all, "tbl_df", exact = FALSE)
  expect_equal(names(all), c("date", "target", "location", "observation"))
  expect_equal(
    unique(all$location),
    c(
      "01", "15", "18", "27", "30", "37", "48", "US", "32", "20",
      "17", "29", "41", "04", "06", "13", "19", "21", "22", "24", "23",
      "26", "28", "38", "31", "34", "39", "40", "42", "72", "45", "51",
      "53", "55", "54", "56", "44", "05", "12", "16", "35", "36", "47",
      "02", "09", "50", "08", "11", "10", "25", "33", "46", "49"
    )
  )
  expect_equal(
    unique(all$target), c("wk flu hosp rate", "wk inc flu hosp")
  )
  expect_equal(
    sapply(all, class),
    c(
      date = "Date", target = "character", location = "character",
      observation = "numeric"
    )
  )
  expect_equal(
    sapply(all, typeof),
    c(
      date = "double", target = "character", location = "character",
      observation = "double"
    )
  )

  # Filter for a specific date before collecting
  filter_obs <- dplyr::filter(ts_con, observation < 1L) |>
    dplyr::collect()

  expect_equal(dim(filter_obs), c(12229L, 4L))
  expect_s3_class(filter_obs, "tbl_df", exact = FALSE)
  expect_equal(names(filter_obs), c("date", "target", "location", "observation"))
  expect_true(all(filter_obs$observation < 1L))
  expect_equal(
    sapply(filter_obs, class),
    c(
      date = "Date", target = "character", location = "character",
      observation = "numeric"
    )
  )
  expect_equal(
    sapply(filter_obs, typeof),
    c(
      date = "double", target = "character", location = "character",
      observation = "double"
    )
  )
})

test_that("connect_target_timeseries works on local multi-file timeseries data with sub directory structure", {
  skip_if_offline()
  fs::dir_delete(ts_dir_hub_path)
  fs::dir_copy(ts_hub_path, ts_dir_hub_path)
  ts_path <- validate_target_data_path(ts_dir_hub_path, "time-series")
  # Read timeseries data from single file
  ts_dat <- arrow::read_csv_arrow(ts_path)
  # Delete single time-series file in preparation for creating time-series directory
  fs::file_delete(ts_path)

  ## Create NON-PARTTIONED timeseries data with sub directory structure ===========
  ts_dir <- fs::path(ts_dir_hub_path, "target-data", "time-series")
  fs::dir_create(ts_dir)

  split(ts_dat, ts_dat$target) |> purrr::iwalk(
    ~ {
      target <- gsub(" ", "_", .y)
      # Create subdirecties within `time-series` directory that do not contain
      # data in the directory names, i.e. the data files within them contain all
      # columns
      fs::dir_create(file.path(ts_dir, target))
      path <- file.path(ts_dir, target, paste0("target-", target, ".csv"))
      arrow::write_csv_arrow(.x, file = path)
    }
  )
  expect_equal(
    fs::dir_ls(ts_dir, recurse = TRUE, type = "file") |>
      fs::path_rel(ts_dir_hub_path) |>
      as.character(),
    c(
      "target-data/time-series/wk_flu_hosp_rate/target-wk_flu_hosp_rate.csv",
      "target-data/time-series/wk_inc_flu_hosp/target-wk_inc_flu_hosp.csv"
    )
  )
  ts_con <- connect_target_timeseries(ts_dir_hub_path)
  expect_s3_class(ts_con,
    c(
      "target_timeseries", "FileSystemDataset", "Dataset", "ArrowObject",
      "R6"
    ),
    exact = TRUE
  )

  # Check files opened correctly as ts_path captured correctly
  expect_equal(
    basename(attr(ts_con, "ts_path")),
    "time-series"
  )
  expect_length(ts_con$files, 2L)
  expect_equal(
    basename(ts_con$files),
    basename(fs::dir_ls(ts_dir, recurse = TRUE, type = "file"))
  )

  expect_equal(
    ts_con$schema$ToString(),
    "date: date32[day]\ntarget: string\nlocation: string\nobservation: double"
  )

  # Test the collect method
  all <- dplyr::collect(ts_con)

  expect_equal(dim(all), c(20510L, 4L))
  expect_s3_class(all, "tbl_df", exact = FALSE)
  expect_equal(names(all), c("date", "target", "location", "observation"))
  expect_equal(
    sapply(all, typeof),
    c(
      date = "double", target = "character", location = "character",
      observation = "double"
    )
  )
  expect_equal(
    sapply(all, class),
    c(
      date = "Date", target = "character", location = "character",
      observation = "numeric"
    )
  )
})

test_that("connect_target_timeseries on HIVE-PARTTIONED timeseries data works on local hub", {
  skip_if_offline()
  fs::dir_delete(ts_dir_hub_path)
  fs::dir_copy(ts_hub_path, ts_dir_hub_path)
  ts_path <- validate_target_data_path(ts_dir_hub_path, "time-series")
  # Read timeseries data from single file
  ts_dat <- arrow::read_csv_arrow(ts_path)
  # Delete single time-series file in preparation for creating time-series directory
  fs::file_delete(ts_path)

  # Create hive partitioned timeseries data by target
  ts_dir <- fs::path(ts_dir_hub_path, "target-data", "time-series")
  fs::dir_create(ts_dir)

  arrow::write_dataset(ts_dat, ts_dir, partitioning = "target", format = "parquet")
  expect_equal(
    fs::dir_ls(ts_dir, recurse = TRUE, type = "file") |>
      fs::path_rel(ts_dir_hub_path) |>
      as.character(),
    c(
      "target-data/time-series/target=wk%20flu%20hosp%20rate/part-0.parquet",
      "target-data/time-series/target=wk%20inc%20flu%20hosp/part-0.parquet"
    )
  )
  ts_con <- connect_target_timeseries(ts_dir_hub_path)
  expect_s3_class(ts_con,
    c(
      "target_timeseries", "FileSystemDataset", "Dataset", "ArrowObject",
      "R6"
    ),
    exact = TRUE
  )

  # Check files opened correctly as ts_path captured correctly
  expect_equal(
    basename(attr(ts_con, "ts_path")),
    "time-series"
  )
  expect_length(ts_con$files, 2L)
  expect_equal(
    basename(ts_con$files),
    basename(fs::dir_ls(ts_dir, recurse = TRUE, type = "file"))
  )

  expect_equal(
    ts_con$schema$ToString(),
    "date: date32[day]\nlocation: string\nobservation: double\ntarget: string"
  )
  # Test the collect method
  all <- dplyr::collect(ts_con)

  expect_equal(dim(all), c(20510L, 4L))
  expect_s3_class(all, "tbl_df", exact = FALSE)
  expect_equal(names(all), c("date", "location", "observation", "target"))
  expect_equal(
    sapply(all, class),
    c(
      date = "Date", location = "character", observation = "numeric",
      target = "character"
    )
  )
  expect_equal(
    sapply(all, typeof),
    c(
      date = "double", location = "character", observation = "double",
      target = "character"
    )
  )
})
