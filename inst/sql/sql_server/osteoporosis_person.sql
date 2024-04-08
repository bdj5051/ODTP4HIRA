with osteoporosis as (
	select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (77365,81390,80502,4010333)
), person_osteoporosis as (
	select co.person_id, p.year_of_birth, min(condition_start_date) as condition_start_date 
	from @cdm_database_schema.condition_occurrence co, osteoporosis o, @cdm_database_schema.person p
	where co.condition_concept_id = o.concept_id and p.person_id = co.person_id and p.gender_concept_id = 8532
	group by co.person_id, p.year_of_birth
)
select *, year(condition_start_date)-year_of_birth as age from person_osteoporosis;
