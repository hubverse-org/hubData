# Tests for create_oracle_output_schema using embedded example hubs
# Requires helper-v5-hubs.R with:
# - use_example_hub_readonly()
# - use_example_hub_editable()
# And helper-fixtures.R with:
# - oracle_output_schema_fixture()  # takes partition_col, output_type_id

test_that("create_oracle_output_schema works on embedded single-file hub", {
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

test_that("create_oracle_output_schema works when partitioned by target_end_date", {
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

test_that("create_oracle_output_schema works on single-file SubTreeFileSystem (local mirror)", {
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

test_that("create_oracle_output_schema returns R datatypes", {
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

test_that("create_oracle_output_schema output_type_id override works", {
  hub_path <- use_example_hub_readonly("file")
  sch_r <- create_oracle_output_schema(
    hub_path,
    r_schema = TRUE,
    output_type_id_datatype = "double"
  )
  expect_equal(sch_r[["output_type_id"]], "double")
})

test_that("create_oracle_output_schema non-task ID partition columns detected", {
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
