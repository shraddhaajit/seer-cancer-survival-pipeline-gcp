-- SQL for Authorized View
-- Dataset: warehouse
-- View: warehouse.v_patient_summary_analyst
-- Description: Excludes patient_id (simulated PII) to enforce a least-privilege clinical-data access pattern for analysts.

CREATE OR REPLACE VIEW `cancer-survival-analytics.warehouse.v_patient_summary_analyst` AS
SELECT
  -- De-identified human-readable categorical dimensions from star-schema joins
  r.race,
  m.marital_status,
  s.t_stage,
  s.n_stage,
  s.ajcc_6th_stage,
  s.a_stage,
  g.grade,
  g.differentiate,
  
  -- Clinical metrics and biomarkers (omitting patient_id)
  f.age,
  f.tumor_size_mm,
  f.estrogen_status,
  f.progesterone_status,
  f.regional_nodes_examined,
  f.regional_nodes_positive,
  f.survival_months,
  f.status
FROM
  `cancer-survival-analytics.warehouse.fact_patient_case` f
JOIN
  `cancer-survival-analytics.warehouse.dim_race` r ON f.race_key = r.race_key
JOIN
  `cancer-survival-analytics.warehouse.dim_marital_status` m ON f.marital_status_key = m.marital_status_key
JOIN
  `cancer-survival-analytics.warehouse.dim_stage` s ON f.stage_key = s.stage_key
JOIN
  `cancer-survival-analytics.warehouse.dim_tumor_grade` g ON f.grade_key = g.grade_key;
