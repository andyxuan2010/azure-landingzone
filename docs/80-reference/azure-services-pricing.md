# Comprehensive Azure Services & AI Pricing Guide (2026)

This document provides a consolidated view of 45 common Azure services, with a specialized focus on the Azure AI and Machine Learning ecosystem.

## Azure AI & Machine Learning Services
The Azure AI portfolio (part of Azure AI Foundry) is generally consumption-based or compute-dependent.

| Service Name | Pricing Model | Minimal Cost (Start/Idle) | Typical Avg. Cost (Monthly) | Key Cost Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Azure OpenAI** | Consumption (Tokens) | $0 | $50 - $500 | Varies by model (GPT-4o vs GPT-3.5); pay per 1k tokens. |
| **Azure AI Search** | Search Units (SU) | ~$100 (Basic) | $300 - $900 | SUs combine replicas and partitions; Basic starts at ~$0.10/hr. |
| **Azure Machine Learning** | Compute + Storage | ~$70 (D-Series VM) | $200 - $1,200 | Costs come from the compute instances and clusters used for training/inference. |
| **Azure AI Document Intelligence** | Page-based | $0 (Free 500 pgs) | $50 - $1,500 | Standard tier is ~$10 per 1k pages; prebuilt models have separate pricing. |
| **Azure AI Vision** | Per Transaction | $0 (Free 5k calls) | $20 - $100 | Roughly $1.00 - $2.00 per 1,000 transactions. |
| **Azure AI Speech** | Token / Hour based | $0 (Free 5 hours) | $50 - $250 | Includes transcription and synthesis; neural voices are billed by characters. |
| **Azure AI Language** | Per Transaction | $0 (Free 5k calls) | $10 - $100 | Charged per 1,000 text records for sentiment, NER, and summarization. |
| **Azure AI Translator** | Per Character | $0 (Free 2M chars) | $10 per 1M chars | Volume-based pricing; characters include spaces. |
| **Azure AI Bot Service** | Per Message | $0 (Standard) | $0.50 / 1k msgs | Free for standard channels; Premium (DirectLine) has message costs. |
| **Azure AI Video Indexer** | Per Minute | $0 (Free 10 hours) | $0.15 / min | Costs depend on whether you use the Basic or Advanced indexing preset. |
| **Azure AI Content Safety** | Per Image / Text | $0 (Free 5k calls) | $1.50 per 1k calls | Billed for analyzing text or images for safety violations. |
| **Azure AI Personalizer** | Per Transaction | $0 (Free 50k events) | $6.50 per 1k events | Reinforcement learning for UI/content personalization. |
| **Azure AI Anomaly Detector** | Per Transaction | $0 (Free 20k calls) | $0.31 per 1k calls | Identifies outliers in time-series data. |
| **Azure Databricks** | Unit-based (DBU) | ~$0.07 / DBU | $200 - $2,000 | Billed as DBU units on top of underlying VM costs. |

## Core Infrastructure & Compute Services

| Service Name | Pricing Model | Minimal Cost (Start/Idle) | Typical Avg. Cost (Monthly) | Key Cost Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Virtual Machines (VM)** | Usage (Per second) | ~$4 (B1s) | $70 - $150 | "Deallocated" state stops compute costs; disk storage still billed. |
| **App Service** | Tier-based (Plan) | Free Tier ($0) | $50 - $150 (S1) | You pay for the "Plan" (the VM/Server) not the app itself. |
| **Azure Functions** | Consumption | $0 (1M calls free) | $5 - $20 | Pay for execution time and number of executions. |
| **Azure Kubernetes (AKS)** | Usage (Node cost) | ~$70 (Std Node) | $200 - $600 | Management is free; you pay for the VM worker nodes. |
| **Azure Container Apps** | Consumption | $0 (Free grant) | $10 - $50 | Scaled to zero = no compute cost. Pay for active vCPU/Memory. |
| **API Management** | Tier-based | $0 (Consumption) | $150 (Standard) | Gateway for securing and publishing APIs. |

## Data & Storage Services

| Service Name | Pricing Model | Minimal Cost (Start/Idle) | Typical Avg. Cost (Monthly) | Key Cost Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Blob Storage** | Capacity + Ops | $0.02 / GB (Hot) | $25 - $100 | "Cool" and "Archive" tiers reduce capacity cost but increase access cost. |
| **Managed Disks** | Provisioned | $0.60 / mo (32GB) | $20 - $80 | Fixed monthly fee based on disk size and type (SSD vs HDD). |
| **Azure SQL Database** | DTU or vCore | ~$5 / mo (Basic) | $150 | Serverless vCore tier can auto-pause to save cost. |
| **Cosmos DB** | Request Units (RU/s) | ~$24 / mo | $100 - $500 | Multi-region write replication doubles the RU cost. |
| **Synapse Analytics** | Provisioned / Usage | $5 / TB (Serverless) | $500+ | Pay for DWUs (Data Warehouse Units) or data scanned. |
| **Data Factory** | Activity-based | ~$1 / 1k activities | $50 - $200 | Pipeline orchestration cost based on step counts. |

## Networking & Security Services

| Service Name | Pricing Model | Minimal Cost (Start/Idle) | Typical Avg. Cost (Monthly) | Key Cost Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Key Vault** | Per Transaction | $0.03 / 10k ops | < $1.00 | Free/Cheap for secrets; HSM-backed keys are ~$1.00/hr. |
| **VPN Gateway** | Hourly + Data | ~$26 / mo (Basic) | $140 | Data egress transfer is the primary variable cost. |
| **Azure Firewall** | Hourly + Data | ~$900 / mo | $1,000+ | Large fixed hourly cost; best for centralized hubs. |
| **Application Gateway** | Hourly + Data | ~$18 / mo | $200 - $400 | WAF (v2) includes security rules; priced by capacity units. |
| **Azure Front Door** | Tier-based + Data | $35 / mo | $100 - $300 | Edge delivery and security; data transfer volume is key. |
| **Azure Bastion** | Hourly | ~$138 / mo | $140 | Secure RDP/SSH; fixed hourly rate once enabled. |
| **Entra ID (Active Dir.)** | Per User / Tier | Free (Basic) | $6 / user | Premium P1/P2 add security features like MFA/Cond. Access. |
| **Microsoft Defender** | Per Resource | $0 | $15 / node | Protection for servers, SQL, and storage billed per instance. |

## Monitoring & Management

| Service Name | Pricing Model | Minimal Cost (Start/Idle) | Typical Avg. Cost (Monthly) | Key Cost Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Azure Monitor** | Data Ingestion | $0 (Metrics) | $2.30 / GB | Log Analytics ingestion is the main variable cost. |
| **Log Analytics** | Ingestion + Ret. | $0 (5GB free) | $2.30 / GB | Pay for what you upload; 31 days retention is free. |
| **Azure Backup** | Per Instance + GB | $5 / mo + Storage | $20 - $100 | Price scales with the size of the VM and retention policy. |
| **Site Recovery (DR)** | Per Instance | $0 (First 31 days) | $25 / instance | Pay for each machine protected against regional disaster. |
| **Logic Apps** | Per Action | $0.000025 / step | $5 - $50 | Low-code workflows; Standard tier has a fixed base cost. |
| **Service Bus** | Tier-based / Ops | ~$10 / mo | $10 - $100 | Messaging; Standard is per-op; Premium is fixed hourly. |
| **Container Registry** | Tier-based | $0.16 / day | $5 - $50 | Basic, Standard, and Premium tiers differ by storage and features. |
| **Virtual Desktop (AVD)** | Compute + License | ~$70 (VM) | $20 / user | Session host VMs are the main cost; licenses are usually in M365. |
| **Azure DNS** | Per Zone / Query | $0.50 / zone | $1 - $5 | Hosting public/private DNS records; queries are very cheap. |
| **Resource Graph** | Usage | Free | $0 | Querying resources for inventory; no cost at any scale. |
| **Cost Management** | Usage | Free | $0 | No cost to use the budgeting and analysis tools. |

---
**Note:** These estimates use **East US** rates for 2026. For precise budgeting, use the [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/).
