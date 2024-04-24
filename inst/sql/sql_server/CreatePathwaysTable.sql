IF OBJECT_ID('@cohortDatabaseSchema.@cohortTable_pathway_events', 'U') IS NOT NULL
	DROP TABLE @cohortDatabaseSchema.@cohortTable_pathway_events;

CREATE TABLE @cohortDatabaseSchema.@cohortTable_pathway_events (
	pathway_analysis_generation_id INT,
	target_cohort_id BIGINT,
	subject_id BIGINT,
	ordinal INT,
	combo_id INT, 
	cohort_start_date DATE,
	cohort_end_date DATE
	);

IF OBJECT_ID('@cohortDatabaseSchema.@cohortTable_pathway_stats', 'U') IS NOT NULL
	DROP TABLE @cohortDatabaseSchema.@cohortTable_pathway_stats;

CREATE TABLE @cohortDatabaseSchema.@cohortTable_pathway_stats (
	pathway_analysis_generation_id INT,
	target_cohort_id BIGINT,
	target_cohort_count BIGINT,
	pathways_count BIGINT
	);

IF OBJECT_ID('@cohortDatabaseSchema.@cohortTable_pathway_paths', 'U') IS NOT NULL
	DROP TABLE @cohortDatabaseSchema.@cohortTable_pathway_paths;

CREATE TABLE @cohortDatabaseSchema.@cohortTable_pathway_paths (
	pathway_analysis_generation_id INT,
	target_cohort_id BIGINT,
	step_1 INT,
	step_2 INT,
	step_3 INT,
	step_4 INT,
	step_5 INT,
	count_value BIGINT
	);
