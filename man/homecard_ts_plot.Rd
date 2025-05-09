% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/static_plots.R
\name{homecard_ts_plot}
\alias{homecard_ts_plot}
\title{Create a homecard time series plot}
\usage{
homecard_ts_plot(data, x_col = "date_month", y_col, type = "area")
}
\arguments{
\item{data}{A dataframe containing the time series data}

\item{x_col}{The name of the column to be used for the x-axis (default: "date_month")}

\item{y_col}{The name of the column to be used for the y-axis}

\item{type}{The type of plot (default: "area")}
}
\value{
An apexchart object
}
\description{
Create a homecard time series plot
}
