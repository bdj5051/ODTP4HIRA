-- rhPTH
DELETE FROM @target_database_schema.@target_cohort_table where cohort_definition_id = @target_cohort_id;
INSERT INTO @target_database_schema.@target_cohort_table (cohort_definition_id, subject_id, drug_concept_id, cohort_start_date, cohort_end_date, days_supply, duration)
select @target_cohort_id as cohort_definition_id, d.person_id, d.drug_concept_id, d.drug_exposure_start_date, d.drug_exposure_end_date, d.days_supply, d.duration
from (
  SELECT de.person_id, de.drug_concept_id, de.drug_exposure_start_date, de.drug_exposure_end_date, de.days_supply, 7 AS duration
  FROM @cdm_database_schema.DRUG_EXPOSURE de
  WHERE de.drug_concept_id IN (42921785, 42970752, 21602783)
    AND de.days_supply >= 1
  ) d;
