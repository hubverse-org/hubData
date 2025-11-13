# Mapping of Arrow types to base R types

A named character vector mapping common arrow::Schema field types (as
strings) to their corresponding base R types. This mapping is used to
translate or validate column types when working with Parquet files or
Arrow datasets, especially for schema inference and compatibility
checks.

## Usage

``` r
arrow_to_r_datatypes
```

## Format

A named character vector with 8 entries.

## Details

Only the safest and most portable Arrow types are supported in the
hubverse. Types not present in this mapping should be treated as
unsupported.

|                 |             |                         |
|-----------------|-------------|-------------------------|
| Arrow type      | R type      | Notes                   |
| `bool`          | `logical`   |                         |
| `int32`         | `integer`   |                         |
| `int64`         | `integer`   | R supports via Arrow    |
| `float`         | `double`    | Promoted to double in R |
| `double`        | `double`    |                         |
| `string`        | `character` |                         |
| `date32[day]`   | `Date`      |                         |
| `timestamp[ms]` | `POSIXct`   | Safest timestamp format |

## See also

[`as_r_schema()`](https://hubverse-org.github.io/hubData/dev/reference/as_r_schema.md),
[`arrow_schema_to_string()`](https://hubverse-org.github.io/hubData/dev/reference/as_r_schema.md)
