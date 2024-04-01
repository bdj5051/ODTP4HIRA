# Copyright 2020 Observational Health Data Sciences and Informatics
#
# This file is part of ODTP4HIRA
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' Create the exposure and outcome cohorts
#'
#' @details
#' This function will create the exposure and outcome cohorts following the definitions included in
#' this package.
#'
#' @param connectionDetails    An object of type \code{connectionDetails} as created using the
#'                             \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                             DatabaseConnector package.
#' @param cdmDatabaseSchema    Schema name where your patient-level data in OMOP CDM format resides.
#'                             Note that for SQL Server, this should include both the database and
#'                             schema name, for example 'cdm_data.dbo'.
#' @param cohortDatabaseSchema Schema name where intermediate data can be stored. You will need to have
#'                             write privileges in this schema. Note that for SQL Server, this should
#'                             include both the database and schema name, for example 'cdm_data.dbo'.
#' @param cohortTable          The name of the table that will be created in the work database schema.
#'                             This table will hold the exposure and outcome cohorts used in this
#'                             study.
#' @param oracleTempSchema     Should be used in Oracle to specify a schema where the user has write
#'                             privileges for storing temporary tables.
#' @param outputFolder         Name of local folder to place results; make sure to use forward slashes
#'                             (/)
#'
#' @export
createCohorts <- function(connectionDetails,
                          cdmDatabaseSchema,
                          cohortDatabaseSchema,
                          cohortTable = "cohort",
                          oracleTempSchema,
                          outputFolder) {
  if (!file.exists(outputFolder))
    dir.create(outputFolder)
  
  conn <- DatabaseConnector::connect(connectionDetails)
  
  .createCohorts(connection = conn,
                 cdmDatabaseSchema = cdmDatabaseSchema,
                 cohortDatabaseSchema = cohortDatabaseSchema,
                 cohortTable = cohortTable,
                 oracleTempSchema = oracleTempSchema,
                 outputFolder = outputFolder)
  
  pathToCsv <- system.file("settings", "NegativeControls.csv", package = "ODTP4HIRA")
  negativeControls <- read.csv(pathToCsv)
  
  ParallelLogger::logInfo("Creating negative control outcome cohorts")
  # Currently assuming all negative controls are outcome controls
  negativeControlOutcomes <- negativeControls
  sql <- SqlRender::loadRenderTranslateSql("NegativeControlOutcomes.sql",
                                           "ODTP4HIRA",
                                           dbms = connectionDetails$dbms,
                                           oracleTempSchema = oracleTempSchema,
                                           cdm_database_schema = cdmDatabaseSchema,
                                           target_database_schema = cohortDatabaseSchema,
                                           target_cohort_table = cohortTable,
                                           outcome_ids = unique(negativeControlOutcomes$outcomeId))
  DatabaseConnector::executeSql(conn, sql)
  
  # Check number of subjects per cohort:
  ParallelLogger::logInfo("Counting cohorts")
  sql <- SqlRender::loadRenderTranslateSql("GetCounts.sql",
                                           "ODTP4HIRA",
                                           dbms = connectionDetails$dbms,
                                           oracleTempSchema = oracleTempSchema,
                                           cdm_database_schema = cdmDatabaseSchema,
                                           work_database_schema = cohortDatabaseSchema,
                                           study_cohort_table = cohortTable)
  counts <- DatabaseConnector::querySql(conn, sql)
  colnames(counts) <- SqlRender::snakeCaseToCamelCase(colnames(counts))
  counts <- addCohortNames(counts)
  write.csv(counts, file.path(outputFolder, "results/TreatmentPathways/CohortCounts.csv"), row.names = FALSE)

  # Osteoporosis Subject
  ParallelLogger::logInfo("")
  sql <- SqlRender::render(sql="select gender_concept_id, count(distinct person_id) as p_cnt from @cdm_database_schema.person group by gender_concept_id;",
                           cdm_database_schema = cdmDatabaseSchema)
  person_whole<- DatabaseConnector::querySql(conn, sql)
  
  sql <- SqlRender::loadRenderTranslateSql("osteoporosis_person.sql",
                                           "ODTP4HIRA",
                                           dbms = connectionDetails$dbms,
                                           oracleTempSchema = oracleTempSchema,
                                           vocabulary_database_schema = cdmDatabaseSchema,
                                           cdm_database_schema = cdmDatabaseSchema)
  data_whole <- DatabaseConnector::querySql(conn, sql)
  
  data_whole<- DatabaseConnector::querySql(conn, sql)
  data_whole <- data_whole %>% mutate(AGE_VALIED=ifelse(AGE>=50,1,0)) %>%
    summarise(OSTEO_PERSON=n_distinct(PERSON_ID),
            OVER_50=sum(AGE_VALIED))
  person_osteoporosis <- data.frame(matrix(nrow=1, ncol=4))
  colnames(person_osteoporosis) <- c("WHOLE", "WOMEN", "OSTEO_WOMEN", "OVER50")
  person_osteoporosis[1,] <- c(sum(person_whole$P_CNT), person_whole[person_whole$GENDER_CONCEPT_ID==8532,]$P_CNT, data_whole$OSTEO_PERSON, data_whole$OVER_50)
  write.csv(person_osteoporosis, file.path(outputFolder, "results/TreatmentPathways/osteoporosis_person.csv"))
  rm(data_whole)
  
  # Prepare DOB, Gender and observation period data
  ParallelLogger::logInfo("Creating DOB, Gender, Observation Table")
  sql <- SqlRender::loadRenderTranslateSql("getDOBGender.sql",
                                           "ODTP4HIRA",
                                           dbms = connectionDetails$dbms,
                                           oracleTempSchema = oracleTempSchema,
                                           cdm_database_schema = cdmDatabaseSchema,
                                           cohort_database_schema = cohortDatabaseSchema,
                                           cohort_table = cohortTable,
                                           yearStartDate = 2018,
                                           yearEndDate = 2022)
 
  sql <- SqlRender::translate(sql, targetDialect = attr(conn, "dbms"))
  data_whole<- DatabaseConnector::querySql(conn, sql)
  saveRDS(data_whole, file.path(outputFolder, "tmpData/DatasetCohort.RDS"))
  
  pathToCsv <- system.file("settings", "CohortsToCreate.csv", package = "ODTP4HIRA")
  cohortsToCreate <- read.csv(pathToCsv)
  cohortsToCreate <- cohortsToCreate[cohortsToCreate$cohortType=="DRUG",]
  # Prepare data for drug cohorts
  ParallelLogger::logInfo("Preparing data for drug cohorts")
  for (i in cohortsToCreate[, "cohortId"]){
    writeLines(paste("Preparing data for drug cohort:", cohortsToCreate[cohortsToCreate$cohortId==i, "name"]))
    sql <- "SELECT * FROM @cohort_database_schema.@cohort_table WHERE cohort_definition_id = @cohortId"
    sql <- SqlRender::render(sql,
                             cohort_database_schema = cohortDatabaseSchema,
                             cohort_table = cohortTable,
                             cohortId = i)
    sql <- SqlRender::translate(sql, targetDialect = attr(conn, "dbms"))
    data_drug <- DatabaseConnector::querySql(conn, sql)
    
    data_drug <- data_drug %>%
      dplyr::inner_join(data_whole %>% dplyr::select(SUBJECT_ID, GENDER, DOB), by = 'SUBJECT_ID') %>%
      dplyr::mutate(start_year = lubridate::year(COHORT_START_DATE),
                    start_yearMth = as.Date(format(COHORT_START_DATE, "%Y-%m-01")),
                    end_year = lubridate::year(COHORT_END_DATE),
                    end_yearMth = as.Date(format(COHORT_END_DATE, "%Y-%m-01")),
                    AGE = lubridate::as.period(lubridate::interval(DOB, as.Date(COHORT_START_DATE)))$year) %>%
      dplyr::arrange(SUBJECT_ID, COHORT_START_DATE)
    
    saveRDS(data_drug, file.path(outputFolder, paste0("tmpData/drugCohort_", i, ".RDS")))
  }
  
  DatabaseConnector::disconnect(conn)
}

addCohortNames <- function(data, IdColumnName = "cohortDefinitionId", nameColumnName = "cohortName") {
  pathToCsv <- system.file("settings", "CohortsToCreate.csv", package = "ODTP4HIRA")
  cohortsToCreate <- read.csv(pathToCsv)
  pathToCsv <- system.file("settings", "NegativeControls.csv", package = "ODTP4HIRA")
  negativeControls <- read.csv(pathToCsv)
  
  idToName <- data.frame(cohortId = c(cohortsToCreate$cohortId,
                                      negativeControls$outcomeId),
                         cohortName = c(as.character(cohortsToCreate$atlasName),
                                        as.character(negativeControls$outcomeName)))
  idToName <- idToName[order(idToName$cohortId), ]
  idToName <- idToName[!duplicated(idToName$cohortId), ]
  names(idToName)[1] <- IdColumnName
  names(idToName)[2] <- nameColumnName
  data <- merge(data, idToName, all.x = TRUE)
  # Change order of columns:
  idCol <- which(colnames(data) == IdColumnName)
  if (idCol < ncol(data) - 1) {
    data <- data[, c(1:idCol, ncol(data) , (idCol+1):(ncol(data)-1))]
  }
  return(data)
}
