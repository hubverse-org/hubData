# Collect Hub model output data

`collect_hub` retrieves data from a
`<hub_connection>/<mod_out_connection>` after executing any
`<arrow_dplyr_query>` into a local tibble. The function also attempts to
convert the output to a `model_out_tbl` class object before returning.

## Usage

``` r
collect_hub(x, silent = FALSE, ...)
```

## Arguments

- x:

  a `<hub_connection>/<mod_out_connection>` or `<arrow_dplyr_query>`
  object.

- silent:

  Logical. Whether to suppress message generated if conversion to
  `model_out_tbl` fails.

- ...:

  Further argument passed on to
  [`as_model_out_tbl()`](https://hubverse-org.github.io/hubUtils/reference/as_model_out_tbl.html).

## Value

A `model_out_tbl`, unless conversion to `model_out_tbl` fails in which
case a `tibble` is returned.

## Examples

``` r
hub_path <- system.file("testhubs/simple", package = "hubUtils")
hub_con <- connect_hub(hub_path)
# Collect all data in a hub
hub_con %>% collect_hub()
#> # A tibble: 599 × 9
#>    model_id     origin_date target        horizon location age_group output_type
#>  * <chr>        <date>      <chr>           <int> <chr>    <chr>     <chr>      
#>  1 hub-baseline 2022-10-01  wk inc flu h…       1 US       NA        mean       
#>  2 hub-baseline 2022-10-01  wk inc flu h…       1 US       NA        quantile   
#>  3 hub-baseline 2022-10-01  wk inc flu h…       1 US       NA        quantile   
#>  4 hub-baseline 2022-10-01  wk inc flu h…       1 US       NA        quantile   
#>  5 hub-baseline 2022-10-01  wk inc flu h…       1 US       NA        quantile   
#>  6 hub-baseline 2022-10-01  wk inc flu h…       1 US       NA        quantile   
#>  7 hub-baseline 2022-10-01  wk inc flu h…       1 US       NA        quantile   
#>  8 hub-baseline 2022-10-01  wk inc flu h…       1 US       NA        quantile   
#>  9 hub-baseline 2022-10-01  wk inc flu h…       1 US       NA        quantile   
#> 10 hub-baseline 2022-10-01  wk inc flu h…       1 US       NA        quantile   
#> # ℹ 589 more rows
#> # ℹ 2 more variables: output_type_id <dbl>, value <int>
# Filter data before collecting
hub_con %>%
  dplyr::filter(is.na(output_type_id)) %>%
  collect_hub()
#> # A tibble: 1 × 9
#>   model_id     origin_date target         horizon location age_group output_type
#> * <chr>        <date>      <chr>            <int> <chr>    <chr>     <chr>      
#> 1 hub-baseline 2022-10-01  wk inc flu ho…       1 US       NA        mean       
#> # ℹ 2 more variables: output_type_id <dbl>, value <int>
# Pass arguments to as_model_out_tbl()
dplyr::filter(hub_con, is.na(output_type_id)) %>%
  collect_hub(remove_empty = TRUE)
#> # A tibble: 1 × 8
#>   model_id  origin_date target horizon location output_type output_type_id value
#> * <chr>     <date>      <chr>    <int> <chr>    <chr>                <dbl> <int>
#> 1 hub-base… 2022-10-01  wk in…       1 US       mean                    NA   150
```
