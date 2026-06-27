-- SQL for Training BQML Logistic Regression Model
-- Model Target Dataset: warehouse
-- Model Name: warehouse.model_survival_prediction
-- Description: Trains a logistic regression model to predict patient status (Alive vs. Dead) using demographic and baseline diagnostic features.

CREATE OR REPLACE MODEL `cancer-survival-analytics.warehouse.model_survival_prediction`
OPTIONS(
  MODEL_TYPE='LOGISTIC_REG',
  INPUT_LABEL_COLS=['status'],
  AUTO_CLASS_WEIGHTS=TRUE  -- Automatically balances the class weights (~85% Alive / 15% Dead)
) AS
SELECT
  f.status,                -- Label (Target Variable)
  f.age,                   -- Numerical features
  f.tumor_size_mm,
  f.regional_nodes_examined,
  f.regional_nodes_positive,
  f.estrogen_status,       -- Categorical biomarker features
  f.progesterone_status,
  r.race,                  -- Demographic dimensions
  m.marital_status,
  s.t_stage,               -- Clinical staging dimensions
  s.n_stage,
  s.ajcc_6th_stage,
  s.a_stage,
  g.grade,                 -- Tumor grading dimensions
  g.differentiate
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
