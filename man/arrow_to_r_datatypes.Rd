% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{arrow_to_r_datatypes}
\alias{arrow_to_r_datatypes}
\title{Mapping of Arrow types to base R types}
\format{
A named character vector with 8 entries.
}
\usage{
arrow_to_r_datatypes
}
\description{
A named character vector mapping common \link[arrow:Schema-class]{arrow::Schema} field types (as strings)
to their corresponding base R types. This mapping is used to translate or validate
column types when working with Parquet files or Arrow datasets, especially
for schema inference and compatibility checks.
}
\details{
Only the safest and most portable Arrow types are supported in the hubverse.
Types not present in this mapping should be treated as unsupported.\tabular{lll}{
   Arrow type \tab R type \tab Notes \cr
   \code{bool} \tab \code{logical} \tab  \cr
   \code{int32} \tab \code{integer} \tab  \cr
   \code{int64} \tab \code{integer} \tab R supports via Arrow \cr
   \code{float} \tab \code{double} \tab Promoted to double in R \cr
   \code{double} \tab \code{double} \tab  \cr
   \code{string} \tab \code{character} \tab  \cr
   \code{date32[day]} \tab \code{Date} \tab  \cr
   \code{timestamp[ms]} \tab \code{POSIXct} \tab Safest timestamp format \cr
}
}
\seealso{
\code{\link[=as_r_schema]{as_r_schema()}}, \code{\link[=arrow_schema_to_string]{arrow_schema_to_string()}}
}
\keyword{datasets}
