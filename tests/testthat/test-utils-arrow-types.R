test_that("arrow_schema_to_string() returns correct Arrow types", {
  schema <- arrow::schema(
    int_col = arrow::int32(),
    dbl_col = arrow::float64(),
    str_col = arrow::utf8()
  )

  result <- arrow_schema_to_string(schema)

  expect_equal(
    result,
    c(
      int_col = "int32",
      dbl_col = "double",
      str_col = "string"
    )
  )
})

test_that("is_supported_arrow_type() correctly identifies supported columns", {
  schema <- arrow::schema(
    supported = arrow::int64(),
    unsupported = arrow::decimal128(10, 2)
  )

  result <- is_supported_arrow_type(schema)

  expect_named(result, c("supported", "unsupported"))
  expect_true(result["supported"])
  expect_false(result["unsupported"])
})

test_that("validate_arrow_schema() passes for supported types", {
  schema <- arrow::schema(
    date = arrow::date32(),
    flag = arrow::bool(),
    val = arrow::float()
  )

  expect_silent(validate_arrow_schema(schema))
  check <- validate_arrow_schema(schema)
  expect_true(check)
})

test_that("validate_arrow_schema() errors on unsupported types", {
  schema <- arrow::schema(
    good = arrow::int32(),
    bad = arrow::decimal128(10, 2)
  )

  expect_error(
    validate_arrow_schema(schema),
    'Unsupported data type in schema:.*"bad"'
  )
})

test_that("as_r_schema() returns correct R types for supported schema", {
  schema <- arrow::schema(
    x = arrow::int32(),
    y = arrow::float(),
    z = arrow::string()
  )

  result <- as_r_schema(schema)

  expect_named(result, c("x", "y", "z"))
  c(x = "integer", y = "double", z = "character")
})

test_that("as_r_schema() errors on unsupported types", {
  schema <- arrow::schema(
    a = arrow::int64(),
    b = arrow::decimal128(10, 2)
  )

  expect_error(
    as_r_schema(schema),
    'Unsupported data type in schema:.*"b"'
  )
})
