# Open connection to oracle-output target data

**\[experimental\]** Open the oracle-output target data file(s) in a hub
as an arrow dataset.

## Usage

``` r
connect_target_oracle_output(
  hub_path = ".",
  na = c("NA", ""),
  ignore_files = NULL,
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

An arrow dataset object of subclass \<target_oracle_output\>.

## Details

If the target data is split across multiple files in a `oracle-output`
directory, all files must share the same file format, either csv or
parquet. No other types of files are currently allowed in a
`oracle-output` directory.

### Schema Creation

This function uses different methods to create the Arrow schema
depending on the hub configuration version:

**v6+ hubs (with `target-data.json`):** Schema is created directly from
the `target-data.json` configuration file using
[`create_oracle_output_schema()`](https://hubverse-org.github.io/hubData/dev/reference/create_oracle_output_schema.md).
This config-based approach is fast and deterministic, requiring no
filesystem I/O to scan data files. It's especially beneficial for cloud
storage where file scanning can be slow.

**Hubs (without `target-data.json`):** Schema is inferred by scanning
the actual data files. This inference-based approach examines file
structure and content to determine column types.

The function automatically detects which method to use based on the
presence of `target-data.json` in the hub configuration.

### Schema Ordering

Column ordering in the resulting dataset depends on configuration
version and file format:

**v6+ hubs (with `target-data.json`):**

- **Parquet**: Columns are reordered to the standard hubverse convention
  (see
  [`get_target_data_colnames()`](https://hubverse-org.github.io/hubData/dev/reference/get_target_data_colnames.md)).
  Parquet's column-by-name matching enables safe reordering.

- **CSV**: Original file ordering is preserved to avoid column
  name/position mismatches during collection.

**Hubs (without `target-data.json`)**: Original file ordering is
preserved regardless of format.

## Examples

``` r
# Column Ordering: CSV vs Parquet in v6+ hubs
# For v6+ hubs with target-data.json, ordering differs by file format

# Example 1: CSV format (single file) - preserves original file ordering
hub_path_csv <- system.file("testhubs/v6/target_file", package = "hubUtils")
oo_con_csv <- connect_target_oracle_output(hub_path_csv)

# CSV columns are in their original file order
names(oo_con_csv)
#> [1] "location"        "target_end_date" "target"          "output_type"    
#> [5] "output_type_id"  "oracle_value"   

# Collect and filter as usual
oo_con_csv |> dplyr::collect()
#> # A tibble: 627 × 6
#>    location target_end_date target       output_type output_type_id oracle_value
#>    <chr>    <date>          <chr>        <chr>       <chr>                 <dbl>
#>  1 US       2022-10-22      wk flu hosp… cdf         1                         1
#>  2 US       2022-10-22      wk flu hosp… cdf         2                         1
#>  3 US       2022-10-22      wk flu hosp… cdf         3                         1
#>  4 US       2022-10-22      wk flu hosp… cdf         4                         1
#>  5 US       2022-10-22      wk flu hosp… cdf         5                         1
#>  6 US       2022-10-22      wk flu hosp… cdf         6                         1
#>  7 US       2022-10-22      wk flu hosp… cdf         7                         1
#>  8 US       2022-10-22      wk flu hosp… cdf         8                         1
#>  9 US       2022-10-22      wk flu hosp… cdf         9                         1
#> 10 US       2022-10-22      wk flu hosp… cdf         10                        1
#> # ℹ 617 more rows
oo_con_csv |>
  dplyr::filter(location == "US") |>
  dplyr::collect()
#> # A tibble: 209 × 6
#>    location target_end_date target       output_type output_type_id oracle_value
#>    <chr>    <date>          <chr>        <chr>       <chr>                 <dbl>
#>  1 US       2022-10-22      wk flu hosp… cdf         1                         1
#>  2 US       2022-10-22      wk flu hosp… cdf         2                         1
#>  3 US       2022-10-22      wk flu hosp… cdf         3                         1
#>  4 US       2022-10-22      wk flu hosp… cdf         4                         1
#>  5 US       2022-10-22      wk flu hosp… cdf         5                         1
#>  6 US       2022-10-22      wk flu hosp… cdf         6                         1
#>  7 US       2022-10-22      wk flu hosp… cdf         7                         1
#>  8 US       2022-10-22      wk flu hosp… cdf         8                         1
#>  9 US       2022-10-22      wk flu hosp… cdf         9                         1
#> 10 US       2022-10-22      wk flu hosp… cdf         10                        1
#> # ℹ 199 more rows

# Example 2: Parquet format (directory) - reordered to hubverse convention
hub_path_parquet <- system.file("testhubs/v6/target_dir", package = "hubUtils")
oo_con_parquet <- connect_target_oracle_output(hub_path_parquet)

# Parquet columns follow hubverse convention (date first, then alphabetical)
names(oo_con_parquet)
#> [1] "target_end_date" "target"          "location"        "output_type"    
#> [5] "output_type_id"  "oracle_value"   

# Reordering is safe for Parquet because it matches columns by name
# rather than position during collection
oo_con_parquet |> dplyr::collect()
#> # A tibble: 627 × 6
#>    target_end_date target       location output_type output_type_id oracle_value
#>    <date>          <chr>        <chr>    <chr>       <chr>                 <dbl>
#>  1 2022-10-22      wk flu hosp… US       cdf         1                         1
#>  2 2022-10-22      wk flu hosp… US       cdf         2                         1
#>  3 2022-10-22      wk flu hosp… US       cdf         3                         1
#>  4 2022-10-22      wk flu hosp… US       cdf         4                         1
#>  5 2022-10-22      wk flu hosp… US       cdf         5                         1
#>  6 2022-10-22      wk flu hosp… US       cdf         6                         1
#>  7 2022-10-22      wk flu hosp… US       cdf         7                         1
#>  8 2022-10-22      wk flu hosp… US       cdf         8                         1
#>  9 2022-10-22      wk flu hosp… US       cdf         9                         1
#> 10 2022-10-22      wk flu hosp… US       cdf         10                        1
#> # ℹ 617 more rows

# Both formats support the same filtering operations
oo_con_parquet |>
  dplyr::filter(target_end_date ==  "2022-12-31") |>
  dplyr::collect()
#> # A tibble: 57 × 6
#>    target_end_date target       location output_type output_type_id oracle_value
#>    <date>          <chr>        <chr>    <chr>       <chr>                 <dbl>
#>  1 2022-12-31      wk flu hosp… US       cdf         1                         0
#>  2 2022-12-31      wk flu hosp… US       cdf         2                         0
#>  3 2022-12-31      wk flu hosp… US       cdf         3                         0
#>  4 2022-12-31      wk flu hosp… US       cdf         4                         0
#>  5 2022-12-31      wk flu hosp… US       cdf         5                         0
#>  6 2022-12-31      wk flu hosp… US       cdf         6                         1
#>  7 2022-12-31      wk flu hosp… US       cdf         7                         1
#>  8 2022-12-31      wk flu hosp… US       cdf         8                         1
#>  9 2022-12-31      wk flu hosp… US       cdf         9                         1
#> 10 2022-12-31      wk flu hosp… US       cdf         10                        1
#> # ℹ 47 more rows

# Get distinct target_end_date values
oo_con_parquet |>
  dplyr::distinct(target_end_date) |>
  dplyr::pull(as_vector = TRUE)
#>  [1] "2022-10-22" "2022-10-29" "2022-11-05" "2022-11-12" "2022-11-19"
#>  [6] "2022-11-26" "2022-12-03" "2022-12-10" "2022-12-17" "2022-12-24"
#> [11] "2022-12-31"

if (FALSE) { # \dontrun{
# Access Target oracle-output data from a cloud hub
s3_hub_path <- s3_bucket("example-complex-forecast-hub")
s3_con <- connect_target_oracle_output(s3_hub_path)
s3_con
s3_con |> dplyr::collect()
} # }
```
