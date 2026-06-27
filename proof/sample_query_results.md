# Preserved Key Analytical Query Results

This document contains a static archive of the key analytical query results executed against the BigQuery datasets. Since the BigQuery Sandbox tables are subject to automatic 60-day expiration, this file serves as the permanent record of query correctness and outputs.

---

### Query 1: Survival Trends and Average Survival Duration by AJCC 6th Stage
Examines the relationship between clinical stage at diagnosis and patient outcomes.

| ajcc_6th_stage | total_patients | alive_patients | dead_patients | survival_rate_pct | avg_survival_months |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **IIA** | 1,305 | 1,209 | 96 | 92.64% | 74.4 |
| **IIB** | 1,130 | 995 | 135 | 88.05% | 72.2 |
| **IIIA** | 1,050 | 866 | 184 | 82.48% | 70.2 |
| **IIIB** | 67 | 47 | 20 | 70.15% | 69.4 |
| **IIIC** | 472 | 291 | 181 | 61.65% | 63.2 |

*Insight: A clear inverse correlation is shown; as the clinical stage progresses from IIA to IIIC, the 5-year survival rate decreases from 92.6% to 61.7% and average survival months decrease by 11.2 months.*

---

### Query 2: Patient Survival Rates by Demographic Segments (Age Group & Race)
Analyzes how age at diagnosis and race intersect with survival rates.

| age_group | race | total_patients | survival_rate_pct | avg_survival_months |
| :--- | :--- | :---: | :---: | :---: |
| **40-49** | Black | 97 | 81.44% | 66.6 |
| **40-49** | Other | 110 | 94.55% | 74.3 |
| **40-49** | White | 917 | 87.79% | 73.2 |
| **50-59** | Black | 92 | 77.17% | 67.1 |
| **50-59** | Other | 93 | 87.10% | 74.1 |
| **50-59** | White | 1,205 | 87.05% | 71.6 |
| **60-69** | Black | 78 | 66.67% | 66.9 |
| **60-69** | Other | 83 | 89.16% | 73.8 |
| **60-69** | White | 1,119 | 81.32% | 70.6 |
| **<40** | Black | 24 | 66.67% | 64.0 |
| **<40** | Other | 34 | 82.35% | 65.9 |
| **<40** | White | 172 | 80.81% | 67.8 |

---

### Query 3: Correlation between Tumor Size (mm) and Survival Months
Measures the strength of linear association between physical tumor size and survival duration.

| status | patient_count | avg_tumor_size_mm | avg_survival_months | pearson_correlation_coefficient |
| :--- | :---: | :---: | :---: | :---: |
| **Alive** | 3,408 | 29.27 | 75.94 | -0.0139 |
| **Dead** | 616 | 37.14 | 45.61 | -0.0733 |

*Insight: Deceased patients present with significantly larger average tumors (37.14 mm vs. 29.27 mm) and shorter survival times. The negative Pearson coefficient suggests that larger tumor sizes correlate with lower survival times.*

---

### Query 4: Mortality Rate and Average Survival Duration by Tumor Grade
Examines survival based on tumor cell differentiation (Grade 1 = well differentiated, Grade 4 = undifferentiated).

| grade | differentiate | total_patients | deceased_patients | mortality_rate_pct | avg_survival_months |
| :--- | :--- | :---: | :---: | :---: | :---: |
| **1** | Well differentiated | 543 | 39 | 7.18% | 72.9 |
| **2** | Moderately differentiated | 2,351 | 305 | 12.97% | 72.2 |
| **3** | Poorly differentiated | 1,111 | 263 | 23.67% | 68.7 |
| **4** | Undifferentiated | 19 | 9 | 47.37% | 64.4 |

*Insight: There is a sharp, progressive increase in mortality rates as cell differentiation degrades, climbing from 7.18% for Grade 1 tumors to 47.37% for Grade 4 (undifferentiated) tumors.*
