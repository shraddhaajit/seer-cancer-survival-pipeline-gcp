-- Staging Cleaned and Standardized Layer
-- Dataset: staging
-- Table: staging.seer_breast_cancer
-- Description: Standardizes column names, applies type casting, fixes spelling typos, and creates a simulated patient clinical identifier.

CREATE OR REPLACE TABLE `cancer-survival-analytics.staging.seer_breast_cancer` AS
SELECT
  -- Generate a simulated clinical patient identifier to act as sensitive PII
  CONCAT('PAT-', LPAD(CAST(ROW_NUMBER() OVER(ORDER BY Age, `Tumor Size`, `Survival Months`, `Reginol Node Positive`) AS STRING), 6, '0')) AS patient_id,
  
  -- Numeric fields casting and null handling
  COALESCE(CAST(Age AS INT64), 0) AS age,
  COALESCE(CAST(`Tumor Size` AS INT64), 0) AS tumor_size_mm,
  COALESCE(CAST(`Regional Node Examined` AS INT64), 0) AS regional_nodes_examined,
  COALESCE(CAST(`Reginol Node Positive` AS INT64), 0) AS regional_nodes_positive, -- Fixed typo
  COALESCE(CAST(`Survival Months` AS INT64), 0) AS survival_months,
  
  -- Standardize strings, trim spaces, handle nulls
  TRIM(COALESCE(Race, 'Unknown')) AS race,
  TRIM(COALESCE(`Marital Status`, 'Unknown')) AS marital_status,
  
  -- Clean staging attributes (note trailing space in 'T Stage ' in raw data)
  TRIM(COALESCE(`T Stage `, 'Unknown')) AS t_stage,
  TRIM(COALESCE(`N Stage`, 'Unknown')) AS n_stage,
  TRIM(COALESCE(`6th Stage`, 'Unknown')) AS ajcc_6th_stage,
  TRIM(COALESCE(`A Stage`, 'Unknown')) AS a_stage,
  
  -- Clean grading and differentiate attributes
  TRIM(COALESCE(differentiate, 'Unknown')) AS differentiate,
  CASE 
    WHEN TRIM(Grade) LIKE '%anaplastic%' OR TRIM(Grade) = 'anaplastic; Grade IV' THEN '4'
    ELSE TRIM(Grade)
  END AS grade,
  
  -- Biomarkers and final outcome status
  TRIM(COALESCE(`Estrogen Status`, 'Unknown')) AS estrogen_status,
  TRIM(COALESCE(`Progesterone Status`, 'Unknown')) AS progesterone_status,
  TRIM(COALESCE(Status, 'Unknown')) AS status
FROM
  `cancer-survival-analytics.raw.seer_breast_cancer`;
