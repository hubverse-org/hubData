# Connect to model output data.

Connect to data in a model output directory through a Modeling Hub or
directly. Data can be stored in a local directory or in the cloud on AWS
or GCS.

## Usage

``` r
connect_hub(
  hub_path,
  file_format = c("csv", "parquet", "arrow"),
  output_type_id_datatype = c("from_config", "auto", "character", "double", "integer",
    "logical", "Date"),
  partitions = list(model_id = arrow::utf8()),
  skip_checks = TRUE,
  na = c("NA", ""),
  ignore_files = NULL
)

connect_model_output(
  model_output_dir,
  file_format = c("csv", "parquet", "arrow"),
  partition_names = "model_id",
  schema = NULL,
  skip_checks = FALSE,
  na = c("NA", ""),
  ignore_files = NULL
)
```

## Arguments

- hub_path:

  Either a character string path to a local Modeling Hub directory or an
  object of class `<SubTreeFileSystem>` created using functions
  [`s3_bucket()`](https://hubverse-org.github.io/hubData/reference/s3_bucket.md)
  or
  [`gs_bucket()`](https://hubverse-org.github.io/hubData/reference/gs_bucket.md)
  by providing a string S3 or GCS bucket name or path to a Modeling Hub
  directory stored in the cloud. For more details consult the [Using
  cloud storage (S3,
  GCS)](https://arrow.apache.org/docs/r/articles/fs.html) in the `arrow`
  package. The hub must be fully configured with valid `admin.json` and
  `tasks.json` files within the `hub-config` directory.

- file_format:

  The file format model output files are stored in. For connection to a
  fully configured hub, accessed through `hub_path`, `file_format` is
  inferred from the hub's `file_format` configuration in `admin.json`
  and is ignored by default. If supplied, it will override hub
  configuration setting. Multiple formats can be supplied to
  `connect_hub` but only a single file format can be supplied to
  `connect_model_output`.

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

- partitions:

  a named list specifying the arrow data types of any partitioning
  column.

- skip_checks:

  Logical. If `TRUE` (default), skip validation checks when opening hub
  datasets, providing optimal performance especially for large cloud
  hubs (AWS S3, GCS) by minimizing I/O operations. However, this will
  result in an error if the model output directory contains files that
  cannot be opened as part of the dataset. Setting to `FALSE` will
  attempt to open and exclude any invalid files that cannot be read as
  part of the dataset. This results in slower performance due to
  increased I/O operations but provides more robustness when working
  with directories that may contain invalid files. Note that hubs
  validated through the hubValidations package should not require these
  additional checks. If invalid (non-model output) files are present in
  the model output directory, use the `ignore_files` argument to exclude
  them.

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

- model_output_dir:

  Either a character string path to a local directory containing model
  output data or an object of class `<SubTreeFileSystem>` created using
  functions
  [`s3_bucket()`](https://hubverse-org.github.io/hubData/reference/s3_bucket.md)
  or
  [`gs_bucket()`](https://hubverse-org.github.io/hubData/reference/gs_bucket.md)
  by providing a string S3 or GCS bucket name or path to a directory
  containing model output data stored in the cloud. For more details
  consult the [Using cloud storage (S3,
  GCS)](https://arrow.apache.org/docs/r/articles/fs.html) in the `arrow`
  package.

- partition_names:

  character vector that defines the field names to which recursive
  directory names correspond to. Defaults to a single `model_id` field
  which reflects the standard expected structure of a `model-output`
  directory.

- schema:

  An arrow::Schema object for the Dataset. If NULL (the default), the
  schema will be inferred from the data sources.

## Value

- `connect_hub` returns an S3 object of class `<hub_connection>`.

- `connect_model_output` returns an S3 object of class
  `<mod_out_connection>`.

Both objects are connected to the data in the model-output directory via
an Apache arrow `FileSystemDataset` connection. The connection can be
used to extract data using `dplyr` custom queries. The
`<hub_connection>` class also contains modeling hub metadata.

## Details

By default, common non-data files that may be present in model output
directories (e.g. `"README"`, `".DS_Store"`) are excluded automatically
to prevent errors when connecting via Arrow. Additional files can be
excluded using the `ignore_files` parameter.

## Functions

- `connect_hub()`: connect to a fully configured Modeling Hub directory.

- `connect_model_output()`: connect directly to a `model-output`
  directory. This function can be used to access data directly from an
  appropriately set up model output directory which is not part of a
  fully configured hub.

## Examples

``` r
# Connect to a local simple forecasting Hub.
hub_path <- system.file("testhubs/simple", package = "hubUtils")
hub_con <- connect_hub(hub_path)
hub_con
#> 
#> ── <hub_connection/UnionDataset> ──
#> 
#> • hub_name: "Simple Forecast Hub"
#> • hub_path: /home/runner/work/_temp/Library/hubUtils/testhubs/simple
#> • file_format: "csv(3/3)" and "parquet(1/1)"
#> • checks: FALSE
#> • file_system: "LocalFileSystem"
#> • model_output_dir:
#>   "/home/runner/work/_temp/Library/hubUtils/testhubs/simple/model-output"
#> • config_admin: hub-config/admin.json
#> • config_tasks: hub-config/tasks.json
#> 
#> ── Connection schema 
#> hub_connection
#> 9 columns
#> origin_date: date32[day]
#> target: string
#> horizon: int32
#> location: string
#> output_type: string
#> output_type_id: double
#> value: int32
#> model_id: string
#> age_group: string
hub_con <- connect_hub(hub_path, output_type_id_datatype = "character")
hub_con
#> 
#> ── <hub_connection/UnionDataset> ──
#> 
#> • hub_name: "Simple Forecast Hub"
#> • hub_path: /home/runner/work/_temp/Library/hubUtils/testhubs/simple
#> • file_format: "csv(3/3)" and "parquet(1/1)"
#> • checks: FALSE
#> • file_system: "LocalFileSystem"
#> • model_output_dir:
#>   "/home/runner/work/_temp/Library/hubUtils/testhubs/simple/model-output"
#> • config_admin: hub-config/admin.json
#> • config_tasks: hub-config/tasks.json
#> 
#> ── Connection schema 
#> hub_connection
#> 9 columns
#> origin_date: date32[day]
#> target: string
#> horizon: int32
#> location: string
#> output_type: string
#> output_type_id: string
#> value: int32
#> model_id: string
#> age_group: string
# Connect directly to a local `model-output` directory
mod_out_path <- system.file("testhubs/simple/model-output", package = "hubUtils")
mod_out_con <- connect_model_output(mod_out_path)
mod_out_con
#> 
#> ── <mod_out_connection/FileSystemDataset> ──
#> 
#> • file_format: "csv(3/3)"
#> • checks: TRUE
#> • file_system: "LocalFileSystem"
#> • model_output_dir:
#>   "/home/runner/work/_temp/Library/hubUtils/testhubs/simple/model-output"
#> 
#> ── Connection schema 
#> mod_out_connection with 3 csv files
#> 8 columns
#> origin_date: date32[day]
#> target: string
#> horizon: int64
#> location: string
#> output_type: string
#> output_type_id: double
#> value: int64
#> model_id: string
# Query hub_connection for data
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
hub_con %>%
  filter(
    origin_date == "2022-10-08",
    horizon == 2
  ) %>%
  collect_hub()
#> # A tibble: 69 × 9
#>    model_id     origin_date target        horizon location age_group output_type
#>  * <chr>        <date>      <chr>           <int> <chr>    <chr>     <chr>      
#>  1 hub-baseline 2022-10-08  wk inc flu h…       2 US       NA        quantile   
#>  2 hub-baseline 2022-10-08  wk inc flu h…       2 US       NA        quantile   
#>  3 hub-baseline 2022-10-08  wk inc flu h…       2 US       NA        quantile   
#>  4 hub-baseline 2022-10-08  wk inc flu h…       2 US       NA        quantile   
#>  5 hub-baseline 2022-10-08  wk inc flu h…       2 US       NA        quantile   
#>  6 hub-baseline 2022-10-08  wk inc flu h…       2 US       NA        quantile   
#>  7 hub-baseline 2022-10-08  wk inc flu h…       2 US       NA        quantile   
#>  8 hub-baseline 2022-10-08  wk inc flu h…       2 US       NA        quantile   
#>  9 hub-baseline 2022-10-08  wk inc flu h…       2 US       NA        quantile   
#> 10 hub-baseline 2022-10-08  wk inc flu h…       2 US       NA        quantile   
#> # ℹ 59 more rows
#> # ℹ 2 more variables: output_type_id <chr>, value <int>
mod_out_con %>%
  filter(
    origin_date == "2022-10-08",
    horizon == 2
  ) %>%
  collect_hub()
#> # A tibble: 69 × 8
#>    model_id origin_date target horizon location output_type output_type_id value
#>  * <chr>    <date>      <chr>    <int> <chr>    <chr>                <dbl> <int>
#>  1 hub-bas… 2022-10-08  wk in…       2 US       quantile             0.01    135
#>  2 hub-bas… 2022-10-08  wk in…       2 US       quantile             0.025   137
#>  3 hub-bas… 2022-10-08  wk in…       2 US       quantile             0.05    139
#>  4 hub-bas… 2022-10-08  wk in…       2 US       quantile             0.1     140
#>  5 hub-bas… 2022-10-08  wk in…       2 US       quantile             0.15    141
#>  6 hub-bas… 2022-10-08  wk in…       2 US       quantile             0.2     141
#>  7 hub-bas… 2022-10-08  wk in…       2 US       quantile             0.25    142
#>  8 hub-bas… 2022-10-08  wk in…       2 US       quantile             0.3     143
#>  9 hub-bas… 2022-10-08  wk in…       2 US       quantile             0.35    144
#> 10 hub-bas… 2022-10-08  wk in…       2 US       quantile             0.4     145
#> # ℹ 59 more rows
# Ignore a file
connect_hub(hub_path, ignore_files = c("README", "2022-10-08-team1-goodmodel.csv"))
#> 
#> ── <hub_connection/UnionDataset> ──
#> 
#> • hub_name: "Simple Forecast Hub"
#> • hub_path: /home/runner/work/_temp/Library/hubUtils/testhubs/simple
#> • file_format: "csv(2/3)" and "parquet(1/1)"
#> • checks: FALSE
#> • file_system: "LocalFileSystem"
#> • model_output_dir:
#>   "/home/runner/work/_temp/Library/hubUtils/testhubs/simple/model-output"
#> • config_admin: hub-config/admin.json
#> • config_tasks: hub-config/tasks.json
#> 
#> ── Connection schema 
#> hub_connection
#> 9 columns
#> origin_date: date32[day]
#> target: string
#> horizon: int32
#> location: string
#> output_type: string
#> output_type_id: double
#> value: int32
#> model_id: string
#> age_group: string
# Connect to a simple forecasting Hub stored in an AWS S3 bucket.
if (FALSE) { # \dontrun{
hub_path <- s3_bucket("hubverse/hubutils/testhubs/simple/")
hub_con <- connect_hub(hub_path)
hub_con
} # }
```
