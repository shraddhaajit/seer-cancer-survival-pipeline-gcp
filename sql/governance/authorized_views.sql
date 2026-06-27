-- SQL for Authorized View
-- Dataset: warehouse
-- View: warehouse.v_patient_summary_analyst
-- Description: Excludes patient_id (simulated PII) to enforce a least-privilege clinical-data access pattern for analysts.

CREATE OR REPLACE VIEW `cancer-survival-analytics.warehouse.v_patient_summary_analyst` AS
SELECT
  -- Column masking: Excluding patient_id (sensitive row identifier)
  -- to allow analysis of clinical profiles without exposing patient keys.
  race_key,
  marital_status_key,
  stage_key,
  grade_key,
  age,
  tumor_size_mm,
  estrogen_status,
  progesterone_status,
  regional_nodes_examined,
  regional_nodes_positive,
  survival_months,
  status
FROM
  `cancer-survival-analytics.warehouse.fact_patient_case`;
