test_that("is_hive_partitioned_path correctly identifies Hive-style partitioned paths", {
  # Basic valid case
  expect_true(is_hive_partitioned_path(
    "data/country=US/year=2024/file.parquet"
  ))

  # Valid: NA value in partition (empty after equals)
  expect_true(is_hive_partitioned_path("data/country=/year=2024/"))

  # Valid: even with an invalid one present, if not in strict mode
  expect_true(is_hive_partitioned_path("data/=US/year=2024/", strict = FALSE))

  # Invalid: no partition-like segments at all
  expect_false(is_hive_partitioned_path("data/year2024/countryUS/file.parquet"))

  # Valid: Hive default placeholder used
  expect_true(is_hive_partitioned_path("data/col=__HIVE_DEFAULT_PARTITION__/"))

  # Valid: trailing slash with partition
  expect_true(is_hive_partitioned_path("data/category=books/year=2023/"))

  # Invalid: just a file path
  expect_false(is_hive_partitioned_path("data/file.parquet"))

  # Valid: multiple valid partitions
  expect_true(is_hive_partitioned_path(
    "data/region=EU/country=FR/year=2024/month=04/"
  ))

  # Valid: mixed valid and malformed in non-strict mode
  expect_true(is_hive_partitioned_path(
    "data/=US/region=EU/year=2024/",
    strict = FALSE
  ))

  # Strict mode: invalid partition throws error with specific message
  expect_error(
    is_hive_partitioned_path("data/=US/year=2024/", strict = TRUE),
    regexp = "Invalid Hive-style partition segments.*=US"
  )

  # Strict mode: all partitions valid, no error
  expect_true(is_hive_partitioned_path(
    "data/country=US/year=2024/",
    strict = TRUE
  ))
})

test_that("extract_hive_partitions extracts key-value pairs correctly", {
  expect_equal(
    extract_hive_partitions("data/country=US/year=2024/file.parquet"),
    c(country = "US", year = "2024")
  )

  expect_equal(
    extract_hive_partitions("data/region=EU/country=FR/year=2024/"),
    c(region = "EU", country = "FR", year = "2024")
  )

  expect_equal(
    extract_hive_partitions("data/type=__HIVE_DEFAULT_PARTITION__/"),
    c(type = NA)
  )

  expect_equal(
    extract_hive_partitions("data/country=/year=2024/"),
    c(country = NA, year = "2024")
  )
})

test_that("extract_hive_partitions decodes URL-encoded values", {
  expect_equal(
    extract_hive_partitions("data/topic=wk%20flu%20hosp/year=2024/"),
    c(topic = "wk flu hosp", year = "2024")
  )
})

test_that("extract_hive_partitions returns NULL if no valid partitions", {
  expect_null(extract_hive_partitions("data/random_folder/file.parquet"))
  expect_null(extract_hive_partitions("data/file.parquet"))
})

test_that("extract_hive_partitions ignores malformed segments in non-strict mode", {
  expect_equal(
    extract_hive_partitions("data/=US/year=2024/", strict = FALSE),
    c(year = "2024")
  )

  expect_equal(
    extract_hive_partitions("data/=/region=EU/", strict = FALSE),
    c(region = "EU")
  )
})

test_that("extract_hive_partitions errors on malformed segments in strict mode", {
  expect_error(
    extract_hive_partitions("data/=US/year=2024/", strict = TRUE),
    regexp = "Invalid Hive-style partition segments.*=US"
  )

  expect_error(
    extract_hive_partitions("data/=/year=2024/", strict = TRUE),
    regexp = "Invalid Hive-style partition segments.*="
  )
})

test_that("extract_hive_partitions handles empty value as NA", {
  expect_equal(
    extract_hive_partitions("data/key=/"),
    c(key = NA)
  )
})

test_that("extract_hive_partitions throws error with invalid input type", {
  expect_error(
    extract_hive_partitions(c("a", "b")),
    regexp = "Assertion on 'path' failed"
  )
})
