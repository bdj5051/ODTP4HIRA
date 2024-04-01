	-- IV BP
DELETE FROM @target_database_schema.@target_cohort_table where cohort_definition_id = @target_cohort_id;
INSERT INTO @target_database_schema.@target_cohort_table (cohort_definition_id, subject_id, drug_concept_id, cohort_start_date, cohort_end_date, days_supply, duration)
select @target_cohort_id as cohort_definition_id, d.person_id, d.drug_concept_id, d.drug_exposure_start_date, d.drug_exposure_end_date, d.days_supply, d.duration
from (
  select de.*, 90 as 'duration'
  FROM @cdm_database_schema.DRUG_EXPOSURE de
  WHERE drug_concept_id in (40173414,21604154)
	and days_supply >=1
union all
  select de.*, 365 as 'duration'
  FROM @cdm_database_schema.DRUG_EXPOSURE de
  WHERE drug_concept_id in (21604156,21118274,41359781)
and days_supply >= 1
  ) d;
