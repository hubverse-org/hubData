# hubData 0.1.0

* Add `collect_hub()` which wraps `dplyr::collect()` and, where possible, converts the output to a `model_out_tbl` class object by default. The function also accepts additional arguments that can be passed to `as_model_out_tbl()`.
* Allow for parsing `tasks.json` config files where both `required` and `optional` properties of task IDs are set to `null`. This change facilitates the encoding of task IDs in modeling tasks where no value is expected for a given task ID. In model output files, the value in such modeling task task IDs will be `NA`.

# hubData 0.0.1

* Initial package release resulting from split of `hubUtils` package. See [`hubUtils` NEWS.md](https://github.com/Infectious-Disease-Modeling-Hubs/hubUtils/blob/main/NEWS.md) for details including previous release notes.
