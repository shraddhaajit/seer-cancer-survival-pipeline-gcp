# Governance, Security & Lifecycle Notes

This document describes the security and data governance design for the Breast Cancer Survival Analytics Platform. It outlines how clinical data access control and data lifecycle management are handled under the constraints of the BigQuery Sandbox.

---

## 1. Least-Privilege Clinical Access Control (IAM Planning)

To protect patient privacy, we design for a least-privilege access control model. We differentiate access between **Clinical Data Engineers** and **Epidemiological Analysts**.

### Target Production IAM Setup
In a production GCP environment, access would be managed at the dataset level using the following role assignments:

| Role Name | Scope (Datasets) | Purpose |
| :--- | :--- | :--- |
| **BigQuery Admin** | All datasets (`raw`, `staging`, `warehouse`, `analytics`) | Full read/write/delete permissions. Assigned strictly to pipeline owners/deployment service accounts. |
| **BigQuery Data Editor** | `raw`, `staging`, `warehouse` | Write access to ingest raw data and run staging and warehousing scheduled queries. |
| **BigQuery Viewer / User** | `analytics` (or `warehouse` view only) | Analyst read-only access to view schemas and query the de-identified authorized views. No access to raw or staging tables. |

---

## 2. Column-Level Security & Sandbox Substitutions

### Why Policy Tags Were Substituted:
In standard BigQuery, column-level security is enforced by applying **policy tags** via **Data Catalog (Dataplex)**.
* **The Limitation**: Establishing a Policy Tag Taxonomy and tagging columns requires:
  1. An active Google Cloud **billing account** linked to the project.
  2. Granular Data Catalog API calls which incur charges.
* **The Decision**: Since the platform must run in the free **BigQuery Sandbox**, true policy-tag masking is unavailable.
* **The Sandbox-Compatible Substitute**: We implemented a **BigQuery Authorized View**: `warehouse.v_patient_summary_analyst`.

### Authorized View Security Flow:
1. The base table `warehouse.fact_patient_case` holds the simulated PII identifier column (`patient_id`).
2. The Authorized View query selects all clinical indicators and keys but **omits `patient_id`**.
3. In production, the analyst would be granted the `BigQuery Data Viewer` role **only** on the view or a separate dataset containing the view. They would have no permissions on `fact_patient_case`.
4. Because the view is *authorized* in the `warehouse` dataset, BigQuery allows the analyst to query the view and read results, even though the analyst does not have permission to read the underlying `fact_patient_case` table.

---

## 3. Data Lifecycle & Expiration Policy

### BigQuery Sandbox 60-Day Constraint:
All tables, views, and partitions created in a BigQuery Sandbox project are subject to an automatic **60-day expiration policy** from their creation date. This is an immutable sandbox constraint.

### Enterprise Comparison (Data Lifecycle Rules):
While this 60-day limit is automatic in the Sandbox, it mirrors standard **lifecycle and retention requirements** in real healthcare applications:
- **HIPAA and GDPR Compliance**: Clinical platforms must implement data retention and destruction schedules. Sensitive clinical staging data is often deleted or moved to cold storage (e.g. Archive Class in Cloud Storage) after a fixed period (e.g. 30 days) once it has been processed into the warehouse.
- **Cost Optimization**: Standard enterprise architectures configure dataset-level table expiration rules or Cloud Storage lifecycle rules (e.g. moving raw bucket files to Coldline/Archive and deleting them after 1 year) to limit storage footprint and costs.
- **Permanence in this Project**: Because the live sandbox tables will expire in 60 days, we preserve schema scripts, SQL logic, query exports, and dashboard views in the `/proof` directory as a permanent record of work.
