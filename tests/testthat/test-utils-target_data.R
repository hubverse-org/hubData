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
  readr::write_csv(data.frame(a = 1:3), fs::path(td, "showtime-series.csv"))
  readr::write_csv(data.frame(a = 1:3), fs::path(td, "time-seriesss.csv"))
  readr::write_csv(data.frame(a = 1:3), fs::path(td, "pre-oracle-output.csv"))
  readr::write_csv(data.frame(a = 1:3), fs::path(td, "oracle-output-v2.csv"))

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
