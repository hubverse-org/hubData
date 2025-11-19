# Get expected target data column names from config

Extracts the expected column names for target data from a hub's
configuration files in the correct order. This is useful for validation
and schema generation without needing to inspect the actual dataset.

## Usage

``` r
get_target_data_colnames(
  config_target_data,
  target_type = c("time-series", "oracle-output")
)
```

## Arguments

- config_target_data:

  A `config_target_data` object (from
  `hubUtils::read_config(hub_path, "target-data")`)

- target_type:

  Character string specifying the target data type. Must be either
  `"time-series"` or `"oracle-output"`.

## Value

A character vector of expected column names in the correct order:

- Date column

- Task ID columns (from `observable_unit`)

- Non-task ID columns (time-series only, if specified in config)

- Output type columns (`output_type` and `output_type_id`, oracle-output
  only if specified in config)

- Target value column (`observation` for time-series, `oracle_value` for
  oracle-output)

- `as_of` column (if data is versioned)

## Details

The function builds the column name vector directly from the
configuration objects without requiring dataset inspection. This makes
it lightweight, efficient, and suitable for validation purposes.

For **time-series** data, columns are ordered as:

1.  Task ID columns from `observable_unit`

2.  Date column (if not in `observable_unit`)

3.  Non-task ID columns from `target-data.json` (if present)

4.  `observation` column (target value)

5.  `as_of` column (if `versioned = TRUE`)

For **oracle-output** data, columns are ordered as:

1.  Task ID columns from `observable_unit`

2.  Date column (if not in `observable_unit`)

3.  `output_type` and `output_type_id` columns (if
    `has_output_type_ids = TRUE`)

4.  `oracle_value` column (target value)

5.  `as_of` column (if `versioned = TRUE`)

## Examples

``` r
# Note: These examples require test data
hub_path <- system.file("testhubs/v6/target_file", package = "hubUtils")
config_target_data <- hubUtils::read_config(hub_path, "target-data")

# Get time-series column names
get_target_data_colnames(
  config_target_data,
  target_type = "time-series"
)
#> [1] "target_end_date" "target"          "location"        "observation"    

# Get oracle-output column names
get_target_data_colnames(
  config_target_data,
  target_type = "oracle-output"
)
#> [1] "target_end_date" "target"          "location"        "output_type"    
#> [5] "output_type_id"  "oracle_value"   
```
