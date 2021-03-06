% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lifecycle-retired.R
\name{scoped_env}
\alias{scoped_env}
\alias{is_scoped}
\alias{scoped_envs}
\alias{scoped_names}
\title{Retired \code{scoped} functions}
\usage{
scoped_env(nm)

is_scoped(nm)

scoped_envs()

scoped_names()
}
\arguments{
\item{nm}{The name of an environment attached to the search
path. Call \code{\link[base:search]{base::search()}} to see what is currently on the path.}
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#deprecated}{\figure{lifecycle-deprecated.svg}{options: alt='[Deprecated]'}}}{\strong{[Deprecated]}}

These functions are deprecated as of rlang 0.3.0. They are replaced
by \code{\link[=is_attached]{is_attached()}}, ...
}
\keyword{internal}
