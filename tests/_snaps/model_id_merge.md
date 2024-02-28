# merging-splitting model_id works

    Code
      model_id_split(tbl)
    Output
      # A tibble: 92 x 9
         team_abbr model_abbr forecast_date horizon target        location output_type
         <chr>     <chr>      <date>          <int> <chr>         <chr>    <chr>      
       1 hub       baseline   2023-05-08          1 wk ahead inc~ US       quantile   
       2 hub       baseline   2023-05-08          1 wk ahead inc~ US       quantile   
       3 hub       baseline   2023-05-08          1 wk ahead inc~ US       quantile   
       4 hub       baseline   2023-05-08          1 wk ahead inc~ US       quantile   
       5 hub       baseline   2023-05-08          1 wk ahead inc~ US       quantile   
       6 hub       baseline   2023-05-08          1 wk ahead inc~ US       quantile   
       7 hub       baseline   2023-05-08          1 wk ahead inc~ US       quantile   
       8 hub       baseline   2023-05-08          1 wk ahead inc~ US       quantile   
       9 hub       baseline   2023-05-08          1 wk ahead inc~ US       quantile   
      10 hub       baseline   2023-05-08          1 wk ahead inc~ US       quantile   
      # i 82 more rows
      # i 2 more variables: output_type_id <chr>, value <dbl>

---

    Code
      model_id_split(tbl)
    Condition
      Error in `model_id_split()`:
      x Cannot split `model_id` column.
      ! Required column "model_id" missing from `tbl`.

---

    Code
      model_id_merge(tbl)
    Condition
      Error in `model_id_merge()`:
      x Cannot create `model_id` column.
      ! Required columns "model_abbr" and "team_abbr" missing from `tbl`.

# Splitting model_id fails if seperator detected

    Code
      model_id_split(tbl)
    Condition
      Error in `model_id_split()`:
      x All `model_id` values must only contain a single separator character "-".
      ! Values "hub-base-line" containing more than one separator character detected in rows 1, 7, and 10.

# Merging model_id fails if seperator detected

    Code
      model_id_merge(tbl)
    Condition
      Error in `model_id_merge()`:
      x `model_abbr` and `team_abbr` values must not contain separator character "-".
      ! Values "base-line" containing separator character detected in `model_abbr` rows 1, 7, and 10.
      ! Values "h-ub" containing separator character detected in `team_abbr` rows 78.

