# Open connection to time-series target data

**\[experimental\]** Open the time-series target data file(s) in a hub
as an arrow dataset.

## Usage

``` r
connect_target_timeseries(
  hub_path = ".",
  date_col = NULL,
  na = c("NA", ""),
  ignore_files = NULL
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
  variable in the config.

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

## Value

An arrow dataset object of subclass \<target_timeseries\>.

## Details

If the target data is split across multiple files in a `time-series`
directory, all files must share the same file format, either csv or
parquet. No other types of files are currently allowed in a
`time-series` directory.

### Schema Creation

This function uses different methods to create the Arrow schema
depending on the hub configuration version:

**v6+ hubs (with `target-data.json`):** Schema is created directly from
the `target-data.json` configuration file using
[`create_timeseries_schema()`](https://hubverse-org.github.io/hubData/dev/reference/create_timeseries_schema.md).
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
ts_con_csv <- connect_target_timeseries(hub_path_csv)

# CSV columns are in their original file order
names(ts_con_csv)
#> [1] "target_end_date" "target"          "location"        "observation"    
# Note: columns appear in the order they are in the CSV file

# Collect and filter as usual
ts_con_csv |> dplyr::collect()
#> # A tibble: 66 × 4
#>    target_end_date target          location observation
#>    <date>          <chr>           <chr>          <dbl>
#>  1 2022-10-22      wk inc flu hosp 02                 3
#>  2 2022-10-22      wk inc flu hosp 01               141
#>  3 2022-10-22      wk inc flu hosp US              2380
#>  4 2022-10-29      wk inc flu hosp 02                14
#>  5 2022-10-29      wk inc flu hosp 01               262
#>  6 2022-10-29      wk inc flu hosp US              4353
#>  7 2022-11-05      wk inc flu hosp 02                10
#>  8 2022-11-05      wk inc flu hosp 01               360
#>  9 2022-11-05      wk inc flu hosp US              6571
#> 10 2022-11-12      wk inc flu hosp 02                20
#> # ℹ 56 more rows
ts_con_csv |>
  dplyr::filter(location == "US") |>
  dplyr::collect()
#> # A tibble: 22 × 4
#>    target_end_date target          location observation
#>    <date>          <chr>           <chr>          <dbl>
#>  1 2022-10-22      wk inc flu hosp US              2380
#>  2 2022-10-29      wk inc flu hosp US              4353
#>  3 2022-11-05      wk inc flu hosp US              6571
#>  4 2022-11-12      wk inc flu hosp US              8848
#>  5 2022-11-19      wk inc flu hosp US             11427
#>  6 2022-11-26      wk inc flu hosp US             19846
#>  7 2022-12-03      wk inc flu hosp US             26333
#>  8 2022-12-10      wk inc flu hosp US             23851
#>  9 2022-12-17      wk inc flu hosp US             21435
#> 10 2022-12-24      wk inc flu hosp US             19286
#> # ℹ 12 more rows

# Example 2: Parquet format (directory) - reordered to hubverse convention
hub_path_parquet <- system.file("testhubs/v6/target_dir", package = "hubUtils")
ts_con_parquet <- connect_target_timeseries(hub_path_parquet)

# Parquet columns follow hubverse convention
names(ts_con_parquet)
#> [1] "target_end_date" "target"          "location"        "observation"    

# Reordering is safe for Parquet because it matches columns by name
# rather than position during collection
ts_con_parquet |> dplyr::collect()
#> # A tibble: 66 × 4
#>    target_end_date target           location observation
#>    <date>          <chr>            <chr>          <dbl>
#>  1 2022-10-22      wk flu hosp rate 02             0.422
#>  2 2022-10-22      wk flu hosp rate 01             2.78 
#>  3 2022-10-22      wk flu hosp rate US             0.716
#>  4 2022-10-29      wk flu hosp rate 02             1.97 
#>  5 2022-10-29      wk flu hosp rate 01             5.17 
#>  6 2022-10-29      wk flu hosp rate US             1.31 
#>  7 2022-11-05      wk flu hosp rate 02             1.41 
#>  8 2022-11-05      wk flu hosp rate 01             7.11 
#>  9 2022-11-05      wk flu hosp rate US             1.98 
#> 10 2022-11-12      wk flu hosp rate 02             2.81 
#> # ℹ 56 more rows

# Both formats support the same filtering operations
ts_con_parquet |>
  dplyr::filter(target_end_date ==  "2022-12-31") |>
  dplyr::collect()
#> # A tibble: 6 × 4
#>   target_end_date target           location observation
#>   <date>          <chr>            <chr>          <dbl>
#> 1 2022-12-31      wk flu hosp rate 02              6.18
#> 2 2022-12-31      wk flu hosp rate 01              2.76
#> 3 2022-12-31      wk flu hosp rate US              5.83
#> 4 2022-12-31      wk inc flu hosp  02             44   
#> 5 2022-12-31      wk inc flu hosp  01            140   
#> 6 2022-12-31      wk inc flu hosp  US          19369   

if (FALSE) { # \dontrun{
# Access Target time-series data from a cloud hub
s3_hub_path <- s3_bucket("example-complex-forecast-hub")
s3_con <- connect_target_timeseries(s3_hub_path)
s3_con
s3_con |> dplyr::collect()
} # }
```
