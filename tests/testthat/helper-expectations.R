# Connection expectations =====

# Checks that a hub_connection has exactly the attributes connect_hub() sets,
# and that the attributes read from the hub's config files match those files.
# Note that the S3 test hubs' configs contain a superseded URL, which
# read_config() reports with a message.
expect_hub_connection_attrs <- function(hub_con, hub_path) {
  testthat::expect_setequal(
    names(attributes(hub_con)),
    c(
      "class",
      "hub_name",
      "file_format",
      "checks",
      "file_system",
      "hub_path",
      "model_output_dir",
      "config_admin",
      "config_tasks"
    )
  )
  config_admin <- suppressMessages(hubUtils::read_config(hub_path, "admin"))
  config_tasks <- suppressMessages(hubUtils::read_config(hub_path, "tasks"))
  testthat::expect_equal(attr(hub_con, "hub_name"), config_admin$name)
  testthat::expect_equal(attr(hub_con, "config_admin"), config_admin)
  testthat::expect_equal(attr(hub_con, "config_tasks"), config_tasks)
}
