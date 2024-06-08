# hubData 0.2.0

* Adds back-compatible support in `create_hub_schema()` for determining a hub's schema from v3.0.0 sample output type configurations in `tasks.json` files (#27).
* Add back-compatible support for v3.0.0 sample output type configuration in `tasks.json` files. The primary change is how `output_type_id` values for sample output types are handled in `expand_model_out_val_grid()`. By default, all valid task ID value combinations are expanded, as per any other output type, but `NA`s are returned in the `output_type_id` column. However, if new argument `include_sample_ids` is set to `TRUE`, example sample IDs are included in the `output_type_id` column, demonstrating how compound tasks IDs group rows of task ID combinations into samples. These are unique across modeling tasks. In `create_model_out_submit_tmpl()`, example sample IDs are included in the `output_type_id` column by default (#30). 

# hubData 0.1.0

* Add `collect_hub()` which wraps `dplyr::collect()` and, where possible, converts the output to a `model_out_tbl` class object by default. The function also accepts additional arguments that can be passed to `as_model_out_tbl()`.
* Allow for parsing `tasks.json` config files where both `required` and `optional` properties of task IDs are set to `null`. This change facilitates the encoding of task IDs in modeling tasks where no value is expected for a given task ID. In model output files, the value in such modeling task task IDs will be `NA`.

# hubData 0.0.1

* Initial package release resulting from split of `hubUtils` package. See [`hubUtils` NEWS.md](https://github.com/Infectious-Disease-Modeling-Hubs/hubUtils/blob/main/NEWS.md) for details including previous release notes.
