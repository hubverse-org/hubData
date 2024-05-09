test_that("read_config_file works", {
  expect_snapshot(
    read_config_file(
      system.file("config", "tasks.json", package = "hubData")
    )
  )
})
