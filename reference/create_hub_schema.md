# Create a Hub arrow schema

Create an arrow schema from a `tasks.json` config file. For use when
opening an arrow dataset.

## Usage

``` r
create_hub_schema(
  config_tasks,
  partitions = list(model_id = arrow::utf8()),
  output_type_id_datatype = c("from_config", "auto", "character", "double", "integer",
    "logical", "Date"),
  r_schema = FALSE
)
```

## Arguments

- config_tasks:

  a list version of the content's of a hub's `tasks.json` config file
  created using function
  [`hubUtils::read_config()`](https://hubverse-org.github.io/hubUtils/reference/read_config.html).

- partitions:

  a named list specifying the arrow data types of any partitioning
  column.

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

- r_schema:

  Logical. If `FALSE` (default), return an
  [`arrow::schema()`](https://arrow.apache.org/docs/r/reference/schema.html)
  object. If `TRUE`, return a character vector of R data types.

## Value

an arrow schema object that can be used to define column datatypes when
opening model output data. If `r_schema = TRUE`, a character vector of R
data types.

## Examples

``` r
hub_path <- system.file("testhubs/simple", package = "hubUtils")
config_tasks <- hubUtils::read_config(hub_path, "tasks")
schema <- create_hub_schema(config_tasks)
```
