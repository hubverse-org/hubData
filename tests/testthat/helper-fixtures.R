# Schema fixtures =====
oracle_output_schema_fixture <- function(
  kind = c("csv", "hive"),
  output_type_id = c("string", "double")
) {
  kind <- rlang::arg_match(kind)
  output_type_id <- rlang::arg_match(output_type_id)
  if (kind == "hive") {
    # hive puts `target` at the end (partition column)
    return(paste0(
      "location: string\n",
      "target_end_date: date32[day]\n",
      "output_type: string\n",
      "output_type_id: ",
      output_type_id,
      "\n",
      "oracle_value: double\n",
      "target: string"
    ))
  } else {
    return(paste0(
      "location: string\n",
      "target_end_date: date32[day]\n",
      "target: string\n",
      "output_type: string\n",
      "output_type_id: ",
      output_type_id,
      "\n",
      "oracle_value: double"
    ))
  }
}
