# Create oracle-output target data file schema

Create oracle-output target data file schema

## Usage

``` r
create_oracle_output_schema(
  hub_path,
  na = c("NA", ""),
  ignore_files = NULL,
  r_schema = FALSE,
  output_type_id_datatype = c("from_config", "auto", "character", "double", "integer",
    "logical", "Date")
)
```

## Arguments

- hub_path:

  Either a character string path to a local Modeling Hub directory or an
  object of class `<SubTreeFileSystem>` created using functions
  [`s3_bucket()`](https://hubverse-org.github.io/hubData/dev/reference/s3_bucket.md)
  or
  [`gs_bucket()`](https://hubverse-org.github.io/hubData/dev/reference/gs_bucket.md)
  by providing a string S3 or GCS bucket name or path to a Modeling Hub
  directory stored in the cloud. For more details consult the [Using
  cloud storage (S3,
  GCS)](https://arrow.apache.org/docs/r/articles/fs.html) in the `arrow`
  package. The hub must be fully configured with valid `admin.json` and
  `tasks.json` files within the `hub-config` directory.

- na:

  A character vector of strings to interpret as missing values. Only
  applies to CSV files. The default is `c("NA", "")`. Useful when actual
  character string `"NA"` values are used in the data. In such a case,
  use empty cells to indicate missing values in your files and set
  `na = ""`.

- ignore_files:

  A character vector of file **names** (not paths) or file **prefixes**
  to ignore when discovering model output files to include in dataset
  connections. Parent directory names should not be included. Common
  non-data files such as `"README"` and `".DS_Store"` are ignored
  automatically, but additional files can be excluded by specifying them
  here.

- r_schema:

  Logical. If `FALSE` (default), return an
  [`arrow::schema()`](https://arrow.apache.org/docs/r/reference/schema.html)
  object. If `TRUE`, return a character vector of R data types.

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

an arrow `<schema>` class object

## Details

When `target-data.json` (v6.0.0+) is present, schema is created directly
from config without reading target data files. Otherwise, schema is
inferred by reading the dataset. Config-based approach avoids file I/O
(especially beneficial for cloud storage) and provides deterministic
schema creation.

## Examples

``` r
hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
# Create target oracle-output schema
create_oracle_output_schema(hub_path)
#> Schema
#> location: string
#> target_end_date: date32[day]
#> target: string
#> output_type: string
#> output_type_id: string
#> oracle_value: double
#  target oracle-output schema from a cloud hub
s3_hub_path <- s3_bucket("example-complex-forecast-hub")
create_oracle_output_schema(s3_hub_path)
#> Schema
#> target_end_date: date32[day]
#> target: string
#> location: string
#> output_type: string
#> output_type_id: string
#> oracle_value: double
```
