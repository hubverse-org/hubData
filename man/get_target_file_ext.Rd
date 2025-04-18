% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils-target_data.R
\name{get_target_file_ext}
\alias{get_target_file_ext}
\title{Get target data file unique file extensions.}
\usage{
get_target_file_ext(hub_path = NULL, target_path)
}
\arguments{
\item{hub_path}{If not \code{NULL}, must be a \code{SubTreeFileSystem} class object of
the root to a cloud hosted hub. Required to trigger the \code{SubTreeFileSystem}
method.}

\item{target_path}{character string. The path to the target data
file or directory. Usually the output of \code{\link[=get_target_path]{get_target_path()}}.}
}
\description{
Get the unique file extension(s) of the target data file(s) in \code{target_path}.
If \code{target_path} is a directory, the function will return the unique file
extensions of all files in the directory. If \code{target_path} is a file,
the function will return the file extension of that file.
}
\examples{
hub_path <- withr::local_tempdir()
example_hub <- "https://github.com/hubverse-org/example-complex-forecast-hub.git"
gert::git_clone(url = example_hub, path = hub_path)
target_path <- get_target_path(hub_path, "time-series")
get_target_file_ext(hub_path, target_path)
}
