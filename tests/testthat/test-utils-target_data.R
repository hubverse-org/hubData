# Tests for get_target_path using embedded example hubs
# Requires helper-v5-hubs.R with:
# - use_example_hub_readonly()
# - use_example_hub_editable()

test_that("get_target_path works on embedded hub (local paths)", {
  hub_path <- use_example_hub_readonly("file")

  expect_equal(
    basename(get_target_path(hub_path)),
    "time-series.csv"
  )
  expect_equal(
    basename(get_target_path(hub_path, "oracle-output")),
    "oracle-output.csv"
  )
})

test_that("get_target_path ignores misleading filenames around target_type", {
  hub_path <- use_example_hub_editable("file")

  # Add files whose names *contain* the token but aren't exact matches
  td <- fs::path(hub_path, "target-data")
  arrow::write_csv_arrow(
    data.frame(a = 1:3),
    fs::path(td, "showtime-series.csv")
  )
  arrow::write_csv_arrow(data.frame(a = 1:3), fs::path(td, "time-seriesss.csv"))
  arrow::write_csv_arrow(
    data.frame(a = 1:3),
    fs::path(td, "pre-oracle-output.csv")
  )
  arrow::write_csv_arrow(
    data.frame(a = 1:3),
    fs::path(td, "oracle-output-v2.csv")
  )

  # Should still find the canonical files
  expect_equal(
    basename(get_target_path(hub_path)),
    "time-series.csv"
  )
  expect_equal(
    basename(get_target_path(hub_path, "oracle-output")),
    "oracle-output.csv"
  )
})

test_that("get_target_path works with SubTreeFileSystem mirror (no network)", {
  # Mirror the embedded hub into a temp FS and mount via SubTreeFileSystem
  src <- use_example_hub_readonly("file")
  tmp <- withr::local_tempdir("subtree-gtt-")
  fs::dir_copy(src, tmp, overwrite = TRUE)
  loc_fs <- arrow::SubTreeFileSystem$create(tmp)

  # The method for SubTreeFileSystem should resolve the canonical targets
  expect_equal(
    basename(get_target_path(loc_fs)),
    "time-series.csv"
  )
  expect_equal(
    basename(get_target_path(loc_fs, "oracle-output")),
    "oracle-output.csv"
  )
})

# Tests for get_target_data_colnames
test_that("get_target_data_colnames works for time-series", {
  hub_path <- system.file("testhubs/v6/target_file", package = "hubUtils")

  config_target_data <- hubUtils::read_config(hub_path, "target-data")

  colnames <- get_target_data_colnames(
    config_target_data,
    target_type = "time-series"
  )

  # Based on the test hub config, observable_unit is:
  # ["target_end_date", "target", "location"]
  # date_col is "target_end_date" (already in observable_unit)
  # versioned is FALSE
  # no non_task_id_schema
  # Expected order: date_col first, then other task IDs (unique removes duplicate), observation
  expect_equal(
    colnames,
    c("target_end_date", "target", "location", "observation")
  )
})

test_that("get_target_data_colnames works for oracle-output with output_type_ids", {
  hub_path <- system.file("testhubs/v6/target_file", package = "hubUtils")

  config_target_data <- hubUtils::read_config(hub_path, "target-data")

  colnames <- get_target_data_colnames(
    config_target_data,
    target_type = "oracle-output"
  )

  # Based on the test hub config:
  # observable_unit is ["target_end_date", "target", "location"]
  # date_col is "target_end_date"
  # has_output_type_ids is TRUE
  # versioned is FALSE
  # Expected order: date_col first, then other task IDs, output_type, output_type_id, oracle_value
  expect_equal(
    colnames,
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

test_that("get_target_data_colnames includes as_of for versioned time-series", {
  # Create a mock config with versioned = TRUE
  config_target_data <- list(
    observable_unit = c("target_end_date", "location"),
    date_col = "target_end_date",
    versioned = TRUE
  )
  class(config_target_data) <- c("config", "list")

  colnames <- get_target_data_colnames(
    config_target_data,
    target_type = "time-series"
  )

  # Expected order: date_col first, other task IDs, observation, as_of
  expect_equal(
    colnames,
    c("target_end_date", "location", "observation", "as_of")
  )
})

test_that("get_target_data_colnames includes as_of for versioned oracle-output", {
  # Create a mock config with versioned = TRUE for oracle-output
  config_target_data <- list(
    observable_unit = c("target_end_date", "location"),
    date_col = "target_end_date",
    versioned = FALSE,
    `oracle-output` = list(
      versioned = TRUE,
      has_output_type_ids = TRUE
    )
  )
  class(config_target_data) <- c("config", "list")

  colnames <- get_target_data_colnames(
    config_target_data,
    target_type = "oracle-output"
  )

  # Expected order: date_col first, other task IDs, output_type, output_type_id, oracle_value, as_of
  expect_equal(
    colnames,
    c(
      "target_end_date",
      "location",
      "output_type",
      "output_type_id",
      "oracle_value",
      "as_of"
    )
  )
})

test_that("get_target_data_colnames includes non_task_id_schema for time-series", {
  # Create a mock config with non_task_id_schema
  config_target_data <- list(
    observable_unit = c("target_end_date", "location"),
    date_col = "target_end_date",
    versioned = FALSE,
    `time-series` = list(
      non_task_id_schema = c(
        population = "integer",
        region = "character"
      )
    )
  )
  class(config_target_data) <- c("config", "list")

  colnames <- get_target_data_colnames(
    config_target_data,
    target_type = "time-series"
  )

  # Expected order: task IDs, non-task IDs, observation
  expect_equal(
    colnames,
    c("target_end_date", "location", "population", "region", "observation")
  )
})

test_that("get_target_data_colnames works for oracle-output without output_type_ids", {
  # Create a mock config with has_output_type_ids = FALSE
  config_target_data <- list(
    observable_unit = c("target_end_date", "location"),
    date_col = "target_end_date",
    versioned = FALSE,
    `oracle-output` = list(
      has_output_type_ids = FALSE
    )
  )
  class(config_target_data) <- c("config", "list")

  colnames <- get_target_data_colnames(
    config_target_data,
    target_type = "oracle-output"
  )

  # Expected order: task IDs, oracle_value (no output_type columns)
  expect_equal(
    colnames,
    c("target_end_date", "location", "oracle_value")
  )
})

test_that("get_target_data_colnames handles complex time-series config", {
  # Create a comprehensive config with all features
  config_target_data <- list(
    observable_unit = c("location", "target"),
    date_col = "target_end_date",
    versioned = TRUE,
    `time-series` = list(
      non_task_id_schema = c(
        population = "integer"
      )
    )
  )
  class(config_target_data) <- c("config", "list")

  colnames <- get_target_data_colnames(
    config_target_data,
    target_type = "time-series"
  )

  # Expected order: task IDs, date_col (not in task IDs), non-task IDs, observation, as_of
  expect_equal(
    colnames,
    c(
      "target_end_date",
      "location",
      "target",
      "population",
      "observation",
      "as_of"
    )
  )
})

test_that("get_target_data_colnames requires valid target_type", {
  config_target_data <- list(
    observable_unit = c("target_end_date", "location"),
    date_col = "target_end_date",
    versioned = FALSE
  )
  class(config_target_data) <- c("config", "list")

  expect_error(
    get_target_data_colnames(config_target_data, target_type = "invalid"),
    "'arg' should be one of"
  )
})

# Test when config_target_data is not a config class object

test_that("get_target_data_colnames errors for invalid config_target_data", {
  invalid_config <- list(
    observable_unit = c("target_end_date", "location"),
    date_col = "target_end_date",
    versioned = FALSE
  )

  expect_error(
    get_target_data_colnames(invalid_config, target_type = "time-series"),
    "Assertion on 'config_target_data' failed: Must inherit from class 'config', but has class 'list'"
  )
})
