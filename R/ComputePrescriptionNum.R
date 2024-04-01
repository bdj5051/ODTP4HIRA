#' @export
computePrescriptionNum <- function(databaseName,
                                   outputFolder) {

  monthStartDate <- as.Date("2018-01-01")
  monthEndDate <- as.Date("2022-04-30")

  tmpDir <- file.path(outputFolder, "tmpData")

  resultsDir <- file.path(outputFolder, "results/TreatmentPathways")

  `%>%` <- magrittr::`%>%`
  '%!in%' <- Negate('%in%')

  pathToCsv <- system.file("settings", "CohortsToCreate.csv", package = "ODTP4HIRA")
  cohortsToCreate <- read.csv(pathToCsv)
  
  ParallelLogger::logInfo("Calculating prescription numbers")
  for (i in cohortsToCreate[cohortsToCreate$cohortType=="DRUG", "cohortId"]){
    writeLines(paste("Calculating prescription numbers :", cohortsToCreate[cohortsToCreate$cohortId==i, "name"]))
    targetDrug <- readRDS(file.path(tmpDir, paste0("drugCohort_", i, ".RDS")))
    targetDrug <- targetDrug %>%
      dplyr::mutate(period = as.numeric(difftime(COHORT_END_DATE, COHORT_START_DATE, units = "days"))+1)
    whole_mth <- data.frame()
    yearMth_seq <- seq(monthStartDate, monthEndDate, by = "month")
    for(m in as.list(yearMth_seq)){
      whole_mth_m <- targetDrug %>%
        dplyr::filter(m == start_yearMth) %>%
        dplyr::mutate(calDate = m) %>%
        dplyr::group_by(calDate) %>%
        dplyr::summarise(prescriptions = dplyr::n(),
                         person = dplyr::n_distinct(SUBJECT_ID),
                         periodSum = sum(period), .groups = 'drop')
      whole_mth <- rbind(whole_mth, whole_mth_m)
    }
    prescriptionNum <- whole_mth
    
    for (m in as.list(yearMth_seq)) {
      if (m %!in% whole_mth$calDate) {
        row <- data.frame(m, 0, 0, 0)
        names(row) <- c("calDate", "prescriptions", "person", "periodSum")
        prescriptionNum <- rbind(prescriptionNum, row)
      }

    }
    prescriptionNum <- prescriptionNum %>%
      dplyr::arrange(calDate) %>%
      dplyr::mutate(database = databaseName)

    write.csv(prescriptionNum, file.path(resultsDir, paste0("drugCohort_", i, ".csv")))

  }
}
