# Create R type to Arrow DataType mapping

Returns a named list mapping base R type strings (e.g., `"character"`,
`"integer"`) to their corresponding Arrow arrow::DataType objects. This
is the inverse of
[arrow_to_r_datatypes](https://hubverse-org.github.io/hubData/reference/arrow_to_r_datatypes.md)
and is useful when creating Arrow schemas programmatically from R type
specifications.

## Usage

``` r
r_to_arrow_datatypes()
```

## Value

A named list with 6 entries mapping R types to Arrow DataType objects:

- logical:

  [`arrow::bool()`](https://arrow.apache.org/docs/r/reference/data-type.html)

- integer:

  [`arrow::int32()`](https://arrow.apache.org/docs/r/reference/data-type.html)
  (uses int32 as default)

- double:

  [`arrow::float64()`](https://arrow.apache.org/docs/r/reference/data-type.html)

- character:

  [`arrow::utf8()`](https://arrow.apache.org/docs/r/reference/data-type.html)

- Date:

  [`arrow::date32()`](https://arrow.apache.org/docs/r/reference/data-type.html)

- POSIXct:

  `arrow::timestamp(unit = "ms")`

## Details

This function generates the mapping dynamically. The R type strings
match those used in the `non_task_id_schema` field of `target-data.json`
configuration files.

This is particularly useful for:

- Creating custom Arrow schemas from R type specifications

- Converting configuration-based type information to Arrow schemas

- Programmatic schema generation

## See also

[arrow_to_r_datatypes](https://hubverse-org.github.io/hubData/reference/arrow_to_r_datatypes.md),
[`create_timeseries_schema()`](https://hubverse-org.github.io/hubData/reference/create_timeseries_schema.md),
[`create_oracle_output_schema()`](https://hubverse-org.github.io/hubData/reference/create_oracle_output_schema.md)

## Examples

``` r
# Get the mapping
type_map <- r_to_arrow_datatypes()

# Use it to create Arrow types from R type strings
r_types <- c("character", "integer", "double")
arrow_types <- type_map[r_types]

# Create a simple Arrow schema
my_schema <- arrow::schema(
  name = type_map[["character"]],
  age = type_map[["integer"]],
  score = type_map[["double"]]
)
my_schema
#> Schema
#> name: string
#> age: int32
#> score: double
```
