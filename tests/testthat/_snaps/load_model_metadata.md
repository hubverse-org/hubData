# load_model_metadata works correctly and retuns one row per model.

    Code
      str(load_model_metadata(hub_path))
    Output
      tibble [2 x 15] (S3: tbl_df/tbl/data.frame)
       $ model_id              : chr [1:2] "hub-baseline" "team1-goodmodel"
       $ team_abbr             : chr [1:2] "hub" "team1"
       $ model_abbr            : chr [1:2] "baseline" "goodmodel"
       $ team_name             : chr [1:2] "Hub Coordination Team" "Team1"
       $ model_name            : chr [1:2] "Baseline" "Good Model"
       $ model_version         : chr [1:2] "1.0" "1.0"
       $ model_contributors    :List of 2
        ..$ :List of 2
        .. ..$ :List of 2
        .. .. ..$ name : chr "Joe Bloggs"
        .. .. ..$ email: chr "j.bloggs@email.com"
        .. ..$ :List of 2
        .. .. ..$ name : chr "J Smith"
        .. .. ..$ email: chr "j.smith@email.com"
        ..$ :List of 2
        .. ..$ :List of 2
        .. .. ..$ name : chr "Joe Bloggs"
        .. .. ..$ email: chr "j.bloggs@email.com"
        .. ..$ :List of 2
        .. .. ..$ name : chr "J Smith"
        .. .. ..$ email: chr "j.smith@email.com"
       $ website_url           : chr [1:2] "https://hubcoordination.website" "https://team1goodmodel.website"
       $ repo_url              : logi [1:2] NA NA
       $ license               : chr [1:2] "cc-by-4.0" "cc-by-4.0"
       $ include_viz           : logi [1:2] TRUE TRUE
       $ include_ensemble      : logi [1:2] FALSE TRUE
       $ include_eval          : logi [1:2] TRUE TRUE
       $ model_details         :List of 2
        ..$ :List of 2
        .. ..$ methods    : chr "this the method description of the model."
        .. ..$ data_inputs: chr "description of the data inputs"
        ..$ :List of 2
        .. ..$ methods    : chr "this the method description of the model."
        .. ..$ data_inputs: chr "description of the data imputs"
       $ ensemble_of_hub_models: logi [1:2] FALSE FALSE

---

    Code
      str(load_model_metadata(hub_path, model_ids = c("hub-baseline")))
    Output
      tibble [1 x 15] (S3: tbl_df/tbl/data.frame)
       $ model_id              : chr "hub-baseline"
       $ team_abbr             : chr "hub"
       $ model_abbr            : chr "baseline"
       $ team_name             : chr "Hub Coordination Team"
       $ model_name            : chr "Baseline"
       $ model_version         : chr "1.0"
       $ model_contributors    :List of 1
        ..$ :List of 2
        .. ..$ :List of 2
        .. .. ..$ name : chr "Joe Bloggs"
        .. .. ..$ email: chr "j.bloggs@email.com"
        .. ..$ :List of 2
        .. .. ..$ name : chr "J Smith"
        .. .. ..$ email: chr "j.smith@email.com"
       $ website_url           : chr "https://hubcoordination.website"
       $ repo_url              : logi NA
       $ license               : chr "cc-by-4.0"
       $ include_viz           : logi TRUE
       $ include_ensemble      : logi FALSE
       $ include_eval          : logi TRUE
       $ model_details         :List of 1
        ..$ :List of 2
        .. ..$ methods    : chr "this the method description of the model."
        .. ..$ data_inputs: chr "description of the data inputs"
       $ ensemble_of_hub_models: logi FALSE

---

    Code
      str(load_model_metadata(hub_path))
    Output
      tibble [4 x 22] (S3: tbl_df/tbl/data.frame)
       $ model_id              : chr [1:4] NA NA "hub-baseline-with-model_id" "wrong-model_id"
       $ team_abbr             : chr [1:4] "hub" "hub" NA NA
       $ model_abbr            : chr [1:4] "baseline" NA NA NA
       $ team_name             : chr [1:4] "Hub Coordination Team" "Hub Coordination Team" "Hub Coordination Team" "Hub Coordination Team"
       $ model_name            : chr [1:4] NA "Baseline" "Baseline" "Baseline"
       $ model_version         : chr [1:4] "1.0" "1.0" "1.0" "1.0"
       $ model_contributors    :List of 4
        ..$ :List of 2
        .. ..$ :List of 2
        .. .. ..$ name : chr "Joe Bloggs"
        .. .. ..$ email: chr "j.bloggs@email.com"
        .. ..$ :List of 2
        .. .. ..$ name : chr "J Smith"
        .. .. ..$ email: chr "j.smith@email.com"
        ..$ :List of 2
        .. ..$ :List of 2
        .. .. ..$ name : chr "Joe Bloggs"
        .. .. ..$ email: chr "j.bloggs@email.com"
        .. ..$ :List of 2
        .. .. ..$ name : chr "J Smith"
        .. .. ..$ email: chr "j.smith@email.com"
        ..$ :List of 2
        .. ..$ :List of 2
        .. .. ..$ name : chr "Joe Bloggs"
        .. .. ..$ email: chr "j.bloggs@email.com"
        .. ..$ :List of 2
        .. .. ..$ name : chr "J Smith"
        .. .. ..$ email: chr "j.smith@email.com"
        ..$ :List of 2
        .. ..$ :List of 2
        .. .. ..$ name : chr "Joe Bloggs"
        .. .. ..$ email: chr "j.bloggs@email.com"
        .. ..$ :List of 2
        .. .. ..$ name : chr "J Smith"
        .. .. ..$ email: chr "j.smith@email.com"
       $ website_url           : chr [1:4] "https://team1goodmodel.website" "https://team1goodmodel.website" "https://team1goodmodel.website" "https://team1goodmodel.website"
       $ repo_url              : logi [1:4] NA NA NA NA
       $ license               : chr [1:4] "cc-by-4.0" "cc-by-4.0" "cc-by-4.0" "cc-by-4.0"
       $ designated_model      : logi [1:4] NA NA NA NA
       $ citation              : logi [1:4] NA NA NA NA
       $ team_funding          : logi [1:4] NA NA NA NA
       $ data_inputs           : logi [1:4] NA NA NA NA
       $ methods               : logi [1:4] NA NA NA NA
       $ methods_long          : logi [1:4] NA NA NA NA
       $ ensemble_of_models    : logi [1:4] NA NA NA NA
       $ ensemble_of_hub_models: logi [1:4] FALSE FALSE FALSE FALSE
       $ include_viz           : logi [1:4] TRUE TRUE TRUE TRUE
       $ include_ensemble      : logi [1:4] FALSE FALSE FALSE FALSE
       $ include_eval          : logi [1:4] TRUE TRUE TRUE TRUE
       $ model_details         :List of 4
        ..$ :List of 2
        .. ..$ methods    : chr "this the method description of the model."
        .. ..$ data_inputs: chr "description of the data inputs"
        ..$ :List of 2
        .. ..$ methods    : chr "this the method description of the model."
        .. ..$ data_inputs: chr "description of the data inputs"
        ..$ :List of 2
        .. ..$ methods    : chr "this the method description of the model."
        .. ..$ data_inputs: chr "description of the data inputs"
        ..$ :List of 2
        .. ..$ methods    : chr "this the method description of the model."
        .. ..$ data_inputs: chr "description of the data inputs"

# resulting tibble has team_abbr, model_abbr, and model_id_columns

    Code
      str(model_metadata)
    Output
      tibble [2 x 15] (S3: tbl_df/tbl/data.frame)
       $ model_id              : chr [1:2] "hub-baseline" "team1-goodmodel"
       $ team_abbr             : chr [1:2] "hub" "team1"
       $ model_abbr            : chr [1:2] "baseline" "goodmodel"
       $ team_name             : chr [1:2] "Hub Coordination Team" "Team1"
       $ model_name            : chr [1:2] "Baseline" "Good Model"
       $ model_version         : chr [1:2] "1.0" "1.0"
       $ model_contributors    :List of 2
        ..$ :List of 2
        .. ..$ :List of 2
        .. .. ..$ name : chr "Joe Bloggs"
        .. .. ..$ email: chr "j.bloggs@email.com"
        .. ..$ :List of 2
        .. .. ..$ name : chr "J Smith"
        .. .. ..$ email: chr "j.smith@email.com"
        ..$ :List of 2
        .. ..$ :List of 2
        .. .. ..$ name : chr "Joe Bloggs"
        .. .. ..$ email: chr "j.bloggs@email.com"
        .. ..$ :List of 2
        .. .. ..$ name : chr "J Smith"
        .. .. ..$ email: chr "j.smith@email.com"
       $ website_url           : chr [1:2] "https://hubcoordination.website" "https://team1goodmodel.website"
       $ repo_url              : logi [1:2] NA NA
       $ license               : chr [1:2] "cc-by-4.0" "cc-by-4.0"
       $ include_viz           : logi [1:2] TRUE TRUE
       $ include_ensemble      : logi [1:2] FALSE TRUE
       $ include_eval          : logi [1:2] TRUE TRUE
       $ model_details         :List of 2
        ..$ :List of 2
        .. ..$ methods    : chr "this the method description of the model."
        .. ..$ data_inputs: chr "description of the data inputs"
        ..$ :List of 2
        .. ..$ methods    : chr "this the method description of the model."
        .. ..$ data_inputs: chr "description of the data imputs"
       $ ensemble_of_hub_models: logi [1:2] FALSE FALSE

