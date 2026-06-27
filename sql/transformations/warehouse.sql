-- Warehouse Dimensional Star-Schema Model
-- Dataset: warehouse
-- Fact Table: warehouse.fact_patient_case
-- Dimensions: dim_race, dim_marital_status, dim_stage, dim_tumor_grade
-- Description: Sets up the dimension and fact tables, generating numeric surrogate keys via FARM_FINGERPRINT and optimizing with clustering.

-- 1. Dimension Table: dim_race
CREATE OR REPLACE TABLE `cancer-survival-analytics.warehouse.dim_race` AS
SELECT DISTINCT
  FARM_FINGERPRINT(race) AS race_key,
  race
FROM
  `cancer-survival-analytics.staging.seer_breast_cancer`;

-- 2. Dimension Table: dim_marital_status
CREATE OR REPLACE TABLE `cancer-survival-analytics.warehouse.dim_marital_status` AS
SELECT DISTINCT
  FARM_FINGERPRINT(marital_status) AS marital_status_key,
  marital_status
FROM
  `cancer-survival-analytics.staging.seer_breast_cancer`;

-- 3. Dimension Table: dim_stage
CREATE OR REPLACE TABLE `cancer-survival-analytics.warehouse.dim_stage` AS
SELECT DISTINCT
  FARM_FINGERPRINT(CONCAT(t_stage, '_', n_stage, '_', ajcc_6th_stage, '_', a_stage)) AS stage_key,
  t_stage,
  n_stage,
  ajcc_6th_stage,
  a_stage
FROM
  `cancer-survival-analytics.staging.seer_breast_cancer`;

-- 4. Dimension Table: dim_tumor_grade
CREATE OR REPLACE TABLE `cancer-survival-analytics.warehouse.dim_tumor_grade` AS
SELECT DISTINCT
  FARM_FINGERPRINT(CONCAT(grade, '_', differentiate)) AS grade_key,
  grade,
  differentiate
FROM
  `cancer-survival-analytics.staging.seer_breast_cancer`;

-- 5. Fact Table: fact_patient_case (Clustered by stage_key)
CREATE OR REPLACE TABLE `cancer-survival-analytics.warehouse.fact_patient_case`
CLUSTER BY stage_key, race_key
AS
SELECT
  patient_id,  -- Base patient ID (PII substitute)
  FARM_FINGERPRINT(race) AS race_key,
  FARM_FINGERPRINT(marital_status) AS marital_status_key,
  FARM_FINGERPRINT(CONCAT(t_stage, '_', n_stage, '_', ajcc_6th_stage, '_', a_stage)) AS stage_key,
  FARM_FINGERPRINT(CONCAT(grade, '_', differentiate)) AS grade_key,
  age,
  tumor_size_mm,
  estrogen_status,
  progesterone_status,
  regional_nodes_examined,
  regional_nodes_positive,
  survival_months,
  status
FROM
  `cancer-survival-analytics.staging.seer_breast_cancer`;
