# Coerce data.frame/tibble column data types to hub schema data types or character.

Coerce data.frame/tibble column data types to hub schema data types or
character.

## Usage

``` r
coerce_to_hub_schema(
  tbl,
  config_tasks,
  skip_date_coercion = FALSE,
  as_arrow_table = FALSE,
  output_type_id_datatype = c("from_config", "auto", "character", "double", "integer",
    "logical", "Date")
)

coerce_to_character(tbl, as_arrow_table = FALSE)
```

## Arguments

- tbl:

  a model output data.frame/tibble

- config_tasks:

  a list version of the content's of a hub's `tasks.json` config file
  created using function
  [`hubUtils::read_config()`](https://hubverse-org.github.io/hubUtils/reference/read_config.html).

- skip_date_coercion:

  Logical. Whether to skip coercing dates. This can be faster,
  especially for larger `tbl`s.

- as_arrow_table:

  Logical. Whether to return an arrow table. Defaults to `FALSE`.

- output_type_id_datatype:

  character string. One of `"from_config"`, `"auto"`, `"character"`,
  `"double"`, `"integer"`, `"logical"`, `"Date"`. Defaults to
  `"from_config"` which uses the setting in the
  `output_type_id_datatype` property in the `tasks.json` config file if
  available. If the property is not set in the config, the argument
  falls back to `"auto"` which determines the `output_type_id` data type
  automatically from the `tasks.json` config file as the simplest data
  type required to represent all output type ID values across all output
  types in the hub. When only point estimate output types (where
  `output_type_id`s are `NA`,) are being collected by a hub, the
  `output_type_id` column is assigned a `character` data type when
  auto-determined. Other data type values can be used to override
  automatic determination. Note that attempting to coerce
  `output_type_id` to a data type that is not valid for the data (e.g.
  trying to coerce`"character"` values to `"double"`) will likely result
  in an error or potentially unexpected behaviour so use with care.

## Value

`tbl` with column data types coerced to hub schema data types or
character. if `as_arrow_table = TRUE`, output is also converted to arrow
table.

## Functions

- `coerce_to_hub_schema()`: coerce columns to hub schema data types.

- `coerce_to_character()`: coerce all columns to character
