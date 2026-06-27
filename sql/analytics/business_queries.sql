-- Analytical Business Queries
-- Operating Dataset: warehouse
-- Query Target: warehouse.v_patient_summary_analyst (De-identified Authorized View)
-- Description: Answering key clinical questions on patient survival trends and indicators without exposing patient IDs.

-- =====================================================================
-- Query 1: Survival Trends and Average Survival Duration by AJCC 6th Stage
-- =====================================================================
SELECT
  s.ajcc_6th_stage,
  COUNT(*) AS total_patients,
  SUM(CASE WHEN f.status = 'Alive' THEN 1 ELSE 0 END) AS alive_patients,
  SUM(CASE WHEN f.status = 'Dead' THEN 1 ELSE 0 END) AS dead_patients,
  ROUND(SUM(CASE WHEN f.status = 'Alive' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS survival_rate_pct,
  ROUND(AVG(f.survival_months), 1) AS avg_survival_months
FROM
  `cancer-survival-analytics.warehouse.v_patient_summary_analyst` f
JOIN
  `cancer-survival-analytics.warehouse.dim_stage` s
ON
  f.stage_key = s.stage_key
GROUP BY
  s.ajcc_6th_stage
ORDER BY
  s.ajcc_6th_stage;

-- =====================================================================
-- Query 2: Patient Survival Rates by Demographic Segments (Age Group & Race)
-- =====================================================================
WITH patient_demographics AS (
  SELECT
    f.age,
    CASE
      WHEN f.age < 40 THEN '<40'
      WHEN f.age BETWEEN 40 AND 49 THEN '40-49'
      WHEN f.age BETWEEN 50 AND 59 THEN '50-59'
      WHEN f.age BETWEEN 60 AND 69 THEN '60-69'
      ELSE '70+'
    END AS age_group,
    r.race,
    f.status,
    f.survival_months
  FROM
    `cancer-survival-analytics.warehouse.v_patient_summary_analyst` f
  JOIN
    `cancer-survival-analytics.warehouse.dim_race` r
  ON
    f.race_key = r.race_key
)
SELECT
  age_group,
  race,
  COUNT(*) AS total_patients,
  ROUND(SUM(CASE WHEN status = 'Alive' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS survival_rate_pct,
  ROUND(AVG(survival_months), 1) AS avg_survival_months
FROM
  patient_demographics
GROUP BY
  age_group,
  race
ORDER BY
  age_group,
  race;

-- =====================================================================
-- Query 3: Correlation between Tumor Size (mm) and Survival Months
-- =====================================================================
SELECT
  status,
  COUNT(*) AS patient_count,
  ROUND(AVG(tumor_size_mm), 2) AS avg_tumor_size_mm,
  ROUND(AVG(survival_months), 2) AS avg_survival_months,
  ROUND(CORR(tumor_size_mm, survival_months), 4) AS pearson_correlation_coefficient
FROM
  `cancer-survival-analytics.warehouse.v_patient_summary_analyst`
GROUP BY
  status;

-- =====================================================================
-- Query 4: Mortality Rate and Average Survival Duration by Tumor Grade
-- =====================================================================
SELECT
  g.grade,
  g.differentiate,
  COUNT(*) AS total_patients,
  SUM(CASE WHEN f.status = 'Dead' THEN 1 ELSE 0 END) AS deceased_patients,
  ROUND(SUM(CASE WHEN f.status = 'Dead' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS mortality_rate_pct,
  ROUND(AVG(f.survival_months), 1) AS avg_survival_months
FROM
  `cancer-survival-analytics.warehouse.v_patient_summary_analyst` f
JOIN
  `cancer-survival-analytics.warehouse.dim_tumor_grade` g
ON
  f.grade_key = g.grade_key
GROUP BY
  g.grade,
  g.differentiate
ORDER BY
  g.grade;
