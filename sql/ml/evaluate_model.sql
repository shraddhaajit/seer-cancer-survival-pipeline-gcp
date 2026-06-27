-- SQL for Evaluating BQML Logistic Regression Model
-- Target Model: warehouse.model_survival_prediction
-- Description: Retrieves standard classification metrics (Accuracy, ROC AUC, Precision, Recall, F1) and generates a confusion matrix.

-- 1. General Evaluation Metrics
SELECT
  *
FROM
  ML.EVALUATE(MODEL `cancer-survival-analytics.warehouse.model_survival_prediction`, (
    SELECT
      f.status,
      f.age,
      f.tumor_size_mm,
      f.regional_nodes_examined,
      f.regional_nodes_positive,
      f.estrogen_status,
      f.progesterone_status,
      r.race,
      m.marital_status,
      s.t_stage,
      s.n_stage,
      s.ajcc_6th_stage,
      s.a_stage,
      g.grade,
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
      `cancer-survival-analytics.warehouse.dim_tumor_grade` g ON f.grade_key = g.grade_key
  ));

-- 2. Confusion Matrix
SELECT
  *
FROM
  ML.CONFUSION_MATRIX(MODEL `cancer-survival-analytics.warehouse.model_survival_prediction`, (
    SELECT
      f.status,
      f.age,
      f.tumor_size_mm,
      f.regional_nodes_examined,
      f.regional_nodes_positive,
      f.estrogen_status,
      f.progesterone_status,
      r.race,
      m.marital_status,
      s.t_stage,
      s.n_stage,
      s.ajcc_6th_stage,
      s.a_stage,
      g.grade,
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
      `cancer-survival-analytics.warehouse.dim_tumor_grade` g ON f.grade_key = g.grade_key
  ));
