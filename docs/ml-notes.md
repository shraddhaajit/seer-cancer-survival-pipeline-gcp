# Machine Learning Model & Evaluation Notes

This document describes the BigQuery ML (BQML) model architecture, training configuration, and performance metrics for predicting patient survival status.

---

## 1. Model Configuration

We trained a binary classification model in BigQuery using logistic regression to predict patient status:
* **Model Type**: Logistic Regression (`LOGISTIC_REG`)
* **Target Label**: `status` (`Alive` or `Dead`)
* **Feature Scope**: Demographic traits, tumor biomarkers, and clinical stages.
* **Class Balancing**: `AUTO_CLASS_WEIGHTS = TRUE`
  * *Rationale*: The dataset is highly imbalanced (~84.7% Alive, ~15.3% Dead). Standard models tend to optimize for the majority class, resulting in high overall accuracy but near-zero recall for the minority class. Auto class weighting ensures the model gives higher weight to the "Dead" class, which is vital in clinical diagnosis to identify high-risk cases.

### Features Utilized:
- **Demographics**: `age`, `race`, `marital_status`
- **Clinical Staging**: `t_stage`, `n_stage`, `ajcc_6th_stage`, `a_stage`
- **Tumor Attributes**: `tumor_size_mm`, `grade`, `differentiate`
- **Biomarkers**: `estrogen_status`, `progesterone_status`
- **Node Metrics**: `regional_nodes_examined`, `regional_nodes_positive`

*Note: The de-identified view was used, meaning no sensitive patient identifiers (`patient_id`) were leaked into the training set.*

---

## 2. Evaluation Metrics

Below are the performance metrics retrieved from `ML.EVALUATE`:

| Metric | Value | Interpretation |
| :--- | :--- | :--- |
| **ROC AUC** | **0.7401** | Standard indicator of classification capacity. A score of 0.74 represents good discrimination between survival outcomes. |
| **Accuracy** | **0.7388** | 73.9% of all cases were classified correctly. Lower than unweighted accuracy due to class weight balancing. |
| **Recall** | **0.5763** | 57.6% of deceased cases were correctly flagged by the model. Crucial for clinical risk identification. |
| **Precision** | **0.3100** | 31.0% of cases predicted as "Dead" were actually deceased. |
| **F1 Score** | **0.4032** | Harmonic mean of precision and recall. |
| **Log Loss** | **0.5934** | Measures the closeness of prediction probabilities to actual labels. |

---

## 3. Confusion Matrix

Retrieved from `ML.CONFUSION_MATRIX`:

| Expected \ Predicted | Alive | Dead |
| :--- | :--- | :--- |
| **Alive** | **2,618** (True Negative) | **790** (False Positive) |
| **Dead** | **261** (False Negative) | **355** (True Positive) |

### Clinical Interpretation:
- By configuring class weights, we successfully shifted the classification threshold to prioritize **Recall (57.6%)** for deceased cases. 
- In clinical risk modeling, a false alarm (predicting high-risk/Dead for an Alive patient, leading to additional screening) is far more acceptable than a missed case (predicting low-risk/Alive for a deceased patient, leading to undertreatment).
