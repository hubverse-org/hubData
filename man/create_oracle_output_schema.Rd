% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_oracle_output_schema.R
\name{create_oracle_output_schema}
\alias{create_oracle_output_schema}
\title{Create oracle-output target data file schema}
\usage{
create_oracle_output_schema(
  hub_path,
  na = c("NA", ""),
  ignore_files = NULL,
  r_schema = FALSE,
  output_type_id_datatype = c("from_config", "auto", "character", "double", "integer",
    "logical", "Date")
)
}
\arguments{
\item{hub_path}{Either a character string path to a local Modeling Hub directory
or an object of class \verb{<SubTreeFileSystem>} created using functions \code{\link[=s3_bucket]{s3_bucket()}}
or \code{\link[=gs_bucket]{gs_bucket()}} by providing a string S3 or GCS bucket name or path to a
Modeling Hub directory stored in the cloud.
For more details consult the
\href{https://arrow.apache.org/docs/r/articles/fs.html}{Using cloud storage (S3, GCS)}
in the \code{arrow} package.
The hub must be fully configured with valid \code{admin.json} and \code{tasks.json}
files within the \code{hub-config} directory.}

\item{na}{A character vector of strings to interpret as missing values. Only
applies to CSV files. The default is \code{c("NA", "")}. Useful when actual character
string \code{"NA"} values are used in the data. In such a case, use empty cells to
indicate missing values in your files and set \code{na = ""}.}

\item{ignore_files}{A character vector of file \strong{names} (not paths) or
file \strong{prefixes} to ignore when discovering model output files to
include in dataset connections.
Parent directory names should not be included.
Common non-data files such as \code{"README"} and \code{".DS_Store"} are ignored automatically,
but additional files can be excluded by specifying them here.}

\item{r_schema}{Logical. If \code{FALSE} (default), return an \code{\link[arrow:schema]{arrow::schema()}} object.
If \code{TRUE}, return a character vector of R data types.}

\item{output_type_id_datatype}{character string. One of \code{"from_config"}, \code{"auto"},
\code{"character"}, \code{"double"}, \code{"integer"}, \code{"logical"}, \code{"Date"}.
Defaults to \code{"from_config"} which uses the setting in the \code{output_type_id_datatype}
property in the \code{tasks.json} config file if available. If the property is
not set in the config, the argument falls back to \code{"auto"} which determines
the  \code{output_type_id} data type automatically from the \code{tasks.json}
config file as the simplest data type required to represent all output
type ID values across all output types in the hub.
When only point estimate output types (where \code{output_type_id}s are \code{NA},) are
being collected by a hub, the \code{output_type_id} column is assigned a \code{character}
data type when auto-determined.
Other data type values can be used to override automatic determination.
Note that attempting to coerce \code{output_type_id} to a data type that is
not valid for the data (e.g. trying to coerce\code{"character"} values to
\code{"double"}) will likely result in an error or potentially unexpected
behaviour so use with care.}
}
\value{
an arrow \verb{<schema>} class object
}
\description{
Create oracle-output target data file schema
}
\examples{
#' # Clone example hub
tmp_hub_path <- withr::local_tempdir()
example_hub <- "https://github.com/hubverse-org/example-complex-forecast-hub.git"
gert::git_clone(url = example_hub, path = tmp_hub_path)
# Create target oracle-output schema
create_oracle_output_schema(tmp_hub_path)
#  target oracle-output schema from a cloud hub
s3_hub_path <- s3_bucket("example-complex-forecast-hub")
create_oracle_output_schema(s3_hub_path)
}
