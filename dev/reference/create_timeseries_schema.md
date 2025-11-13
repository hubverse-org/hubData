# Create time-series target data file schema

Create time-series target data file schema

## Usage

``` r
create_timeseries_schema(
  hub_path,
  date_col = NULL,
  na = c("NA", ""),
  ignore_files = NULL,
  r_schema = FALSE
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

- date_col:

  Optional column name to be interpreted as date. Default is `NULL`.
  Useful when the required date column is a partitioning column in the
  target data and does not have the same name as a date typed task ID
  variable in the config. **Note**: Ignored when `target-data.json`
  exists (v6+); date column is read from config.

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
# Create target time-series schema
create_timeseries_schema(hub_path)
#> Schema
#> target_end_date: date32[day]
#> target: string
#> location: string
#> observation: double
#  target time-series schema from a cloud hub
s3_hub_path <- s3_bucket("example-complex-forecast-hub")
create_timeseries_schema(s3_hub_path)
#> Schema
#> target_end_date: date32[day]
#> target: string
#> location: string
#> observation: double
```
