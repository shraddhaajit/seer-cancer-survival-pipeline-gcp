# Ingestion Design & Architecture Notes

This document captures the design decisions and architectural trade-offs made during the data preparation and ingestion phase of the Breast Cancer Survival Analytics Platform.

---

## 1. ELT vs. ETL Decision Justification

For this platform, an **ELT (Extract, Load, Transform)** pattern was chosen over an **ETL (Extract, Transform, Load)** pattern. 

### Why ELT was Selected:
1. **Source Data Profile**: The SEER Breast Cancer dataset is highly structured, small in size (~4,024 rows, ~400 KB), and clean. Pre-processing the file outside the data warehouse would add unnecessary compute components and engineering overhead.
2. **Compute Optimization**: Modern cloud data warehouses like BigQuery are designed to process transformations on massive datasets using distributed query engines (Dremel). By loading the raw CSV directly, we leverage BigQuery's auto-detect capabilities for schema parsing and execute all formatting, cleansing, and validation inside BigQuery using SQL.
3. **Traceability (Audit Trail)**: Storing the raw, unchanged data in `raw.seer_breast_cancer` ensures we have a permanent historical audit trail. If our transformation logic changes or a bug is discovered, we can replay the transformation from the raw layer without re-ingesting or requesting the source files again.
4. **Tooling Efficiency in Sandbox**: An ETL process would require running a Python container, Dataflow job, or Cloud Function to parse the data before loading. In BigQuery Sandbox, executing transformations via SQL scripts keeps the pipeline entirely serverless, zero-cost, and within the Sandbox quotas.

---

## 2. Production Enterprise Architecture (Scalability Overview)

While this sandbox edition relies on direct local file upload via the `bq` CLI, an enterprise-grade clinical analytics pipeline requires automated, highly secure, and resilient ingestion paths for both batch and streaming data.

Below is the conceptual architecture for scaling this ingestion pipeline to production:

```mermaid
graph TD
    classDef source fill:#f9f,stroke:#333,stroke-width:2px;
    classDef gcp fill:#4285F4,stroke:#333,stroke-width:1px,color:#fff;
    
    subgraph Source Systems
    S1[Clinical EHR Batch Exports]:::source
    S2[Real-time Vital Sign Streams]:::source
    end
    
    subgraph Ingestion Layer
    GCS[(Cloud Storage Buckets)]:::gcp
    PubSub[Cloud Pub/Sub Topics]:::gcp
    end
    
    subgraph Processing Layer
    Dataflow[Cloud Dataflow Engine]:::gcp
    CloudFunction[Cloud Functions / Cloud Run]:::gcp
    end
    
    subgraph Warehouse (BigQuery)
    BQRaw[(raw.seer_breast_cancer)]:::gcp
    end
    
    S1 -->|Scheduled SFTP / gcutil| GCS
    GCS -->|Storage Trigger / Event| CloudFunction
    CloudFunction -->|Trigger batch load job| BQRaw
    
    S2 -->|HTTPS Post / SDK| PubSub
    PubSub -->|Streaming Stream| Dataflow
    Dataflow -->|Continuous Stream Write| BQRaw
```

### Ingestion Paths Detailed:

#### A. Batch Ingestion (EHR Data Exports)
- **Workflow**: EHR (Electronic Health Record) systems generate daily/weekly CSV or HL7/FHIR batch extracts. These are encrypted and uploaded to an **authenticated Google Cloud Storage (GCS)** bucket.
- **Trigger**: GCS Object Finalize events trigger a **Cloud Function** (or a **Cloud Composer / Airflow** DAG for complex workflows).
- **Execution**: The Cloud Function triggers a BigQuery load job (which is a metadata operation and free of query processing costs) to append new batches into the raw table.

#### B. Streaming Ingestion (Real-Time Patient Metrics)
- **Workflow**: Clinical feeds (like telemetry monitors or real-time lab updates) publish JSON payloads to a **Cloud Pub/Sub** topic.
- **Execution**: A **Cloud Dataflow** pipeline (Apache Beam) consumes from the Pub/Sub topic, executes micro-cleansing or de-identification in-flight, and streams the records directly into BigQuery using BigQuery's Storage Write API (which supports exactly-once delivery and high throughput).
