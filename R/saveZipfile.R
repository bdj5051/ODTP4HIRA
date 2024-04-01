#' Create Zip file
#'
#' @description
#' Compress the analysis results files
#' @param databaseName  Some meta-information that will be used by the export function.
#' @param outputFolder  Name of local folder where the results were generated; make sure to use forward slashes
#'                      (/). Do not use a folder on a network drive since this greatly impacts performance.
#' @export

saveZipfile <- function(databaseName,
                        outputFolder) {

  ParallelLogger::logInfo("*** Compress the results files ***")
  resultsDir <- file.path(paste0(outputFolder,"/results"))
  zip::zip(zipfile = paste0(databaseName, "_results.zip"),
           files = "results",
           root = outputFolder)

}


