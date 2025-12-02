# Accessing Target Data

## Introduction

Target data represents the “ground truth” observations that models are
trying to predict in forecasting hubs. Understanding how to access and
work with target data is essential for evaluating model performance,
creating visualizations, and conducting analyses.

For a comprehensive overview of what target data is and why it matters
in the context of modeling hubs, please refer to the [Hubverse target
data
guide](https://docs.hubverse.io/en/latest/user-guide/target-data.html).

This vignette focuses on the practical aspects of accessing target data
using hubData’s specialized functions:

- **Time-series target data**: Historical observations (stored as
  `target-data/time-series.csv`, `target-data/time-series.parquet`, or
  in a `target-data/time-series/` directory)
- **Oracle-output target data**: Model-formatted target observations
  (stored as `target-data/oracle-output.csv`,
  `target-data/oracle-output.parquet`, or in a
  `target-data/oracle-output/` directory)

## Target data structure

Modeling hubs store target data in two complementary formats, each
serving distinct purposes in the forecasting workflow:

### Time-series format

Time-series target data represents the **observed counts or rates** in
their native format. Each row constitutes an **observable unit** - a
unique combination of task ID variables that defines a single
observation. This format typically includes:

- A date variable
- Location identifiers
- An `observation` column containing the measured value (e.g., case
  counts, hospitalization numbers)
- Other task ID variables

For example, if your task IDs are location and date, then each
observable unit is a specific location-date combination (e.g., “US on
2022-10-15”), and the `observation` column contains the value measured
for that unit.

**Why time-series format?** This format is designed for:

- **Model fitting**: Providing historical data for parameter estimation
  and model training
- **Visualization**: Supporting tools like hubVis and dashboards that
  display historical trends
- **General analysis**: Working with target data in its natural,
  observational form

### Oracle-output format

Oracle-output target data are generally **derived from time-series
data** but formatted to match the structure of model outputs (similar to
`model_out_tbl` objects). It represents “what predictions would look
like if the target values had been known ahead of time.” Like
time-series data, each row represents an **observable unit** defined by
the task ID variables, but the data is structured as model output. This
format includes:

- `output_type` and `output_type_id`: Only required if the hub collects
  `pmf` or `cdf` output types. For `mean`, `median`, `quantile`, and
  `sample` output types, these columns can be omitted entirely.
- `oracle_value`: the target observation value formatted as an “oracle”
  prediction
- Task ID variables (e.g., location, date)

**Why oracle-output format?** This format is designed for:

- **Model evaluation**: Enabling evaluation tools like hubEvals to
  directly compare model predictions against observed outcomes
- **Visualization**: Supporting plots that display predictions alongside
  target data in a consistent format (e.g., plotting pmf predictions
  with categorical target data)

By formatting target data as model output with all probability mass on
the observed outcome, oracle-output data allows evaluation tools to
treat it identically to model predictions.

## Connection approach

Accessing target data follows the same approach as accessing model
outputs (see `vignette("connect_hub")` for more details):

- Connections are established through the
  [`arrow`](https://arrow.apache.org/docs/r/) package, opening datasets
  as
  [`FileSystemDataset`s](https://arrow.apache.org/docs/r/reference/Dataset.html)
- Both
  [`connect_target_timeseries()`](https://hubverse-org.github.io/hubData/dev/reference/connect_target_timeseries.md)
  and
  [`connect_target_oracle_output()`](https://hubverse-org.github.io/hubData/dev/reference/connect_target_oracle_output.md)
  work with data stored locally or in the cloud (e.g., in AWS S3
  buckets)
- The functions use hub configuration files to determine the appropriate
  schema for the target data
- Once connected, you can use `dplyr` verbs to filter and query the data
  before collecting it into memory

This means the same workflows you use for model output data also apply
to target data.

## Accessing time-series target data

First, load the required packages:

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

Use
[`connect_target_timeseries()`](https://hubverse-org.github.io/hubData/dev/reference/connect_target_timeseries.md)
to open a connection to time-series target data:

``` r
hub_path <- system.file("testhubs/v6/target_dir", package = "hubUtils")
ts_con <- connect_target_timeseries(hub_path)
ts_con
#> target_timeseries with 2 Parquet files
#> 4 columns
#> target_end_date: date32[day]
#> target: string
#> location: string
#> observation: double
```

This shows the Arrow dataset structure, including the schema (column
names and data types) and information about the underlying file(s). The
connection is lazy - no data is loaded into memory until you explicitly
collect it.

You can query and collect data from the connection using `dplyr` verbs:

``` r
# Collect all time-series data
ts_con |>
  collect()
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
```

### Filtering time-series data

You can filter before collecting to work with subsets of the data:

``` r
# Filter by location
ts_con |>
  filter(location == "US") |>
  collect()
#> # A tibble: 22 × 4
#>    target_end_date target           location observation
#>    <date>          <chr>            <chr>          <dbl>
#>  1 2022-10-22      wk flu hosp rate US             0.716
#>  2 2022-10-29      wk flu hosp rate US             1.31 
#>  3 2022-11-05      wk flu hosp rate US             1.98 
#>  4 2022-11-12      wk flu hosp rate US             2.66 
#>  5 2022-11-19      wk flu hosp rate US             3.44 
#>  6 2022-11-26      wk flu hosp rate US             5.97 
#>  7 2022-12-03      wk flu hosp rate US             7.93 
#>  8 2022-12-10      wk flu hosp rate US             7.18 
#>  9 2022-12-17      wk flu hosp rate US             6.45 
#> 10 2022-12-24      wk flu hosp rate US             5.81 
#> # ℹ 12 more rows

# Filter by date range
ts_con |>
  filter(target_end_date >= "2022-10-01") |>
  collect()
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

# Combine multiple filters
ts_con |>
  filter(
    location %in% c("US", "01"),
    target_end_date >= "2022-10-01"
  ) |>
  collect()
#> # A tibble: 44 × 4
#>    target_end_date target           location observation
#>    <date>          <chr>            <chr>          <dbl>
#>  1 2022-10-22      wk flu hosp rate 01             2.78 
#>  2 2022-10-22      wk flu hosp rate US             0.716
#>  3 2022-10-29      wk flu hosp rate 01             5.17 
#>  4 2022-10-29      wk flu hosp rate US             1.31 
#>  5 2022-11-05      wk flu hosp rate 01             7.11 
#>  6 2022-11-05      wk flu hosp rate US             1.98 
#>  7 2022-11-12      wk flu hosp rate 01             5.98 
#>  8 2022-11-12      wk flu hosp rate US             2.66 
#>  9 2022-11-19      wk flu hosp rate 01             4.46 
#> 10 2022-11-19      wk flu hosp rate US             3.44 
#> # ℹ 34 more rows
```

## Accessing oracle-output target data

Use
[`connect_target_oracle_output()`](https://hubverse-org.github.io/hubData/dev/reference/connect_target_oracle_output.md)
to open a connection to oracle-output target data:

``` r
oo_con <- connect_target_oracle_output(hub_path)
oo_con
#> target_oracle_output with 5 Parquet files
#> 6 columns
#> target_end_date: date32[day]
#> target: string
#> location: string
#> output_type: string
#> output_type_id: string
#> oracle_value: double
```

Like the time-series connection, this displays the Arrow dataset
structure with the schema showing columns formatted like model outputs.
Notice the presence of columns like `output_type`, `output_type_id`, and
`oracle_value`.

You can query and collect data from this connection:

``` r
# Collect all oracle-output data
oo_con |>
  collect()
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
```

### Filtering oracle-output data

Oracle-output data has the same structure as model output, making it
easy to filter by output type:

``` r
# Get quantile forecasts only
oo_con |>
  filter(output_type == "quantile") |>
  collect()
#> # A tibble: 33 × 6
#>    target_end_date target       location output_type output_type_id oracle_value
#>    <date>          <chr>        <chr>    <chr>       <chr>                 <dbl>
#>  1 2022-10-22      wk inc flu … US       quantile    NA                     2380
#>  2 2022-10-22      wk inc flu … 01       quantile    NA                      141
#>  3 2022-10-22      wk inc flu … 02       quantile    NA                        3
#>  4 2022-10-29      wk inc flu … US       quantile    NA                     4353
#>  5 2022-10-29      wk inc flu … 01       quantile    NA                      262
#>  6 2022-10-29      wk inc flu … 02       quantile    NA                       14
#>  7 2022-11-05      wk inc flu … US       quantile    NA                     6571
#>  8 2022-11-05      wk inc flu … 01       quantile    NA                      360
#>  9 2022-11-05      wk inc flu … 02       quantile    NA                       10
#> 10 2022-11-12      wk inc flu … US       quantile    NA                     8848
#> # ℹ 23 more rows
```

Notice that `output_type_id` is `NA` for quantile outputs. This is
because the oracle value represents the observed outcome with all
probability mass concentrated on that single value - the `oracle_value`
applies to all quantile levels. For `pmf` or `cdf` output types,
`output_type_id` would specify the category or threshold.

``` r
# Get specific pmf category
oo_con |>
  filter(
    output_type == "pmf",
    output_type_id == "large"
  ) |>
  collect()
#> # A tibble: 0 × 6
#> # ℹ 6 variables: target_end_date <date>, target <chr>, location <chr>,
#> #   output_type <chr>, output_type_id <chr>, oracle_value <dbl>

# Filter by location and date
oo_con |>
  filter(
    location == "US",
    target_end_date == "2022-12-31"
  ) |>
  collect()
#> # A tibble: 19 × 6
#>    target_end_date target       location output_type output_type_id oracle_value
#>    <date>          <chr>        <chr>    <chr>       <chr>                 <dbl>
#>  1 2022-12-31      wk inc flu … US       mean        NA                    19369
#>  2 2022-12-31      wk flu hosp… US       pmf         low                       0
#>  3 2022-12-31      wk flu hosp… US       pmf         moderate                  0
#>  4 2022-12-31      wk flu hosp… US       pmf         high                      1
#>  5 2022-12-31      wk flu hosp… US       pmf         very high                 0
#>  6 2022-12-31      wk inc flu … US       quantile    NA                    19369
#>  7 2022-12-31      wk flu hosp… US       cdf         1                         0
#>  8 2022-12-31      wk flu hosp… US       cdf         2                         0
#>  9 2022-12-31      wk flu hosp… US       cdf         3                         0
#> 10 2022-12-31      wk flu hosp… US       cdf         4                         0
#> 11 2022-12-31      wk flu hosp… US       cdf         5                         0
#> 12 2022-12-31      wk flu hosp… US       cdf         6                         1
#> 13 2022-12-31      wk flu hosp… US       cdf         7                         1
#> 14 2022-12-31      wk flu hosp… US       cdf         8                         1
#> 15 2022-12-31      wk flu hosp… US       cdf         9                         1
#> 16 2022-12-31      wk flu hosp… US       cdf         10                        1
#> 17 2022-12-31      wk flu hosp… US       cdf         11                        1
#> 18 2022-12-31      wk flu hosp… US       cdf         12                        1
#> 19 2022-12-31      wk inc flu … US       sample      NA                    19369
```

## Working with target data

### Joining target data with model outputs

A common workflow is to join oracle-output target data with model
predictions for evaluation. Let’s start by connecting to the model
outputs and collecting predictions:

``` r
# Connect to model outputs
hub_con <- connect_hub(hub_path)

# Collect model outputs for a specific location and output type
model_data <- hub_con |>
  filter(
    output_type == "quantile",
    location == "US"
  ) |>
  collect_hub()

model_data
#> # A tibble: 132 × 9
#>    model_id   location reference_date horizon target_end_date target output_type
#>  * <chr>      <chr>    <date>           <int> <date>          <chr>  <chr>      
#>  1 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#>  2 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#>  3 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#>  4 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#>  5 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#>  6 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#>  7 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#>  8 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#>  9 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#> 10 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#> # ℹ 122 more rows
#> # ℹ 2 more variables: output_type_id <chr>, value <dbl>
```

Next, collect the corresponding oracle-output target data:

``` r
# Collect corresponding oracle-output target data
target_data <- oo_con |>
  filter(
    output_type == "quantile",
    location == "US"
  ) |>
  collect()

target_data
#> # A tibble: 11 × 6
#>    target_end_date target       location output_type output_type_id oracle_value
#>    <date>          <chr>        <chr>    <chr>       <chr>                 <dbl>
#>  1 2022-10-22      wk inc flu … US       quantile    NA                     2380
#>  2 2022-10-29      wk inc flu … US       quantile    NA                     4353
#>  3 2022-11-05      wk inc flu … US       quantile    NA                     6571
#>  4 2022-11-12      wk inc flu … US       quantile    NA                     8848
#>  5 2022-11-19      wk inc flu … US       quantile    NA                    11427
#>  6 2022-11-26      wk inc flu … US       quantile    NA                    19846
#>  7 2022-12-03      wk inc flu … US       quantile    NA                    26333
#>  8 2022-12-10      wk inc flu … US       quantile    NA                    23851
#>  9 2022-12-17      wk inc flu … US       quantile    NA                    21435
#> 10 2022-12-24      wk inc flu … US       quantile    NA                    19286
#> 11 2022-12-31      wk inc flu … US       quantile    NA                    19369
```

Before joining, we need to remove the `output_type` and `output_type_id`
columns from the oracle-output data. For quantile (and mean, median,
sample) outputs, these columns don’t provide useful information since
the oracle value applies across all quantile levels. Keeping them would
cause merge conflicts.

**Note:** For `pmf` or `cdf` output types, you would need to keep these
columns as they specify the category or threshold being predicted.

``` r
# Remove unnecessary columns that would cause merge conflicts
target_data <- target_data |>
  select(-c(output_type, output_type_id))

# Join on common task ID columns
join_cols <- c("location", "target_end_date", "target")

comparison <- model_data |>
  inner_join(
    target_data,
    by = join_cols
  )

comparison
#> # A tibble: 132 × 10
#>    model_id   location reference_date horizon target_end_date target output_type
#>    <chr>      <chr>    <date>           <int> <date>          <chr>  <chr>      
#>  1 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#>  2 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#>  3 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#>  4 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#>  5 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#>  6 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#>  7 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#>  8 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#>  9 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#> 10 Flusight-… US       2022-11-19           1 2022-11-26      wk in… quantile   
#> # ℹ 122 more rows
#> # ℹ 3 more variables: output_type_id <chr>, value <dbl>, oracle_value <dbl>
```

Now we have successfully aligned predicted values (`value`) with target
observations (`oracle_value`) for each combination of task IDs.

#### Special case: Hubs with horizon-based forecasts

Some hubs collect forecasts using only a reference date (or origin date)
and a horizon column, rather than explicitly storing the target end
date. In these cases, the target end date is often calculated as
`origin_date + (horizon * 7L)` (assuming weekly forecasts).

``` r
# Model data without target_end_date
model_data_horizon
#> # A tibble: 132 × 8
#>    model_id    location reference_date horizon target output_type output_type_id
#>    <chr>       <chr>    <date>           <int> <chr>  <chr>       <chr>         
#>  1 Flusight-b… US       2022-11-19           1 wk in… quantile    0.025         
#>  2 Flusight-b… US       2022-11-19           1 wk in… quantile    0.1           
#>  3 Flusight-b… US       2022-11-19           1 wk in… quantile    0.2           
#>  4 Flusight-b… US       2022-11-19           1 wk in… quantile    0.3           
#>  5 Flusight-b… US       2022-11-19           1 wk in… quantile    0.4           
#>  6 Flusight-b… US       2022-11-19           1 wk in… quantile    0.5           
#>  7 Flusight-b… US       2022-11-19           1 wk in… quantile    0.6           
#>  8 Flusight-b… US       2022-11-19           1 wk in… quantile    0.7           
#>  9 Flusight-b… US       2022-11-19           1 wk in… quantile    0.8           
#> 10 Flusight-b… US       2022-11-19           1 wk in… quantile    0.9           
#> # ℹ 122 more rows
#> # ℹ 1 more variable: value <dbl>
```

When working with such hubs, you’ll need to calculate the
`target_end_date` in the model output data before joining with target
data:

``` r
# Calculate target_end_date from origin_date and horizon
model_data_horizon <- model_data_horizon |>
  mutate(
    target_end_date = reference_date + (horizon * 7L)
  )

model_data_horizon
#> # A tibble: 132 × 9
#>    model_id    location reference_date horizon target output_type output_type_id
#>    <chr>       <chr>    <date>           <int> <chr>  <chr>       <chr>         
#>  1 Flusight-b… US       2022-11-19           1 wk in… quantile    0.025         
#>  2 Flusight-b… US       2022-11-19           1 wk in… quantile    0.1           
#>  3 Flusight-b… US       2022-11-19           1 wk in… quantile    0.2           
#>  4 Flusight-b… US       2022-11-19           1 wk in… quantile    0.3           
#>  5 Flusight-b… US       2022-11-19           1 wk in… quantile    0.4           
#>  6 Flusight-b… US       2022-11-19           1 wk in… quantile    0.5           
#>  7 Flusight-b… US       2022-11-19           1 wk in… quantile    0.6           
#>  8 Flusight-b… US       2022-11-19           1 wk in… quantile    0.7           
#>  9 Flusight-b… US       2022-11-19           1 wk in… quantile    0.8           
#> 10 Flusight-b… US       2022-11-19           1 wk in… quantile    0.9           
#> # ℹ 122 more rows
#> # ℹ 2 more variables: value <dbl>, target_end_date <date>
```

Now we can join with target data as before:

``` r
join_cols <- c("location", "target_end_date", "target")

comparison_horizon <- model_data_horizon |>
  inner_join(
    target_data,
    by = join_cols
  )

comparison_horizon
#> # A tibble: 132 × 10
#>    model_id    location reference_date horizon target output_type output_type_id
#>    <chr>       <chr>    <date>           <int> <chr>  <chr>       <chr>         
#>  1 Flusight-b… US       2022-11-19           1 wk in… quantile    0.025         
#>  2 Flusight-b… US       2022-11-19           1 wk in… quantile    0.1           
#>  3 Flusight-b… US       2022-11-19           1 wk in… quantile    0.2           
#>  4 Flusight-b… US       2022-11-19           1 wk in… quantile    0.3           
#>  5 Flusight-b… US       2022-11-19           1 wk in… quantile    0.4           
#>  6 Flusight-b… US       2022-11-19           1 wk in… quantile    0.5           
#>  7 Flusight-b… US       2022-11-19           1 wk in… quantile    0.6           
#>  8 Flusight-b… US       2022-11-19           1 wk in… quantile    0.7           
#>  9 Flusight-b… US       2022-11-19           1 wk in… quantile    0.8           
#> 10 Flusight-b… US       2022-11-19           1 wk in… quantile    0.9           
#> # ℹ 122 more rows
#> # ℹ 3 more variables: value <dbl>, target_end_date <date>, oracle_value <dbl>
```

Note: The multiplier (7L) assumes weekly horizons. Adjust this based on
your hub’s configuration (e.g., 1L for daily horizons).

### Computing simple metrics

Once you have both model predictions and target data, you can compute
evaluation metrics:

``` r
# Calculate absolute error for median forecasts
comparison |>
  filter(output_type_id == "0.5") |>
  mutate(
    abs_error = abs(value - oracle_value)
  ) |>
  group_by(model_id) |>
  summarise(
    mean_abs_error = mean(abs_error, na.rm = TRUE),
    .groups = "drop"
  )
#> # A tibble: 3 × 2
#>   model_id          mean_abs_error
#>   <chr>                      <dbl>
#> 1 Flusight-baseline          9050.
#> 2 MOBS-GLEAM_FLUH            5475.
#> 3 PSI-DICE                   6526.
```

This workflow of aligning predictions with target observations and
computing metrics is exactly what evaluation tools like hubEvals
automate as part of comprehensive model evaluation pipelines.

## Accessing target data from cloud hubs

Both
[`connect_target_timeseries()`](https://hubverse-org.github.io/hubData/dev/reference/connect_target_timeseries.md)
and
[`connect_target_oracle_output()`](https://hubverse-org.github.io/hubData/dev/reference/connect_target_oracle_output.md)
work seamlessly with cloud-based hubs. Use the same cloud connection
approach as with
[`connect_hub()`](https://hubverse-org.github.io/hubData/dev/reference/connect_hub.md):

``` r
# Connect to a cloud hub
s3_hub_path <- s3_bucket("example-complex-forecast-hub")

# Access time-series target data from cloud
ts_cloud <- connect_target_timeseries(s3_hub_path)
ts_cloud
#> target_timeseries with 1 csv file
#> 4 columns
#> target_end_date: date32[day]
#> target: string
#> location: string
#> observation: double
```

``` r
# Collect a sample of the data
ts_cloud |>
  filter(location == "US") |>
  collect()
#> # A tibble: 402 × 4
#>    target_end_date target          location observation
#>    <date>          <chr>           <chr>          <dbl>
#>  1 2020-01-11      wk inc flu hosp US                 1
#>  2 2020-01-18      wk inc flu hosp US                 0
#>  3 2020-01-25      wk inc flu hosp US                 0
#>  4 2020-02-01      wk inc flu hosp US                 0
#>  5 2020-02-08      wk inc flu hosp US                 0
#>  6 2020-02-15      wk inc flu hosp US                 0
#>  7 2020-02-22      wk inc flu hosp US                 0
#>  8 2020-02-29      wk inc flu hosp US                 0
#>  9 2020-03-07      wk inc flu hosp US                 0
#> 10 2020-03-14      wk inc flu hosp US                 0
#> # ℹ 392 more rows
```

``` r
# Access oracle-output target data from cloud
oo_cloud <- connect_target_oracle_output(s3_hub_path)
oo_cloud
#> target_oracle_output with 1 csv file
#> 6 columns
#> location: string
#> target_end_date: date32[day]
#> target: string
#> output_type: string
#> output_type_id: string
#> oracle_value: double
```

``` r
# Collect a sample of oracle-output data
oo_cloud |>
  filter(location == "US") |>
  collect()
#> # A tibble: 3,780 × 6
#>    location target_end_date target       output_type output_type_id oracle_value
#>    <chr>    <date>          <chr>        <chr>       <chr>                 <dbl>
#>  1 US       2022-10-22      wk inc flu … quantile    NA                     2380
#>  2 US       2022-10-29      wk inc flu … quantile    NA                     4353
#>  3 US       2022-11-05      wk inc flu … quantile    NA                     6571
#>  4 US       2022-11-12      wk inc flu … quantile    NA                     8848
#>  5 US       2022-11-19      wk inc flu … quantile    NA                    11427
#>  6 US       2022-11-26      wk inc flu … quantile    NA                    19846
#>  7 US       2022-12-03      wk inc flu … quantile    NA                    26333
#>  8 US       2022-12-10      wk inc flu … quantile    NA                    23851
#>  9 US       2022-12-17      wk inc flu … quantile    NA                    21435
#> 10 US       2022-12-24      wk inc flu … quantile    NA                    19286
#> # ℹ 3,770 more rows
```

### Performance tips for cloud hubs

When working with cloud-based target data, consider these performance
tips:

1.  **Filter before collecting**: Always apply filters on the Arrow
    dataset before calling
    [`collect()`](https://dplyr.tidyverse.org/reference/compute.html) to
    minimize data transfer:

``` r
# Good: filter first, then collect
ts_cloud |>
  filter(location == "US") |>
  collect()

# Less efficient: collect everything, then filter
ts_cloud |>
  collect() |>
  filter(location == "US")
```

2.  **Select specific columns**: If you only need certain columns, use
    [`select()`](https://dplyr.tidyverse.org/reference/select.html)
    before collecting:

``` r
ts_cloud |>
  select(location, target_end_date, observation) |>
  filter(location == "US") |>
  collect()
#> # A tibble: 402 × 3
#>    location target_end_date observation
#>    <chr>    <date>                <dbl>
#>  1 US       2020-01-11                1
#>  2 US       2020-01-18                0
#>  3 US       2020-01-25                0
#>  4 US       2020-02-01                0
#>  5 US       2020-02-08                0
#>  6 US       2020-02-15                0
#>  7 US       2020-02-22                0
#>  8 US       2020-02-29                0
#>  9 US       2020-03-07                0
#> 10 US       2020-03-14                0
#> # ℹ 392 more rows
```

## Hub version compatibility

The target data functions work transparently across different hub
versions:

- **Newer hubs (v6+)** with `target-data.json` configuration benefit
  from optimized schema creation and potentially better performance
- **Older hubs** without `target-data.json` have their schemas inferred
  automatically from data files

As a user, you don’t need to worry about these implementation details -
the same API works for all hubs, and the functions automatically detect
and use the appropriate method.

## Summary

- Use
  [`connect_target_timeseries()`](https://hubverse-org.github.io/hubData/dev/reference/connect_target_timeseries.md)
  for historical observational data
- Use
  [`connect_target_oracle_output()`](https://hubverse-org.github.io/hubData/dev/reference/connect_target_oracle_output.md)
  for model-formatted target data
- Both functions return Arrow datasets that work with `dplyr` verbs
- Filter before collecting to improve performance, especially for cloud
  hubs
- Oracle-output format makes it easy to join with model predictions for
  evaluation
- The same API works across all hub versions

For more information on: - Model output data, see
`vignette("connect_hub")` - Target data concepts, see the [Hubverse
target data
guide](https://docs.hubverse.io/en/latest/user-guide/target-data.html)
