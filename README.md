<<<<<<< HEAD
# AWS-DevSecOps-Auditor-IaC
Autonomous Cloud Governance Tool: FinOps Cost Audit &amp; Security Compliance using Terraform and Python Lambda.
=======
# 🛡️ Cloud DevSecOps & FinOps Auditor (IaC Managed)

## Project Overview
A fully autonomous, zero-cost cloud governance tool built on AWS Serverless architecture (Lambda, DynamoDB) and deployed entirely via **Terraform (Infrastructure as Code - IaC)**. This project demonstrates expert-level proficiency in cloud security, cost management, and distributed systems architecture.

**Goal:** Provide continuous auditing for both security compliance (DevSecOps) and resource waste (FinOps) to deliver quantifiable cost savings and risk reduction.

## 📊 Quantified Achievements (Proof of Value)

| Audit Pillar | Check Performed | Value Proposition | Status |
| :--- | :--- | :--- | :--- |
| **FinOps** (Cost Savings) | EBS Unattached Volume Audit | **Identifies wasted cloud expenditure** by flagging unused storage volumes. | **LIVE** |
| **DevSecOps** (Security) | S3 Public Access Block Audit | **Mitigates data leak risk** by verifying 100% of S3 buckets are protected from public access. | **LIVE** |
| **Architecture** | IaC Deployment (Terraform) | Achieved 100% immutable infrastructure, eliminating configuration drift. | **VERIFIED** |

## ⚙️ Architecture and Technology Stack
The system runs autonomously via an **AWS EventBridge** cron job that triggers an **AWS Lambda function** (Python/Boto3). Audit findings are stored in a **DynamoDB** table. 

**Core Technologies:**
* **IaC:** **Terraform**
* **Automation:** **Python (Boto3)**
* **Compute:** AWS Lambda (Python 3.11)
* **Database:** AWS DynamoDB (NoSQL)
* **Scheduling:** AWS EventBridge

## 🚀 Setup & Deployment

### 1. Requirements
1.  AWS Account and configured `aws cli` with programmatic access.
2.  Terraform CLI installed.

### 2. Deployment
Clone the repository and run these three commands to deploy the entire stack:
```bash
terraform init
terraform plan
terraform apply
>>>>>>> 2eb56bd (Finalizing DevSecOps Auditor project, including README and FinOps checks)
