# Tests for create_oracle_output_schema using embedded example hubs
# Requires helper-v5-hubs.R with:
# - use_example_hub_readonly()
# - use_example_hub_editable()
# And helper-fixtures.R with:
# - oracle_output_schema_fixture()  # takes partition_col, output_type_id

test_that("create_oracle_output_schema inference works on single-file hub", {
  hub_path <- use_example_hub_readonly("file")

  sch <- create_oracle_output_schema(hub_path)
  expect_equal(
    sch$ToString(),
    oracle_output_schema_fixture(
      partition_col = NULL,
      output_type_id = "string"
    )
  )
})

test_that("create_oracle_output_schema inference handles target_end_date partitioning", {
  # editable copy to partition and remove the single file
  hub_path <- use_example_hub_editable("file")
  oo_path <- validate_target_data_path(hub_path, "oracle-output")
  dat <- arrow::read_csv_arrow(oo_path)

  out_dir <- fs::path(hub_path, "target-data", "oracle-output")
  if (fs::dir_exists(out_dir)) {
    fs::dir_delete(out_dir)
  }
  fs::dir_create(out_dir)

  arrow::write_dataset(
    dat,
    out_dir,
    partitioning = "target_end_date",
    format = "parquet"
  )
  fs::file_delete(oo_path)

  # partitioned schema: partition column appears last
  sch_hive <- create_oracle_output_schema(hub_path)
  expect_equal(
    sch_hive$ToString(),
    oracle_output_schema_fixture(
      partition_col = "target_end_date",
      output_type_id = "string"
    )
  )

  # ignoring a specific partition folder should yield the same schema
  sch_ign <- create_oracle_output_schema(
    hub_path,
    ignore_files = "target_end_date=2023-06-17"
  )
  expect_equal(
    sch_ign$ToString(),
    oracle_output_schema_fixture(
      partition_col = "target_end_date",
      output_type_id = "string"
    )
  )
})

test_that("create_oracle_output_schema inference works on SubTreeFileSystem", {
  skip_on_os("windows") # SubTreeFileSystem lower-level calls are flaky on Windows

  src <- use_example_hub_readonly("file")
  tmp <- withr::local_tempdir("subtree-oo-")
  fs::dir_copy(src, tmp, overwrite = TRUE)
  loc_fs <- arrow::SubTreeFileSystem$create(tmp)

  cfg <- read_config(tmp)
  local_mocked_bindings(read_config = function(...) cfg)

  sch <- create_oracle_output_schema(loc_fs)
  expect_equal(
    sch$ToString(),
    oracle_output_schema_fixture(
      partition_col = NULL,
      output_type_id = "string"
    )
  )
})

test_that("create_oracle_output_schema inference returns R datatypes", {
  hub_path <- use_example_hub_readonly("file")
  sch_r <- create_oracle_output_schema(hub_path, r_schema = TRUE)

  expect_equal(
    sch_r,
    c(
      location = "character",
      target_end_date = "Date",
      target = "character",
      output_type = "character",
      output_type_id = "character",
      oracle_value = "double"
    )
  )
})

test_that("create_oracle_output_schema inference handles output_type_id override", {
  hub_path <- use_example_hub_readonly("file")
  sch_r <- create_oracle_output_schema(
    hub_path,
    r_schema = TRUE,
    output_type_id_datatype = "double"
  )
  expect_equal(sch_r[["output_type_id"]], "double")
})

test_that("create_oracle_output_schema inference detects non-task ID partition columns", {
  # editable copy to partition and remove the single file
  hub_path <- use_example_hub_editable("file")
  oo_path <- validate_target_data_path(hub_path, "oracle-output")
  dat <- arrow::read_csv_arrow(oo_path)
  dat$extra_col <- "extra"

  out_dir <- fs::path(hub_path, "target-data", "oracle-output")
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
  fs::file_delete(oo_path)

  sch_extra <- create_oracle_output_schema(hub_path)
  expect_equal(
    sch_extra$extra_col$ToString(),
    "extra_col: string"
  )
})

# v6 config-based tests ----

test_that("create_oracle_output_schema config works with basic v6 hub", {
  hub_path <- use_example_hub_readonly("file", v = 6)

  sch <- create_oracle_output_schema(hub_path)

  # Config-based schema follows observable_unit order from config
  expect_equal(
    sch$ToString(),
    "target_end_date: date32[day]\ntarget: string\nlocation: string\noutput_type: string\noutput_type_id: string\noracle_value: double" # nolint: line_length_linter
  )
})

test_that("create_oracle_output_schema config handles versioned data", {
  hub_path <- use_example_hub_editable("file", v = 6)
  config_path <- fs::path(hub_path, "hub-config", "target-data.json")

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

  sch <- create_oracle_output_schema(hub_path)

  # Check as_of column is present
  expect_true("as_of" %in% names(sch))
  expect_equal(sch$as_of$ToString(), "as_of: date32[day]")
})

test_that("create_oracle_output_schema config handles has_output_type_ids=false", {
  hub_path <- use_example_hub_editable("file", v = 6)
  config_path <- fs::path(hub_path, "hub-config", "target-data.json")

  # Set has_output_type_ids to false
  config_path <- fs::path(hub_path, "hub-config", "target-data.json")
  config <- hubUtils::read_config_file(config_path)
  config$`oracle-output`$has_output_type_ids <- FALSE
  hubAdmin::write_config(
    config,
    config_path = config_path,
    overwrite = TRUE,
    silent = TRUE
  )

  sch <- create_oracle_output_schema(hub_path)

  # Check output_type columns are NOT present
  expect_false("output_type" %in% names(sch))
  expect_false("output_type_id" %in% names(sch))

  # But oracle_value should be present
  expect_true("oracle_value" %in% names(sch))
})

test_that("create_oracle_output_schema config with output_type_id_datatype override", {
  hub_path <- use_example_hub_readonly("file", v = 6)

  sch <- create_oracle_output_schema(
    hub_path,
    output_type_id_datatype = "double"
  )

  # Should use double instead of string
  expect_equal(
    sch$ToString(),
    "target_end_date: date32[day]\ntarget: string\nlocation: string\noutput_type: string\noutput_type_id: double\noracle_value: double" # nolint: line_length_linter
  )
})

test_that("create_oracle_output_schema config returns R datatypes", {
  hub_path <- use_example_hub_readonly("file", v = 6)
  sch_r <- create_oracle_output_schema(hub_path, r_schema = TRUE)

  # Config-based schema follows observable_unit order from config
  expect_equal(
    sch_r,
    c(
      target_end_date = "Date",
      target = "character",
      location = "character",
      output_type = "character",
      output_type_id = "character",
      oracle_value = "double"
    )
  )
})

test_that("create_oracle_output_schema config handles versioned + has_output_type_ids=false", {
  hub_path <- use_example_hub_editable("file", v = 6)
  config_path <- fs::path(hub_path, "hub-config", "target-data.json")

  # Set both versioned and has_output_type_ids=false
  config_path <- fs::path(hub_path, "hub-config", "target-data.json")
  config <- hubUtils::read_config_file(config_path)
  config$versioned <- TRUE
  config$`oracle-output`$has_output_type_ids <- FALSE
  hubAdmin::write_config(
    config,
    config_path = config_path,
    overwrite = TRUE,
    silent = TRUE
  )

  sch <- create_oracle_output_schema(hub_path)

  # Check as_of is present, output_type columns are NOT
  expect_true("as_of" %in% names(sch))
  expect_false("output_type" %in% names(sch))
  expect_false("output_type_id" %in% names(sch))
  expect_true("oracle_value" %in% names(sch))
  expect_named(
    sch,
    c(
      "target_end_date",
      "target",
      "location",
      "oracle_value",
      "as_of"
    )
  )
})
