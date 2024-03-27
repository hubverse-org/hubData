# collect_hub works on local simple forecasting hub

    Code
      collect_hub(hub_con)
    Output
      # A tibble: 599 x 9
         model_id     origin_date target        horizon location age_group output_type
       * <chr>        <date>      <chr>           <int> <chr>    <chr>     <chr>      
       1 hub-baseline 2022-10-01  wk inc flu h~       1 US       <NA>      mean       
       2 hub-baseline 2022-10-01  wk inc flu h~       1 US       <NA>      quantile   
       3 hub-baseline 2022-10-01  wk inc flu h~       1 US       <NA>      quantile   
       4 hub-baseline 2022-10-01  wk inc flu h~       1 US       <NA>      quantile   
       5 hub-baseline 2022-10-01  wk inc flu h~       1 US       <NA>      quantile   
       6 hub-baseline 2022-10-01  wk inc flu h~       1 US       <NA>      quantile   
       7 hub-baseline 2022-10-01  wk inc flu h~       1 US       <NA>      quantile   
       8 hub-baseline 2022-10-01  wk inc flu h~       1 US       <NA>      quantile   
       9 hub-baseline 2022-10-01  wk inc flu h~       1 US       <NA>      quantile   
      10 hub-baseline 2022-10-01  wk inc flu h~       1 US       <NA>      quantile   
      # i 589 more rows
      # i 2 more variables: output_type_id <dbl>, value <int>

---

    Code
      dplyr::filter(hub_con, is.na(output_type_id)) %>% collect_hub()
    Output
      # A tibble: 1 x 9
        model_id     origin_date target         horizon location age_group output_type
      * <chr>        <date>      <chr>            <int> <chr>    <chr>     <chr>      
      1 hub-baseline 2022-10-01  wk inc flu ho~       1 US       <NA>      mean       
      # i 2 more variables: output_type_id <dbl>, value <int>

---

    Code
      dplyr::filter(hub_con, is.na(output_type_id)) %>% collect_hub(remove_empty = TRUE)
    Output
      # A tibble: 1 x 8
        model_id  origin_date target horizon location output_type output_type_id value
      * <chr>     <date>      <chr>    <int> <chr>    <chr>                <dbl> <int>
      1 hub-base~ 2022-10-01  wk in~       1 US       mean                    NA   150

---

    Code
      dplyr::filter(hub_con, is.na(output_type_id)) %>% dplyr::select(target) %>%
        collect_hub()
    Message
      ! `model_id` column missing. Attempting to create automatically.
      Cannot coerce to <model_out_tbl>
      ! Cannot create `model_id` column.
    Output
      # A tibble: 1 x 1
        target         
        <chr>          
      1 wk inc flu hosp

---

    Code
      dplyr::filter(hub_con, is.na(output_type_id)) %>% dplyr::select(target) %>%
        collect_hub(silent = TRUE)
    Output
      # A tibble: 1 x 1
        target         
        <chr>          
      1 wk inc flu hosp

# collect_hub returns NULL with warning when model output folder is empty

    Code
      collect_hub(hub_con)
    Condition
      Warning:
      Hub is empty. No data to collect. Returning `NULL`
    Output
      NULL

# collect_hub works on model output directories

    Code
      dplyr::filter(mod_out_con, is.na(output_type_id)) %>% collect_hub()
    Output
      # A tibble: 1 x 8
        model_id  origin_date target horizon location output_type output_type_id value
      * <chr>     <date>      <chr>    <int> <chr>    <chr>                <dbl> <int>
      1 hub-base~ 2022-10-01  wk in~       1 US       mean                    NA   150

---

    Code
      dplyr::filter(mod_out_con, is.na(output_type_id)) %>% dplyr::select(target) %>%
        collect_hub()
    Message
      ! `model_id` column missing. Attempting to create automatically.
      Cannot coerce to <model_out_tbl>
      ! Cannot create `model_id` column.
    Output
      # A tibble: 1 x 1
        target         
        <chr>          
      1 wk inc flu hosp

---

    Code
      dplyr::filter(mod_out_con, is.na(output_type_id)) %>% dplyr::select(target) %>%
        collect_hub(silent = TRUE)
    Output
      # A tibble: 1 x 1
        target         
        <chr>          
      1 wk inc flu hosp

