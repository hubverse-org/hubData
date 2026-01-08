# Accessing Model Output Data

An important function of `hubData` is allowing for the connection to
data in the `model-output` directory to facilitate extraction,
filtering, querying, exploring, and analyzing of Hub data.

## Structure of hubverse datasets

All data returned from connecting to and querying hubs can be read or
validated as a `model_out_tbl` which is a foundational S3 class in the
hubverse ecosystem. A `model_out_tbl` is a long-form
[`tibble`](https://tibble.tidyverse.org/) designed to conform to the
[hubverse data specifications for model output
data](https://docs.hubverse.io/en/latest/user-guide/model-output.html).
In short, the columns of a valid `model_out_tbl` containing model output
data from a hub are:

- `model_id`: this is the unique character identifier of a model.
- `output_type`: a character variable that defines the type of
  representation of model output that is in a given row.
- `output_type_id`: a variable that specifies some additional
  identifying information specific to the output type in a given row,
  e.g., a numeric quantile level, a string giving the name of a possible
  category for a discrete outcome, or an index of a sample.
- `value`: a numeric variable that provides the information about the
  model’s prediction.
- `...` : other columns will be present depending on modeling tasks
  defined by the individual modeling hub. These columns are referred to
  in hubverse terminology as the `task-ID` variables.

Other hubverse tools, designed for data validation, [ensemble
building](https://hubverse-org.github.io/hubEnsembles/),
[visualization](https://github.com/hubverse-org/hubVis), etc…, all are
designed with the “promises” implicit in the data format specified by
`model_out_tbl`. For example, [the `hubEnsembles::linear_pool()`
function](https://hubverse-org.github.io/hubEnsembles/reference/linear_pool.html)
both accepts as input and returns as output `model_out_tbl` objects.

## Hub connections

There are two functions for connecting to `model-output` data:

- [`connect_hub()`](https://hubverse-org.github.io/hubData/dev/reference/connect_hub.md)
  is used for connecting to fully configured hubs (i.e. which contain
  valid `admin.json` and `tasks.json` in a `hub-config` directory). This
  function uses configurations defined in config files in the
  `hub-config/` directory and allows for connecting to hubs with files
  in multiple file formats (allowable formats specified by the
  `file_format` property of `admin.json`).
- [`connect_model_output()`](https://hubverse-org.github.io/hubData/dev/reference/connect_hub.md)
  allows for connecting directly to the contents of a `model-output`
  directory and is useful for connecting to appropriately organised
  files in an informal hub (i.e. which has not been fully configured
  with appropriate `hub-config/` files.)

Both functions establish connections through the
[`arrow`](https://arrow.apache.org/docs/r/) package, specifically by
opening datasets as
[`FileSystemDataset`s](https://arrow.apache.org/docs/r/reference/Dataset.html),
one for each file format. Both functions are also able to connect to
files that are stored locally or in the cloud (e.g. in AWS S3 buckets).

Where multiple file formats are accepted in a single Hub, file format
specific `FileSystemDataset`s are combined into a single `UnionDataset`
for single point access to the entire Hub `model-output` dataset. This
only applies to
[`connect_hub()`](https://hubverse-org.github.io/hubData/dev/reference/connect_hub.md)
in fully configured Hubs, where config files can be used to determine a
unifying schema across all file formats.

In contrast,
[`connect_model_output()`](https://hubverse-org.github.io/hubData/dev/reference/connect_hub.md)
can only be used to open single file format datasets of the format
defined explicitly through the `file_format` argument.

``` r
library(hubData)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
```

## Connecting to a configured hub

### Connecting to a local hub

To connect to a local hub, supply the path to the hub to
[`connect_hub()`](https://hubverse-org.github.io/hubData/dev/reference/connect_hub.md)

``` r
hub_path <- system.file("testhubs/flusight", package = "hubUtils")
hub_con <- hubData::connect_hub(hub_path)
hub_con
#> 
#> ── <hub_connection/UnionDataset> ──
#> 
#> • hub_name: "US CDC FluSight"
#> • hub_path: /home/runner/work/_temp/Library/hubUtils/testhubs/flusight
#> • file_format: "csv(5/5)", "parquet(2/2)", and "arrow(1/1)"
#> • checks: FALSE
#> • file_system: "LocalFileSystem"
#> • model_output_dir:
#>   "/home/runner/work/_temp/Library/hubUtils/testhubs/flusight/forecasts"
#> • config_admin: hub-config/admin.json
#> • config_tasks: hub-config/tasks.json
#> 
#> ── Connection schema
#> hub_connection
#> 8 columns
#> forecast_date: date32[day]
#> horizon: int32
#> target: string
#> location: string
#> output_type: string
#> output_type_id: string
#> value: double
#> model_id: string
```

### Connecting to a hub in the cloud

To connect to a hub in the cloud, first use one of the re-exported
`arrow` helpers
[`s3_bucket()`](https://hubverse-org.github.io/hubData/dev/reference/s3_bucket.md)
or
[`gs_bucket()`](https://hubverse-org.github.io/hubData/dev/reference/gs_bucket.md)
depending on the cloud storage provider, and a string of the bucket
name/path to create the appropriate cloud `*FileSystem` object (For more
details consult the `arrow` article on [Using cloud storage (S3,
GCS)](https://arrow.apache.org/docs/r/articles/fs.html)).

Then supply the resulting `*FileSystem` object to
[`connect_hub()`](https://hubverse-org.github.io/hubData/dev/reference/connect_hub.md).

``` r
hub_path_cloud <- hubData::s3_bucket("hubverse/hubutils/testhubs/simple/")
hub_con_cloud <- hubData::connect_hub(hub_path_cloud)
#> ℹ Updating superseded URL `Infectious-Disease-Modeling-hubs` to `hubverse-org`
#> ℹ Updating superseded URL `Infectious-Disease-Modeling-hubs` to `hubverse-org`
hub_con_cloud
#> 
#> ── <hub_connection/UnionDataset> ──
#> 
#> • hub_name: "Simple Forecast Hub"
#> • hub_path: hubverse/hubutils/testhubs/simple/
#> • file_format: "csv(3/3)" and "parquet(1/1)"
#> • checks: FALSE
#> • file_system: "S3FileSystem"
#> • model_output_dir: "model-output/"
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
```

#### Performance considerations

By default,
[`connect_hub()`](https://hubverse-org.github.io/hubData/dev/reference/connect_hub.md)
skips file validation checks when creating a connection, providing
optimal performance especially for large cloud-based hubs by minimizing
I/O operations.

If you are working with a model output directory that may contain files
that cannot be opened as part of the dataset (e.g., non-model output
files with incompatible formats), you can use `skip_checks = FALSE` to
have
[`connect_hub()`](https://hubverse-org.github.io/hubData/dev/reference/connect_hub.md)
attempt to detect and exclude invalid files before connecting. Note that
this will negatively impact performance due to increased I/O operations.

For most hubs validated through the hubValidations package, the default
`skip_checks = TRUE` behavior is recommended. If invalid files are
present, consider using the `ignore_files` argument instead.

``` r
hub_path_cloud <- hubData::s3_bucket("hubverse/hubutils/testhubs/parquet/")
hub_con_cloud <- hubData::connect_hub(hub_path_cloud, file_format = "parquet")
#> ℹ Updating superseded URL `Infectious-Disease-Modeling-hubs` to `hubverse-org`
#> ℹ Updating superseded URL `Infectious-Disease-Modeling-hubs` to `hubverse-org`
hub_con_cloud
#> 
#> ── <hub_connection/FileSystemDataset> ──
#> 
#> • hub_name: "Simple Forecast Hub"
#> • hub_path: hubverse/hubutils/testhubs/parquet/
#> • file_format: "parquet(4/4)"
#> • checks: FALSE
#> • file_system: "S3FileSystem"
#> • model_output_dir: "model-output/"
#> • config_admin: hub-config/admin.json
#> • config_tasks: hub-config/tasks.json
#> 
#> ── Connection schema
#> hub_connection with 4 Parquet files
#> 9 columns
#> origin_date: date32[day]
#> target: string
#> horizon: int32
#> location: string
#> age_group: string
#> output_type: string
#> output_type_id: double
#> value: int32
#> model_id: string
```

## Accessing data

To access data from a hub connection you can use dplyr verbs and
construct querying pipelines.

To perform the queries, you can use `dplyr`’s
[`collect()`](https://dplyr.tidyverse.org/reference/compute.html)
function:

``` r
hub_con |>
  dplyr::filter(output_type == "quantile", location == "US") |>
  dplyr::collect()
#> # A tibble: 276 × 8
#>    forecast_date horizon target        location output_type output_type_id value
#>    <date>          <int> <chr>         <chr>    <chr>       <chr>          <dbl>
#>  1 2023-05-01          1 wk ahead inc… US       quantile    0.01               0
#>  2 2023-05-01          1 wk ahead inc… US       quantile    0.025              0
#>  3 2023-05-01          1 wk ahead inc… US       quantile    0.05               0
#>  4 2023-05-01          1 wk ahead inc… US       quantile    0.1              193
#>  5 2023-05-01          1 wk ahead inc… US       quantile    0.15             495
#>  6 2023-05-01          1 wk ahead inc… US       quantile    0.2              618
#>  7 2023-05-01          1 wk ahead inc… US       quantile    0.25             717
#>  8 2023-05-01          1 wk ahead inc… US       quantile    0.3              774
#>  9 2023-05-01          1 wk ahead inc… US       quantile    0.35             822
#> 10 2023-05-01          1 wk ahead inc… US       quantile    0.4              857
#> # ℹ 266 more rows
#> # ℹ 1 more variable: model_id <chr>
```

Note however that in the above example, while the output contains the
required `model_id`, `output_type`, `output_type_id` and `value` columns
for a `model_out_tbl` object, it is returned as a `tbl_df` or `tibble`
object and the order of the columns is not standardised.

### Use `collect_hub()` to return `model_out_tbl`s

Conveniently, you can use the `hubData` wrapper
[`collect_hub()`](https://hubverse-org.github.io/hubData/dev/reference/collect_hub.md)
which converts the output of
[`dplyr::collect()`](https://dplyr.tidyverse.org/reference/compute.html)
to a `model_out_tbl` class object where possible:

``` r
tbl <- hub_con |>
  dplyr::filter(output_type == "quantile", location == "US") |>
  hubData::collect_hub()

tbl
#> # A tibble: 276 × 8
#>    model_id     forecast_date horizon target location output_type output_type_id
#>  * <chr>        <date>          <int> <chr>  <chr>    <chr>       <chr>         
#>  1 hub-baseline 2023-04-24          1 wk ah… US       quantile    0.01          
#>  2 hub-baseline 2023-04-24          1 wk ah… US       quantile    0.025         
#>  3 hub-baseline 2023-04-24          1 wk ah… US       quantile    0.05          
#>  4 hub-baseline 2023-04-24          1 wk ah… US       quantile    0.1           
#>  5 hub-baseline 2023-04-24          1 wk ah… US       quantile    0.15          
#>  6 hub-baseline 2023-04-24          1 wk ah… US       quantile    0.2           
#>  7 hub-baseline 2023-04-24          1 wk ah… US       quantile    0.25          
#>  8 hub-baseline 2023-04-24          1 wk ah… US       quantile    0.3           
#>  9 hub-baseline 2023-04-24          1 wk ah… US       quantile    0.35          
#> 10 hub-baseline 2023-04-24          1 wk ah… US       quantile    0.4           
#> # ℹ 266 more rows
#> # ℹ 1 more variable: value <dbl>

class(tbl)
#> [1] "model_out_tbl" "tbl_df"        "tbl"           "data.frame"
```

### Accessing data from cloud hubs

Accessing data from hubs in the cloud is exactly the same:

``` r
hub_con_cloud |>
  dplyr::filter(output_type == "quantile", location == "US") |>
  hubData::collect_hub()
#> # A tibble: 230 × 9
#>    model_id        origin_date target     horizon location age_group output_type
#>  * <chr>           <date>      <chr>        <int> <chr>    <chr>     <chr>      
#>  1 team1-goodmodel 2022-10-08  wk inc fl…       1 US       NA        quantile   
#>  2 team1-goodmodel 2022-10-08  wk inc fl…       1 US       NA        quantile   
#>  3 team1-goodmodel 2022-10-08  wk inc fl…       1 US       NA        quantile   
#>  4 team1-goodmodel 2022-10-08  wk inc fl…       1 US       NA        quantile   
#>  5 team1-goodmodel 2022-10-08  wk inc fl…       1 US       NA        quantile   
#>  6 team1-goodmodel 2022-10-08  wk inc fl…       1 US       NA        quantile   
#>  7 team1-goodmodel 2022-10-08  wk inc fl…       1 US       NA        quantile   
#>  8 team1-goodmodel 2022-10-08  wk inc fl…       1 US       NA        quantile   
#>  9 team1-goodmodel 2022-10-08  wk inc fl…       1 US       NA        quantile   
#> 10 team1-goodmodel 2022-10-08  wk inc fl…       1 US       NA        quantile   
#> # ℹ 220 more rows
#> # ℹ 2 more variables: output_type_id <dbl>, value <int>
```

### Limitations of `dplyr` queries on `arrow` datasets

Note that [not all `dplyr` filtering options are
available](https://arrow.apache.org/docs/dev/r/reference/acero.html) on
arrow datasets.

For example, if you wanted to get all quantile predictions for the last
forecast date in the hub, you might try:

``` r
hub_con |>
  dplyr::filter(
    output_type == "quantile",
    location == "US",
    forecast_date == max(forecast_date, na.rm = TRUE)
  ) |>
  hubData::collect_hub()
#> Error in `forecast_date == max(forecast_date, na.rm = TRUE)`:
#> ! Expression not supported in filter() in Arrow
#> → Call collect() first to pull data into R.
```

This doesn’t work however as `arrow` does not have an equivalent `max`
method for `Date[32]` data types.

In such a situation, you could collect after applying the first
filtering level which does work for arrow and then finish the filtering
on the in-memory data returned by collect.

``` r
hub_con |>
  dplyr::filter(output_type == "quantile", location == "US") |>
  hubData::collect_hub() |>
  dplyr::filter(forecast_date == max(forecast_date))
#> # A tibble: 92 × 8
#>    model_id     forecast_date horizon target location output_type output_type_id
#>    <chr>        <date>          <int> <chr>  <chr>    <chr>       <chr>         
#>  1 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.01          
#>  2 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.025         
#>  3 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.05          
#>  4 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.1           
#>  5 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.15          
#>  6 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.2           
#>  7 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.25          
#>  8 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.3           
#>  9 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.35          
#> 10 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.4           
#> # ℹ 82 more rows
#> # ℹ 1 more variable: value <dbl>
```

Alternatively, depending on the size of the data, in might be quicker to
filter the data in two steps:

1.  get the last forecast date available for the filtered subset.
2.  use the last forecast date in the filtering query.

``` r
last_forecast <- hub_con |>
  dplyr::filter(output_type == "quantile", location == "US") |>
  dplyr::pull(forecast_date, as_vector = TRUE) |>
  max(na.rm = TRUE)


hub_con |>
  dplyr::filter(
    output_type == "quantile",
    location == "US",
    forecast_date == last_forecast
  ) |>
  hubData::collect_hub()
#> # A tibble: 92 × 8
#>    model_id     forecast_date horizon target location output_type output_type_id
#>  * <chr>        <date>          <int> <chr>  <chr>    <chr>       <chr>         
#>  1 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.01          
#>  2 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.025         
#>  3 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.05          
#>  4 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.1           
#>  5 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.15          
#>  6 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.2           
#>  7 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.25          
#>  8 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.3           
#>  9 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.35          
#> 10 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.4           
#> # ℹ 82 more rows
#> # ℹ 1 more variable: value <dbl>
```

#### Use `arrow::to_duckdb()` to extend available queries

You could alternatively use
[`arrow::to_duckdb()`](https://arrow.apache.org/docs/r/reference/to_duckdb.html)
to first convert the dataset connection to an in memory virtual DuckDB
table. This will allows you to run queries that are supported by DuckDB
but not by arrow, extending the potential queries that can be run
against hub data before collecting.

*For more details see [DuckDB quacks Arrow: A zero-copy data integration
between Apache Arrow and
DuckDB](https://duckdb.org/2021/12/03/duck-arrow.html).*

``` r
hub_con |>
  arrow::to_duckdb() |>
  dplyr::filter(
    output_type == "quantile",
    location == "US",
    forecast_date == max(forecast_date, na.rm = TRUE)
  ) |>
  hubData::collect_hub()
#> # A tibble: 92 × 8
#>    model_id     forecast_date horizon target location output_type output_type_id
#>  * <chr>        <date>          <int> <chr>  <chr>    <chr>       <chr>         
#>  1 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.01          
#>  2 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.025         
#>  3 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.05          
#>  4 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.1           
#>  5 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.15          
#>  6 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.2           
#>  7 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.25          
#>  8 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.3           
#>  9 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.35          
#> 10 hub-baseline 2023-05-08          1 wk ah… US       quantile    0.4           
#> # ℹ 82 more rows
#> # ℹ 1 more variable: value <dbl>
```

## Connecting to a model output directory

There is also an option to connect directly to a model output directory
without using any metadata in a hub config file. This can be useful when
a hub has not been fully configured yet.

The approach does have certain limitations though. For example, an
overall unifying schema cannot be determined from the config files so
the ability of
[`open_dataset()`](https://arrow.apache.org/docs/r/reference/open_dataset.html)
to connect and parse data correctly cannot be guaranteed across files.

In addition, only a single file_format dataset can be opened.

``` r
model_output_dir <- system.file(
  "testhubs/simple/model-output",
  package = "hubUtils"
)
mod_out_con <- hubData::connect_model_output(
  model_output_dir,
  file_format = "csv"
)
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
```

Accessing data follows the same procedure described for fully configured
hubs:

``` r
mod_out_con |>
  dplyr::filter(output_type == "quantile", location == "US") |>
  hubData::collect_hub()
#> # A tibble: 138 × 8
#>    model_id origin_date target horizon location output_type output_type_id value
#>  * <chr>    <date>      <chr>    <int> <chr>    <chr>                <dbl> <int>
#>  1 team1-g… 2022-10-08  wk in…       1 US       quantile             0.01    135
#>  2 team1-g… 2022-10-08  wk in…       1 US       quantile             0.025   137
#>  3 team1-g… 2022-10-08  wk in…       1 US       quantile             0.05    139
#>  4 team1-g… 2022-10-08  wk in…       1 US       quantile             0.1     140
#>  5 team1-g… 2022-10-08  wk in…       1 US       quantile             0.15    141
#>  6 team1-g… 2022-10-08  wk in…       1 US       quantile             0.2     141
#>  7 team1-g… 2022-10-08  wk in…       1 US       quantile             0.25    142
#>  8 team1-g… 2022-10-08  wk in…       1 US       quantile             0.3     143
#>  9 team1-g… 2022-10-08  wk in…       1 US       quantile             0.35    144
#> 10 team1-g… 2022-10-08  wk in…       1 US       quantile             0.4     145
#> # ℹ 128 more rows
```

And connecting to cloud model output data follows the same procedure
described for fully configured cloud hubs:

``` r
mod_out_dir_cloud <- hubData::s3_bucket(
  "hubverse/hubutils/testhubs/simple/model-output/"
)
mod_out_con_cloud <- hubData::connect_model_output(
  mod_out_dir_cloud,
  file_format = "csv"
)
mod_out_con_cloud
#> 
#> ── <mod_out_connection/FileSystemDataset> ──
#> 
#> • file_format: "csv(3/3)"
#> • checks: TRUE
#> • file_system: "S3FileSystem"
#> • model_output_dir: "hubverse/hubutils/testhubs/simple/model-output/"
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
```

[`connect_model_output()`](https://hubverse-org.github.io/hubData/dev/reference/connect_hub.md)
also has a `skip_checks` argument. Unlike
[`connect_hub()`](https://hubverse-org.github.io/hubData/dev/reference/connect_hub.md),
which defaults to `skip_checks = TRUE` for optimal performance with
validated hubs,
[`connect_model_output()`](https://hubverse-org.github.io/hubData/dev/reference/connect_hub.md)
defaults to `skip_checks = FALSE` since it is designed to work with
model output directories that may be in draft form and contain invalid
files. You can improve performance by setting `skip_checks = TRUE` if
you know your directory contains only valid model output files:

``` r
mod_out_dir_cloud <- hubData::s3_bucket(
  "hubverse/hubutils/testhubs/parquet/model-output/"
)
mod_out_con_cloud <- hubData::connect_model_output(
  mod_out_dir_cloud,
  file_format = "parquet",
  skip_checks = TRUE
)
mod_out_con_cloud
#> 
#> ── <mod_out_connection/FileSystemDataset> ──
#> 
#> • file_format: "parquet(4/4)"
#> • checks: FALSE
#> • file_system: "S3FileSystem"
#> • model_output_dir: "hubverse/hubutils/testhubs/parquet/model-output/"
#> 
#> ── Connection schema
#> mod_out_connection with 4 Parquet files
#> 9 columns
#> origin_date: date32[day]
#> target: string
#> horizon: int32
#> location: string
#> output_type: string
#> output_type_id: double
#> value: int32
#> age_group: string
#> model_id: string
```

### Providing a custom schema

When connecting to a model output directly, you can also specify a
schema to override the default arrow schema auto-detection. This can
help at times to resolve conflicts in data types across different
dataset files.

``` r
library(arrow)
#> 
#> Attaching package: 'arrow'
#> The following object is masked from 'package:utils':
#> 
#>     timestamp

model_output_schema <- arrow::schema(
  origin_date = date32(),
  target = string(),
  horizon = int32(),
  location = string(),
  output_type = string(),
  output_type_id = string(),
  value = int32(),
  model_id = string()
)

mod_out_con <- hubData::connect_model_output(
  model_output_dir,
  file_format = "csv",
  schema = model_output_schema
)
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
#> horizon: int32
#> location: string
#> output_type: string
#> output_type_id: string
#> value: int32
#> model_id: string
```

Using a schema can however also produce new errors which can sometimes
be hard to debug. For example, here we are defining a schema with field
`output_type` cast as `int32` data type. As column `output_type`
actually contain character type data which cannot be coerced to integer,
connecting to the model output directory produces an `arrow` error.

``` r
model_output_schema <- arrow::schema(
  origin_date = date32(),
  target = string(),
  horizon = int32(),
  location = string(),
  output_type = int32(),
  output_type_id = string(),
  value = int32(),
  model_id = string()
)

mod_out_con <- hubData::connect_model_output(
  model_output_dir,
  file_format = "csv",
  schema = model_output_schema
)
#> Error in `arrow::open_dataset()`:
#> ! Invalid: No non-null segments were available for field 'model_id'; couldn't infer type
```

Beware that `arrow` errors can be somewhat misleading at times so if you
do get such a non-informative error, a good place to start would be to
check your schema matches the columns and your data can be coerced to
the data types specified in the schema.

## Working with target data

While
[`connect_hub()`](https://hubverse-org.github.io/hubData/dev/reference/connect_hub.md)
and
[`connect_model_output()`](https://hubverse-org.github.io/hubData/dev/reference/connect_hub.md)
focus on accessing model predictions, modeling hubs also contain target
data - the “ground truth” observations that models are trying to
predict.

hubData provides dedicated functions for accessing target data:

- [`connect_target_timeseries()`](https://hubverse-org.github.io/hubData/dev/reference/connect_target_timeseries.md) -
  Access historical time-series target observations
- [`connect_target_oracle_output()`](https://hubverse-org.github.io/hubData/dev/reference/connect_target_oracle_output.md) -
  Access target data formatted like model outputs (useful for
  evaluation)

These functions work similarly to
[`connect_hub()`](https://hubverse-org.github.io/hubData/dev/reference/connect_hub.md),
returning Arrow datasets that you can query with `dplyr` verbs and
collect with
[`collect()`](https://dplyr.tidyverse.org/reference/compute.html).

For detailed examples and best practices for working with target data,
including how to join target data with model outputs for evaluation, see
`vignette("connect_target_data")`.
