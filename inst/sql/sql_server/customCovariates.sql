-- Previous Fracture events covariates construction

SELECT 100000800 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_occurrence.condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id = condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id)
	  AND condition_occurrence.condition_start_date < cohort.cohort_start_date
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -365, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (45757330,45757329,4222001,4203555,4053828,4013596,4013156,4009296,4209549,4210437,4129394,4013604,4008222,4013160,4129420,4013161,35624169,4053654,35624484,4001458,45772068,4204781)
		) I
		LEFT JOIN (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (45770877,4203556)
		) E ON I.concept_id = E.concept_id 
		WHERE E.concept_id is null
		) -- vertebral
	) by_row_id
union all
SELECT 100001800 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id)
	  AND condition_occurrence.condition_start_date < cohort.cohort_start_date
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -365, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (433856,4027460,4281541,4015503,4009610,4015981,4135748)
			) I 
		) -- Hip (Proximal femur)
	) by_row_id
union all
SELECT 100002800 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id) 
	  AND condition_occurrence.condition_start_date < cohort.cohort_start_date
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -365, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (81141,4296627,78276,81696,4276036,77405,76240,4263360,75943,4008356,4013613)
			) I 
		) -- Pelvis
	) by_row_id
union all
SELECT 100003800 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id) 
	  AND condition_occurrence.condition_start_date < cohort.cohort_start_date
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -365, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (4237458,4319889,4302740)
			) I 
		) -- Clavicle+Scapula+Sternum
	) by_row_id
union all
SELECT 100004800 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id)
	  AND condition_occurrence.condition_start_date < cohort.cohort_start_date 
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -365, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (438887,440825,440856,440548,4135749,435094,435093,442560,438583)
			) I 
		) -- other femur
	 ) by_row_id
union all
SELECT 100005800 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id) 
	  AND condition_occurrence.condition_start_date < cohort.cohort_start_date 
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -365, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (435666,4070301,441979,436252,4320628,437693,4012455,4133194,4012456,40492392,436209,40490827,4211657,4185758,4186548)
			) I 
		) -- tibia+fibula		
	) by_row_id
union all
SELECT 100006800 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id) 
	  AND condition_occurrence.condition_start_date < cohort.cohort_start_date
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -365, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (434494,4133610,436250,435940,4175616,434497,440228,4138299,437121)
			) I 
		) -- humerus
	) by_row_id
union all
SELECT 100007800 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id) 
	  AND condition_occurrence.condition_start_date < cohort.cohort_start_date 
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -365, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (436251,4136718,433047,441973,4136715,441423,437400,4134325,433333,437116,4134322,440546,440538,4138301,432747,441974,4278672,440851)
			) I 
		) -- radius+ulnar
	) by_row_id
union all
SELECT 100008800 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id) 
	  AND condition_occurrence.condition_start_date <cohort.cohort_start_date
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -365, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (439162,4105127,432749,441428,4085552,437998,4211657,4185758,4186548)
			) I 
		) -- Ankle
	) by_row_id
union all
SELECT 100009800 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id) 
	  AND condition_occurrence.condition_start_date < cohort.cohort_start_date
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -365, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT
			where concept_id in (4013604,35624169,4013160,4013596,4209549,4203556,4204781,4203555,4222001,4001458,4053654,4129394,4129420,4053828,4009296,4008222,35624484,4013161,4013156,4210437,45770877,45757330,45772068,45757329,437993,433329,4129393,4013612,4008354,437689,4008355,441698,436540,443248,433856,4027460,4281541,4015503,4009610,4015981,4135748,81141,4296627,78276,81696,4276036,77405,76240,4263360,75943,4008356,4013613,4237458,4319889,4302740,434494,4133610,436250,435940,4175616,434497,440228,4138299,437121,438887,440825,440856,440548,4135749,435094,435093,442560,438583,435666,4070301,441979,436252,4320628,437693,4012455,4133194,4012456,40492392,436209,40490827,4211657,4185758,4186548,436251,4136718,433047,441973,4136715,441423,437400,4134325,433333,437116,4134322,440546,440538,4138301,432747,441974,4278672,440851,439162,4105127,432749,441428,4085552,437998,4211657,4185758,4186548,40441585,4069306,40480160,73571)
			) I 
		) -- Osteoporotic fracture
	) by_row_id
union all
SELECT 100010800 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id)  
	  AND condition_occurrence.condition_start_date < cohort.cohort_start_date
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -365, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select ca.descendant_concept_id 
		from @cdm_database_schema.CONCEPT_ANCESTOR ca 
		where ca.ancestor_concept_id in (75053)
		) -- ALL
	) by_row_id
union all
SELECT 100000801 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id) 
	  AND condition_occurrence.condition_start_date < cohort.cohort_start_date
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -30, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (45757330,45757329,4222001,4203555,4053828,4013596,4013156,4009296,4209549,4210437,4129394,4013604,4008222,4013160,4129420,4013161,35624169,4053654,35624484,4001458,45772068,4204781)
			) I
		LEFT JOIN (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (45770877,4203556)
			) E ON I.concept_id = E.concept_id WHERE E.concept_id is null
		) -- vertebral
	) by_row_id
union all
SELECT 100001801 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id) 
	  AND condition_occurrence.condition_start_date < cohort.cohort_start_date
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -30, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (433856,4027460,4281541,4015503,4009610,4015981,4135748)
			) I 
		) -- Hip (Proximal femur)
	) by_row_id
union all
SELECT 100002801 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id) 
	  AND condition_occurrence.condition_start_date < cohort.cohort_start_date
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -30, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (81141,4296627,78276,81696,4276036,77405,76240,4263360,75943,4008356,4013613)
			) I 
		) -- Pelvis
	) by_row_id
union all
SELECT 100003801 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id) 
	  AND condition_occurrence.condition_start_date < cohort.cohort_start_date 
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -30, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (4237458,4319889,4302740)
			) I 
		) -- Clavicle+Scapula+Sternum		
	) by_row_id
union all
SELECT 100004801 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id)
	  AND condition_occurrence.condition_start_date < cohort.cohort_start_date 
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -30, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (438887,440825,440856,440548,4135749,435094,435093,442560,438583)
			) I 
		) -- other femur	 
	) by_row_id
union all
SELECT 100005801 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id)
	  AND condition_occurrence.condition_start_date <cohort.cohort_start_date 
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -30, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (435666,4070301,441979,436252,4320628,437693,4012455,4133194,4012456,40492392,436209,40490827,4211657,4185758,4186548)
			) I 
		) -- tibia+fibula
	) by_row_id
union all
SELECT 100006801 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id) 
	  AND condition_occurrence.condition_start_date < cohort.cohort_start_date 
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -30, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (434494,4133610,436250,435940,4175616,434497,440228,4138299,437121)
			) I 
		) -- humerus
	) by_row_id
union all
SELECT 100007801 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id) 
	  AND condition_occurrence.condition_start_date <cohort.cohort_start_date 
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -30, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (436251,4136718,433047,441973,4136715,441423,437400,4134325,433333,437116,4134322,440546,440538,4138301,432747,441974,4278672,440851)
			) I 
		) -- radius+ulnar
	) by_row_id
union all
SELECT 100008801 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id)
	  AND condition_occurrence.condition_start_date < cohort.cohort_start_date
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -30, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (439162,4105127,432749,441428,4085552,437998,4211657,4185758,4186548)
			) I 
		) -- Ankle	
	) by_row_id
union all
SELECT 100009801 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id) 
	  AND condition_occurrence.condition_start_date < cohort.cohort_start_date 
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -30, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select distinct I.concept_id 
		FROM (
			select concept_id 
			from @vocabulary_database_schema.CONCEPT 
			where concept_id in (4013604,35624169,4013160,4013596,4209549,4203556,4204781,4203555,4222001,4001458,4053654,4129394,4129420,4053828,4009296,4008222,35624484,4013161,4013156,4210437,45770877,45757330,45772068,45757329,437993,433329,4129393,4013612,4008354,437689,4008355,441698,436540,443248,433856,4027460,4281541,4015503,4009610,4015981,4135748,81141,4296627,78276,81696,4276036,77405,76240,4263360,75943,4008356,4013613,4237458,4319889,4302740,434494,4133610,436250,435940,4175616,434497,440228,4138299,437121,438887,440825,440856,440548,4135749,435094,435093,442560,438583,435666,4070301,441979,436252,4320628,437693,4012455,4133194,4012456,40492392,436209,40490827,4211657,4185758,4186548,436251,4136718,433047,441973,4136715,441423,437400,4134325,433333,437116,4134322,440546,440538,4138301,432747,441974,4278672,440851,439162,4105127,432749,441428,4085552,437998,4211657,4185758,4186548,40441585,4069306,40480160,73571)
		) I 
		) -- Osteoporotic fracture		
	) by_row_id
union all
SELECT 100010801 AS covariate_id, row_id, 1 AS covariate_value
FROM (
	SELECT DISTINCT condition_concept_id, cohort.subject_id AS row_id
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.condition_occurrence condition_occurrence
		ON cohort.subject_id =condition_occurrence.person_id
	WHERE cohort.cohort_definition_id IN (@cohort_id)
	  AND condition_occurrence.condition_start_date < cohort.cohort_start_date
	  AND condition_occurrence.condition_start_date >= DATEADD(DAY, -30, cohort.cohort_start_date)
	  AND condition_occurrence.condition_concept_id in (
		select ca.descendant_concept_id 
		from @cdm_database_schema.CONCEPT_ANCESTOR ca 
		where ca.ancestor_concept_id in (75053)
		) -- ALL
	) by_row_id
union all
SELECT 200000802 AS covariate_id, subject_id as row_id, 1 AS covariate_value
from (
	select cohort.*, min(DRUG_EXPOSURE.drug_exposure_start_date) as drug_start_date, max(DRUG_EXPOSURE.drug_exposure_end_date) as drug_end_date 
	FROM @cohort_table cohort
	INNER JOIN @cdm_database_schema.DRUG_EXPOSURE DRUG_EXPOSURE
		ON cohort.subject_id =DRUG_EXPOSURE.person_id
	where cohort.cohort_definition_id IN (@cohort_id) 
	  and DRUG_EXPOSURE.drug_concept_id in (
		select descendant_concept_id 
		from @cdm_database_schema.CONCEPT_ANCESTOR 
		where ancestor_concept_id in (21602737,21602730,21602734,21602732,21602729)
		)
	  AND DRUG_EXPOSURE.drug_exposure_start_date < cohort.cohort_start_date
	  AND DRUG_EXPOSURE.drug_exposure_end_date >= DATEADD(DAY, -365, cohort.cohort_start_date)
	group by cohort.cohort_definition_id, cohort.subject_id, cohort.cohort_start_date, cohort.cohort_end_date
	) drug
where datediff(day, drug_start_date, drug_end_date)>=90

;
