test_that("get_target_path works", {
  hub_path <- withr::local_tempdir()
  example_hub <- "https://github.com/hubverse-org/example-complex-forecast-hub.git"
  gert::git_clone(url = example_hub, path = hub_path)
  expect_equal(
    basename(get_target_path(hub_path)),
    "time-series.csv"
  )
  expect_equal(
    basename(get_target_path(hub_path, "oracle-output")),
    "oracle-output.csv"
  )

  s3_hub_path <- s3_bucket("example-complex-forecast-hub")
  expect_equal(
    basename(get_target_path(s3_hub_path)),
    "time-series.csv"
  )
  expect_equal(
    basename(get_target_path(s3_hub_path, "oracle-output")),
    "oracle-output.csv"
  )
})
