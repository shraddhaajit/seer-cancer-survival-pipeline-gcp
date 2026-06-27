# Breast Cancer Survival Analytics Platform (Google Cloud BigQuery Sandbox Edition)

An end-to-end data engineering, analytics, and machine learning platform built on Google Cloud Platform, aligned with the Associate Data Practitioner (ADP) exam domains. This project demonstrates real-world clinical data pipelines, dimensional modeling, data governance, and predictive analytics using a de-identified public health dataset.

### BigQuery Sandbox Constraints
- Execution Environment: This project runs entirely within the BigQuery Sandbox tier.
- 60-Day Expiration Policy: All tables, views, and datasets are subject to Google's standard 60-day automatic expiration limit from their creation date. This is an expected sandbox lifecycle constraint. The permanent record of the project (schemas, SQL codes, queries, and dashboard screenshots) is preserved in the /proof folder.

---

## ADP Certification Domains Covered
1. Data Preparation & Ingestion: Direct-upload CSV ELT pipeline, staging cleansing, and casting.
2. Storage & Data Modeling: Staging and star-schema (fact/dimensions) dimensional modeling with clustering optimization.
3. Governance & Security: Simulated IAM controls, de-identification of data, and column-level masking via BigQuery Authorized Views.
4. Analytics & Machine Learning: Correlation queries, Looker Studio dashboards, and predictive BigQuery ML (BQML) logistic regression modeling.

---

## Technical Stack
- Data Warehouse: Google BigQuery (Sandbox Tier)
- Transformation Engine: BigQuery Standard SQL (ELT Pattern)
- Data Governance: Authorized Views (Least-Privilege clinical masking)
- Machine Learning: BigQuery ML (BQML) - Logistic Regression
- Visualization: Looker Studio ([Live Dashboard Link](https://datastudio.google.com/reporting/958949e8-a4b9-44a6-b1fc-d76c0d8356d6))

---

## Data Pipeline Summary
1. Ingestion: Raw SEER Breast Cancer CSV uploaded directly into the raw dataset.
2. Cleansing & Staging: SQL transformations map and cast fields, standardize strings, and generate a surrogate clinical patient_id inside the staging dataset.
3. Data Modeling: A normalized star schema created inside the warehouse dataset with dimension tables (dim_race, dim_marital_status, dim_stage, dim_tumor_grade) clustered to optimize query scans.
4. De-Identification View: The authorized view v_patient_summary_analyst masks the sensitive patient_id column while exposing clinical facts for analysts and Looker Studio.
5. Predictive Analytics: A BigQuery ML Logistic Regression model is trained on clinical and demographic indicators to predict patient survival outcomes.

---

## Project Structure
- /data/raw: Raw input dataset (ignored in Git to comply with standard clinical data distribution).
- /sql: Production-grade versioned SQL scripts categorized by stages (transformations, governance, analytics, ml).
- /docs: Technical decisions (ELT, star schema modeling, sandbox substitutions, BQML evaluation).
- /proof: Permanent files showing schemas, query outputs, and dashboard views.

---

## Sandbox Constraints & Lifecycle Policy
Because this project runs in the BigQuery Sandbox tier, all datasets, tables, and views are subject to a 60-day expiration limit from their creation date. To ensure this project remains demonstrable after the sandbox environment expires, a permanent record of schemas, ML metrics, and key query outputs is archived in the /proof folder.

---

## How to Verify (Project Permanence & Pipeline Execution Guide)

Since this project resides within the free BigQuery Sandbox, its datasets and tables are subject to the automatic 60-day expiration policy. To ensure that this work remains permanently demonstrable and easy to audit, all schemas, queries, metrics, and views are archived.

---

### Phase 1: Review Archived Proofs (Static Record)
The project's output and structural validity can be inspected directly within this repository:
1. Database Schemas: Review [schemas.txt](file:///c:/Users/shrad/OneDrive/Desktop/adpproject/proof/schemas.txt) to verify the JSON definitions for raw, staging, and warehouse tables.
2. SQL Query Outputs: Review [sample_query_results.md](file:///c:/Users/shrad/OneDrive/Desktop/adpproject/proof/sample_query_results.md) and [sample_query_results.csv](file:///c:/Users/shrad/OneDrive/Desktop/adpproject/proof/sample_query_results.csv) to inspect the exact outputs returned by the analytical SQL queries.
3. ML Evaluation: Review [ml-notes.md](file:///c:/Users/shrad/OneDrive/Desktop/adpproject/docs/ml-notes.md) to inspect the trained logistic regression model's accuracy, recall, ROC AUC score, and confusion matrix.
4. Dashboard Views: Open the [dashboard folder](file:///c:/Users/shrad/OneDrive/Desktop/adpproject/proof/dashboard/) to inspect the static exports of the Looker Studio dashboard.

---

### Phase 2: Re-Run the Pipeline (Active Verification)
The entire pipeline can be executed from scratch in any Google Cloud project using the standard GCP SDK and the versioned SQL scripts.

#### 1. Setup & Ingestion
```powershell
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

bq mk --location=us --dataset raw
bq load --autodetect --skip_leading_rows=1 --source_format=CSV raw.seer_breast_cancer ./data/raw/seer_breast_cancer_raw.csv
```

#### 2. Staging & Warehousing Transformations
```powershell
bq mk --location=us --dataset staging
Get-Content ./sql/transformations/staging.sql -Raw | bq query --use_legacy_sql=false

bq mk --location=us --dataset warehouse
Get-Content ./sql/transformations/warehouse.sql -Raw | bq query --use_legacy_sql=false
```

#### 3. Governance & Views
```powershell
Get-Content ./sql/governance/authorized_views.sql -Raw | bq query --use_legacy_sql=false
```

#### 4. Analytics & Machine Learning
```powershell
Get-Content ./sql/analytics/business_queries.sql -Raw | bq query --use_legacy_sql=false

Get-Content ./sql/ml/train_model.sql -Raw | bq query --use_legacy_sql=false

Get-Content ./sql/ml/evaluate_model.sql -Raw | bq query --use_legacy_sql=false
```
