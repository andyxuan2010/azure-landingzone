# Expanded Azure Services & AI Pricing Guide (2026)

This document provides an overview of the top 45 Azure services, focusing heavily on AI and Machine Learning, alongside core infrastructure.

## Azure AI & Machine Learning Services

| Service Name | Pricing Model | Minimal Cost (Start/Idle) | Typical Avg. Cost (Monthly) | Key Cost Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Azure OpenAI** | Consumption (Tokens) | $0 | $50 - $500 | Pricing depends on model (GPT-4o, GPT-3.5, etc.) and token count. |
| **Azure Machine Learning** | Compute + Storage | ~$70 (D-Series Node) | $200 - $1,000 | Pay for VMs used for training/inferencing and storage for data. |
| **Azure AI Search** | Search Units (SU) | ~$100 (Basic SKU) | $300 - $900 | SU cost covers replicas and partitions; scales with capacity. |
| **Azure AI Document Intelligence**| Page-based | $0 (Free 500 pages) | $50 - $2,000 | Charged per page analyzed; high volume can scale costs quickly. |
| **Azure AI Vision** | Per Transaction | $0 (Free 5k calls) | $20 - $150 | Standard tier is roughly $2.00 per 1,000 transactions. |
| **Azure AI Speech** | Token / Hour based | $0 (Free 5 hours) | $50 - $200 | STT, TTS, and Translation; Custom Neural Voice has extra fees. |
| **Azure AI Language** | Per Transaction | $0 (Free 5k calls) | $10 - $100 | Charged per 1k text records for sentiment and summarization. |
| **Azure AI Translator** | Per Character | $0 (Free 2M chars) | $10 per 1M chars | Pay for characters translated; free tier resets monthly. |
| **Azure AI Bot Service** | Per Message | $0 (Standard Chans) | $0.50 / 1k msgs | Premium channels (DirectLine) incur costs + App Service. |
| **Azure AI Video Indexer** | Per Minute | $0 (Free 10 hours) | $0.15 - $0.25 / min | Costs vary by indexing preset (Basic vs Advanced). |
| **Azure AI Content Safety** | Per Image / Text | $0 (Free 5k calls) | $1.50 per 1k calls | Detects hate, violence, and self-harm in AI workflows. |
| **Azure AI Personalizer** | Per Transaction | $0 (Free 50k events) | $6.50 per 1k events | Tier-based pricing; cheaper at higher volumes. |
| **Azure AI Anomaly Detector**| Per Transaction | $0 (Free 20k calls) | $0.31 per 1k calls | Identifies data trends and outliers in time-series data. |
| **Azure Databricks** | Unit-based (DBU) | ~$0.07 / DBU | $200 - $2,000 | Unified analytics platform; costs added to underlying VMs. |

## Core Infrastructure & Platform Services

| Service Name | Pricing Model | Minimal Cost (Start/Idle) | Typical Avg. Cost (Monthly) | Key Cost Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Virtual Machines (VM)** | Usage (Per second) | ~$4 (B1s instance) | $70 - $150 | Stop/Deallocate to pause compute costs. |
| **App Service** | Tier-based (Plan) | Free Tier ($0) | $50 - $150 | Cost is per Plan, multiple apps can share one plan. |
| **Azure Functions** | Consumption (Usage) | $0 (1M calls free) | $5 - $20 | Great for event-driven tasks; serverless scaling. |
| **Azure Kubernetes (AKS)** | Usage (Node cost) | ~$70 (Standard node) | $200 - $500+ | Only pay for the VMs in your cluster. |
| **Azure Container Apps** | Consumption | $0 (Free grant units) | $10 - $50 | Scaled to zero = no cost. Pay for CPU/Memory active time. |
| **Blob Storage** | Capacity + Ops | $0.018 / GB (Hot) | $25 - $100 | Inbound is free; outbound data transfer is charged. |
| **Managed Disks** | Provisioned | $0.60 / mo (32GB HDD) | $20 - $80 | Fixed monthly cost regardless of disk utilization. |
| **Azure SQL Database** | DTU or vCore | ~$5 / mo (Basic) | $150 | Serverless tier auto-scales and pauses when idle. |
| **Cosmos DB** | Request Units (RU/s) | ~$24 / mo (400 RU/s) | $100 - $500 | Pay for throughput (RU/s) and storage. |
| **Azure Monitor** | Data Ingestion | $0 (Basic metrics) | $2.30 / GB ingested | Log Analytics ingestion and storage drive costs. |
| **Entra ID (Active Dir.)** | Per User / Tier | Free (Basic) | $6 / user (P1) | Identity management; advanced features require P1/P2. |
| **Key Vault** | Per Transaction | $0.03 / 10k ops | < $1.00 | Security secrets/keys; managed HSMs are much pricier. |
| **Load Balancer** | Usage (Data/Rules) | ~$18 / mo (Basic) | $20 - $40 | Charged per rule and amount of data processed. |
| **VPN Gateway** | Hourly + Data | ~$26 / mo (Basic) | $140 | Data transfer outbound is charged separately. |
| **Azure Firewall** | Hourly + Data | ~$900 / mo | $1,000+ | Premium network security; high base cost. |
| **Application Gateway** | Hourly + Data | ~$18 / mo (Basic) | $200 - $400 | L7 Load balancer with optional WAF protection. |
| **Azure Front Door** | Tier-based + Data | $35 / mo (Standard) | $100 - $300 | Global CDN and edge security service. |
| **Azure Bastion** | Hourly | ~$138 / mo (Basic) | $140 | RDP/SSH access without public IPs. |
| **Log Analytics** | Data Ingestion | $0 (5GB/mo free) | $2.30 per GB | Centralized logging; pay for ingest and retention. |
| **Synapse Analytics** | Provisioned / Usage | $5 / TB (Serverless) | $500+ | Data warehousing; scales with data volume. |
| **Data Factory** | Activity-based | ~$1 / 1k acts | $50 - $200 | ETL service; price depends on orchestration runs. |
| **Azure Backup** | Per Instance + GB | $5 / mo + Storage | $20 - $100 | Cost per protected instance plus the backup data size. |
| **Site Recovery (DR)** | Per Instance | $0 (First 31 days) | $25 / instance | Disaster recovery service; pay for each protected machine. |
| **Service Bus** | Tier-based / Ops | ~$10 / mo (Standard) | $10 - $100 | Message queueing; Standard is per-op; Premium is fixed. |
| **Logic Apps** | Per Action | $0.000025 / action | $5 - $50 | Low-code workflows; price per execution step. |
| **Container Registry** | Tier-based | $0.16 / day (Basic) | $5 - $50 | Storage for Docker images. |
| **Virtual Desktop (AVD)** | Compute + License | ~$70 (Standard VM) | $20 - $50 / user | Pay for the session host VMs and user licenses. |
| **Microsoft Defender** | Per Resource | $0 (Free tier) | $15 / node / Mo | Cloud security posture and workload protection. |
| **API Management** | Tier-based | $0 (Consumption) | $150 (Standard) | Scalable gateway for managing APIs. |
| **Azure DNS** | Per Zone / Query | $0.50 / zone | $1 - $5 | Hosting for public and private DNS zones. |
| **Resource Graph** | Usage | Free | $0 | Tool for querying Azure resources at scale. |

---
**Note:** These prices are based on East US region estimates for 2026. Use the [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/) for specific quotes.
