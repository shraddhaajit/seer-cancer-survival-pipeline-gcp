# Storage & Data Modeling Notes

This document describes the dimensional star-schema modeling decisions made for the warehouse layer of the Breast Cancer Survival Analytics Platform.

---

## 1. Schema Architecture: Star Schema vs. Wide Table

An enterprise **Star Schema** model was implemented in the `warehouse` dataset. This structure consists of a central fact table containing numerical patient metrics joined to four descriptive dimension tables using surrogate keys.

### Entity Relationship Diagram (ERD) Reference:
```
  [dim_race]
      └── race_key (PK) ◄────────┐
                                  │
  [dim_marital_status]            │
      └── marital_status_key ◄───┼────────── [fact_patient_case]
                                  │             ├── patient_id (simulated PII)
  [dim_stage]                     │             ├── race_key (FK)
      └── stage_key ◄─────────────┼────────────┤ marital_status_key (FK)
                                  │             ├── stage_key (FK)
  [dim_tumor_grade]               │             ├── grade_key (FK)
      └── grade_key ◄─────────────┘             ├── age
                                                ├── tumor_size_mm
                                                ├── regional_nodes_examined
                                                ├── regional_nodes_positive
                                                ├── survival_months
                                                └── status
```

### Rationale for Star Schema in Clinical Data Warehousing:
1. **Normalization of Dimensions**: Categorical fields such as race, marital status, grade, and TNM stage combinations are shared across many patients. Fact-dimension separation reduces duplicate string storage.
2. **Surrogate Key Generation**: BigQuery does not natively support auto-incrementing integer keys. To maintain standard relational mapping, we generated surrogate keys using BigQuery's native `FARM_FINGERPRINT()` hashing function.
   * **Why FARM_FINGERPRINT**: It generates a deterministic `INT64` hash from string concatenation. This allows for extremely fast `JOIN` processing using integer comparisons rather than slow string evaluations, and keeps the dimension keys perfectly consistent across incremental runs.

---

## 2. Table Optimization: Clustering

The fact table `warehouse.fact_patient_case` is configured with a clustering key:
`CLUSTER BY stage_key, race_key`

### What is Clustering in BigQuery?
Clustering organizes table data based on the values in specified columns. BigQuery automatically sorts and stores the data in blocks corresponding to these column values.

### Justification for Clustering Keys:
- **`stage_key`**: Clinical dashboards and analytical queries almost always filter patients by their diagnostic stage (e.g. comparing survival rates across AJCC 6th stage or N/T categories). Clustering by `stage_key` ensures that queries filtering by stage only scan blocks containing patients of those specific stages.
- **`race_key`**: This is a secondary demographic filter commonly queried for health equity and epidemiology research.

### Cost & Quota Performance Benefits:
In BigQuery Sandbox, users are capped at **1 TB of free query processing per month**. 
1. **Scanned Bytes Reduction**: When an analyst queries survival trends for stage III patients, BigQuery uses the clustered blocks to skip reading data for stages I, II, and IV. This significantly cuts the amount of data scanned, preserving the free-tier quota.
2. **No Cost to Maintain**: Unlike indexing or clustering in standard RDBMS, BigQuery does not charge a performance penalty or require manual maintenance for clustering. BigQuery performs automatic re-sorting in the background.
3. **Partitioning Decision**: Partitioning was considered but not chosen for this dataset. BigQuery partitions tables by ingestion time, an integer range, or a `DATE`/`TIMESTAMP` column. Since this dataset does not have time-series patient data, partitioning is not a fit, making **clustering** the correct performance optimization tool.
