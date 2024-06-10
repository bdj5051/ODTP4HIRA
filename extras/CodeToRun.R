library(ODTP4HIRA)
 
# Optional: specify where the temporary files (used by the Andromeda package) will be created:
options(andromedaTempFolder = "s:/andromeda")
 
# Maximum number of cores to be used:
maxCores <- parallel::detectCores()
 
# The folder where the study intermediate and result files will be written:
 outputFolder <- "s:/ODTP4HIRA"

# Details for connecting to the server:
 connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "pdw",
                                                                 server = Sys.getenv("PDW_SERVER"),
                                                                 user = NULL,
                                                                 password = NULL,
                                                                 port = Sys.getenv("PDW_PORT"))
 
# The name of the database schema where the CDM data can be found:
cdmDatabaseSchema <- "CDM_IBM_MDCD_V1153.dbo"
 
# The name of the database schema and table where the study-specific cohorts will be instantiated:
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "mschuemi_skeleton"

# # Some meta-information that will be used by the export function:
databaseId <- "HIRA"
# 
# # For Oracle: define a schema that can be used to emulate temp tables:
oracleTempSchema <- NULL

execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        oracleTempSchema = oracleTempSchema,
        outputFolder = outputFolder,
        databaseId = databaseId,
        databaseName = databaseId,
        databaseDescription = databaseId,
        createCohorts = FALSE,
        synthesizePositiveControls = FALSE,
        runAnalyses = TRUE,
        packageResults = TRUE,
        maxCores = maxCores)
# Extract PS equiposed area -----------------------------------------------
library(dplyr)
omr <- readRDS(file.path(outputFolder, "cmOutput", "outcomeModelReference.rds"))
tcos <- read.csv(system.file("settings", "TcosOfInterest.csv", package = "ODTP4HIRA"))
analysisIdList <- unique(omr$analysisId)
outcomeIds <- c(443,984,985,986,987)
computePreferenceScore <- function (data, unfilteredData = NULL) {
  
  if (is.null(unfilteredData)) {
    proportion <- sum(data$treatment)/nrow(data)
  }
  else {
    proportion <- sum(unfilteredData$treatment)/nrow(unfilteredData)
  }
  propensityScore <- data$propensityScore
  propensityScore[propensityScore > 0.9999999] <- 0.9999999
  x <- exp(log(propensityScore/(1 - propensityScore)) - log(proportion/(1 - proportion)))
  data$preferenceScore <- x/(x + 1)
  return(data)
}

psResult <- data.frame()

for (i in 1:nrow(tcos)) {
  target <- tcos$targetId[i]
  comparator <- tcos$comparatorId[i]
  for (j in analysisIdList) {
    for (outcome in outcomeIds){
      psFile <- omr %>% filter(targetId == target & comparatorId == comparator & outcomeId == outcome & analysisId == j)
      ps <- readRDS(file.path(outputFolder, "cmOutput", psFile$psFile))
      ps <- computePreferenceScore(ps)
      auc <- CohortMethod::computePsAuc(ps)
      equipoise <- mean(ps$preferenceScore >= 0.3 & ps$preferenceScore <= 0.7)
      
      temp <- data.frame(targetId = target,
                         comparatorId = comparator,
                         outcomeId = outcome,
                         analysisId = j,
                         auc = auc,
                         equipoise = equipoise)
      
      psResult <- rbind(psResult, temp)
    }
  }
}

write.csv(psResult, file.path(outputFolder, "export", "psResult.csv"), row.names = F)

# Extract subResults ------------------------------------------------------

getOutcomesOfInterest <- function() {
  pathToCsv <- system.file("settings", "TcosOfInterest.csv", package = "ODTP4HIRA")
  tcosOfInterest <- read.csv(pathToCsv, stringsAsFactors = FALSE) 
  outcomeIds <- as.character(tcosOfInterest$outcomeIds)
  outcomeIds <- do.call("c", (strsplit(outcomeIds, split = ";")))
  outcomeIds <- unique(as.numeric(outcomeIds))
  return(outcomeIds)
}

computeMeansPerGroup <- function (cohorts, cohortMethodData) 
{
  hasStrata <- "stratumId" %in% colnames(cohorts)
  if (hasStrata) {
    stratumSize <- cohorts %>% group_by(.data$stratumId, 
                                        .data$treatment) %>% count() %>% ungroup()
  }
  if (hasStrata && any(stratumSize %>% pull(.data$n) > 1)) {
    w <- stratumSize %>% mutate(weight = 1/.data$n) %>% 
      inner_join(cohorts, by = c("stratumId", "treatment")) %>% 
      select(.data$rowId, .data$treatment, .data$weight)
    wSum <- w %>% group_by(.data$treatment) %>% summarize(wSum = sum(.data$weight, 
                                                                     na.rm = TRUE)) %>% ungroup()
    cohortMethodData$w <- w %>% inner_join(wSum, by = "treatment") %>% 
      mutate(weight = .data$weight/.data$wSum) %>% select(.data$rowId, 
                                                          .data$treatment, .data$weight)
    sumW <- 1
    result <- cohortMethodData$covariates %>% inner_join(cohortMethodData$w, by = c("rowId")) %>% 
      group_by(.data$covariateId, .data$treatment) %>% summarise(sum = sum(.data$covariateValue, na.rm = TRUE), 
                                                                 mean = sum(.data$weight * .data$covariateValue, na.rm = TRUE), 
                                                                 sumSqr = sum(.data$weight * .data$covariateValue^2,na.rm = TRUE), 
                                                                 sumWSqr = sum(.data$weight^2, na.rm = TRUE)) %>% 
      mutate(sd = sqrt(abs(.data$sumSqr - .data$mean^2) * sumW/(sumW^2 - .data$sumWSqr))) %>% 
      ungroup() %>% 
      select(.data$covariateId, .data$treatment, .data$sum, .data$mean, .data$sd) %>% 
      collect()
    cohortMethodData$w <- NULL
  }
  else {
    cohortCounts <- cohorts %>% group_by(.data$treatment) %>% count()
    result <- cohortMethodData$covariates %>% 
      inner_join(select(cohorts, .data$rowId, .data$treatment), by = "rowId") %>% 
      group_by(.data$covariateId, .data$treatment) %>% 
      summarise(sum = sum(.data$covariateValue, na.rm = TRUE), 
                sumSqr = sum(.data$covariateValue^2, na.rm = TRUE)) %>% 
      inner_join(cohortCounts, by = "treatment") %>% 
      mutate(sd = sqrt((.data$sumSqr - (.data$sum^2/.data$n))/.data$n), mean = .data$sum/.data$n) %>% 
      ungroup() %>% 
      select(.data$covariateId, .data$treatment, .data$sum, .data$mean, .data$sd) %>% 
      collect()
  }
  target <- result %>% filter(.data$treatment == 1) %>% 
    select(.data$covariateId, 
           sumTarget = .data$sum,
           meanTarget = .data$mean, 
           sdTarget = .data$sd)
  
  comparator <- result %>% filter(.data$treatment == 0) %>% 
    select(.data$covariateId, 
           sumComparator = .data$sum, 
           meanComparator = .data$mean, 
           sdComparator = .data$sd)
  
  result <- target %>% 
    full_join(comparator, by = "covariateId") %>% 
    mutate(sd = sqrt((.data$sdTarget^2 + .data$sdComparator^2)/2)) %>% 
    select(!c(.data$sdTarget, .data$sdComparator))
  return(result)
}

computeCovariateBalanceRe <- function (population, studyPopulation, cohortMethodData, subgroupCovariateId = NULL) {
  
  cohortMethodData$tempCohortsBeforeMatching <- studyPopulation %>%
    select(.data$rowId, .data$treatment)
  cohortMethodData$tempCohortsAfterMatching <- population %>%
    select(.data$rowId, .data$treatment, .data$stratumId)
  
  on.exit(cohortMethodData$tempCohortsBeforeMatching <- NULL)
  on.exit(cohortMethodData$tempCohortsAfterMatching <- NULL,
          add = TRUE)
  
  beforeMatching <- computeMeansPerGroup(cohortMethodData$tempCohortsBeforeMatching,
                                         cohortMethodData)
  afterMatching <- computeMeansPerGroup(cohortMethodData$tempCohortsAfterMatching,
                                        cohortMethodData)
  
  colnames(beforeMatching)[colnames(beforeMatching) == "meanTarget"] <- "beforeMatchingMeanTarget"
  colnames(beforeMatching)[colnames(beforeMatching) == "meanComparator"] <- "beforeMatchingMeanComparator"
  colnames(beforeMatching)[colnames(beforeMatching) == "sumTarget"] <- "beforeMatchingSumTarget"
  colnames(beforeMatching)[colnames(beforeMatching) == "sumComparator"] <- "beforeMatchingSumComparator"
  colnames(beforeMatching)[colnames(beforeMatching) == "sd"] <- "beforeMatchingSd"
  colnames(afterMatching)[colnames(afterMatching) == "meanTarget"] <- "afterMatchingMeanTarget"
  colnames(afterMatching)[colnames(afterMatching) == "meanComparator"] <- "afterMatchingMeanComparator"
  colnames(afterMatching)[colnames(afterMatching) == "sumTarget"] <- "afterMatchingSumTarget"
  colnames(afterMatching)[colnames(afterMatching) == "sumComparator"] <- "afterMatchingSumComparator"
  colnames(afterMatching)[colnames(afterMatching) == "sd"] <- "afterMatchingSd"
  
  balance <- beforeMatching %>% full_join(afterMatching, by = "covariateId") %>%
    inner_join(collect(cohortMethodData$covariateRef), by = "covariateId") %>%
    mutate(beforeMatchingStdDiff = (.data$beforeMatchingMeanTarget - .data$beforeMatchingMeanComparator) / .data$beforeMatchingSd,
           afterMatchingStdDiff = (.data$afterMatchingMeanTarget - .data$afterMatchingMeanComparator) / .data$afterMatchingSd
    )
  
  balance$beforeMatchingStdDiff[balance$beforeMatchingSd == 0] <- 0
  balance$afterMatchingStdDiff[balance$beforeMatchingSd == 0] <- 0
  balance <- balance[order(-abs(balance$beforeMatchingStdDiff)),]
  
  return(balance)
}

computeCovariateBalanceRevise <- function(row, cmOutputFolder, balanceFolder) {
  outputFileName <- file.path(balanceFolder,
                              sprintf("bal_t%s_c%s_o%s_a%s.rds", row$targetId, row$comparatorId, row$outcomeId, row$analysisId))
  if (!file.exists(outputFileName)) {
    ParallelLogger::logTrace("Creating covariate balance file ", outputFileName)
    cohortMethodDataFile <- file.path(cmOutputFolder, row$cohortMethodDataFile)
    cohortMethodData <- CohortMethod::loadCohortMethodData(cohortMethodDataFile)
    strataFile <- file.path(cmOutputFolder, row$strataFile)
    strata <- readRDS(strataFile)
    studyPopFile <- file.path(cmOutputFolder, row$studyPopFile)
    studyPopulation <- readRDS(studyPopFile)
    balance <- computeCovariateBalanceRe(population = strata, studyPopulation = studyPopulation, cohortMethodData = cohortMethodData)
    saveRDS(balance, outputFileName)
  }
}

enforceMinCellValue <- function(data, fieldName, minValues, silent = FALSE) {
  toCensor <- !is.na(pull(data, fieldName)) & pull(data, fieldName) < minValues & pull(data, fieldName) != 0
  if (!silent) {
    percent <- round(100 * sum(toCensor)/nrow(data), 1)
    ParallelLogger::logInfo("   censoring ",
                            sum(toCensor),
                            " values (",
                            percent,
                            "%) from ",
                            fieldName,
                            " because value below minimum")
  }
  if (length(minValues) == 1) {
    data[toCensor, fieldName] <- -minValues
  } else {
    data[toCensor, fieldName] <- -minValues[toCensor]
  }
  return(data)
}

################################

minCellCount <- 5
maxCores <- parallel::detectCores()
exportFolder <- file.path(outputFolder, "export")
balanceFolder <- file.path(outputFolder, "balanceRevise")

if(!file.exists(balanceFolder)) {
  dir.create(balanceFolder)
}

cmOutputFolder <- file.path(outputFolder, "cmOutput")
results <- readRDS(file.path(cmOutputFolder, "outcomeModelReference.rds"))

outcomesOfInterest <- getOutcomesOfInterest()


subset <- results[results$outcomeId %in% outcomesOfInterest,]
subset <- subset[subset$strataFile != "", ]

subset <- split(subset, seq(nrow(subset)))
lapply(subset, computeCovariateBalanceRevise, cmOutputFolder = cmOutputFolder, balanceFolder = balanceFolder)

ParallelLogger::logInfo("Exporting diagnostics")
ParallelLogger::logInfo("- covariate_balance table")
fileName <- file.path(exportFolder, "covariate_balance_revise.csv")
if (file.exists(fileName)) {
  unlink(fileName)
}
first <- TRUE
balanceFolder <- file.path(outputFolder, "balanceRevise")
files <- list.files(balanceFolder, pattern = "bal_.*.rds", full.names = TRUE)
pb <- txtProgressBar(style = 3)

for (i in 1:length(files)) {
  ids <- gsub("^.*bal_t", "", files[i])
  targetId <- as.numeric(gsub("_c.*", "", ids))
  ids <- gsub("^.*_c", "", ids)
  comparatorId <- as.numeric(gsub("_[aso].*$", "", ids))
  if (grepl("_s", ids)) {
    subgroupId <- as.numeric(gsub("^.*_s", "", gsub("_a[0-9]*.rds", "", ids)))
  } else {
    subgroupId <- NA
  }
  if (grepl("_o", ids)) {
    outcomeId <- as.numeric(gsub("^.*_o", "", gsub("_a[0-9]*.rds", "", ids)))
  } else {
    outcomeId <- NA
  }
  ids <- gsub("^.*_a", "", ids)
  analysisId <- as.numeric(gsub(".rds", "", ids))
  balance <- readRDS(files[i])
  inferredTargetBeforeSize <- mean(balance$beforeMatchingSumTarget/balance$beforeMatchingMeanTarget,
                                   na.rm = TRUE)
  inferredComparatorBeforeSize <- mean(balance$beforeMatchingSumComparator/balance$beforeMatchingMeanComparator,
                                       na.rm = TRUE)
  inferredTargetAfterSize <- mean(balance$afterMatchingSumTarget/balance$afterMatchingMeanTarget,
                                  na.rm = TRUE)
  inferredComparatorAfterSize <- mean(balance$afterMatchingSumComparator/balance$afterMatchingMeanComparator,
                                      na.rm = TRUE)
  
  balance$databaseId <- databaseId
  balance$targetId <- targetId
  balance$comparatorId <- comparatorId
  balance$outcomeId <- outcomeId
  balance$analysisId <- analysisId
  balance$interactionCovariateId <- subgroupId
  balance <- balance[, c("databaseId",
                         "targetId",
                         "comparatorId",
                         "outcomeId",
                         "analysisId",
                         "interactionCovariateId",
                         "covariateId",
                         "beforeMatchingSumTarget",
                         "beforeMatchingMeanTarget",
                         "beforeMatchingSumComparator",
                         "beforeMatchingMeanComparator",
                         "beforeMatchingStdDiff",
                         "afterMatchingSumTarget",
                         "afterMatchingMeanTarget",
                         "afterMatchingSumComparator",
                         "afterMatchingMeanComparator",
                         "afterMatchingStdDiff")]
  colnames(balance) <- c("databaseId",
                         "targetId",
                         "comparatorId",
                         "outcomeId",
                         "analysisId",
                         "interactionCovariateId",
                         "covariateId",
                         "targetSumBefore",
                         "targetMeanBefore",
                         "comparatorSumBefore",
                         "comparatorMeanBefore",
                         "stdDiffBefore",
                         "targetSumAfter",
                         "targetMeanAfter",
                         "comparatorSumAfter",
                         "comparatorMeanAfter",
                         "stdDiffAfter")
  
  balance$targetMeanBefore[is.na(balance$targetMeanBefore)] <- 0
  balance$comparatorMeanBefore[is.na(balance$comparatorMeanBefore)] <- 0
  balance$stdDiffBefore <- round(balance$stdDiffBefore, 3)
  balance$targetMeanAfter[is.na(balance$targetMeanAfter)] <- 0
  balance$comparatorMeanAfter[is.na(balance$comparatorMeanAfter)] <- 0
  balance$stdDiffAfter <- round(balance$stdDiffAfter, 3)
  
  balance <- enforceMinCellValue(balance,
                                 "targetMeanBefore",
                                 minCellCount/inferredTargetBeforeSize,
                                 TRUE)
  balance <- enforceMinCellValue(balance,
                                 "comparatorMeanBefore",
                                 minCellCount/inferredComparatorBeforeSize,
                                 TRUE)
  balance <- enforceMinCellValue(balance,
                                 "targetMeanAfter",
                                 minCellCount/inferredTargetAfterSize,
                                 TRUE)
  balance <- enforceMinCellValue(balance,
                                 "comparatorMeanAfter",
                                 minCellCount/inferredComparatorAfterSize,
                                 TRUE)
  balance$targetMeanBefore <- round(balance$targetMeanBefore, 3)
  balance$comparatorMeanBefore <- round(balance$comparatorMeanBefore, 3)
  balance$targetMeanAfter <- round(balance$targetMeanAfter, 3)
  balance$comparatorMeanAfter <- round(balance$comparatorMeanAfter, 3)
  balance <- balance[balance$targetMeanBefore != 0 & balance$comparatorMeanBefore != 0 & balance$targetMeanAfter !=
                       0 & balance$comparatorMeanAfter != 0 & balance$stdDiffBefore != 0 & balance$stdDiffAfter !=
                       0, ]
  balance <- balance[!is.na(balance$targetId), ]
  colnames(balance) <- SqlRender::camelCaseToSnakeCase(colnames(balance))
  write.table(x = balance,
              file = fileName,
              row.names = FALSE,
              col.names = first,
              sep = ",",
              dec = ".",
              qmethod = "double",
              append = !first)
  first <- FALSE
  setTxtProgressBar(pb, i/length(files))
}
close(pb)

resultsZipFile <- file.path(outputFolder, "export", paste0("Results_", databaseId, ".zip"))