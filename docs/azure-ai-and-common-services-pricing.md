# Validated Azure AI & Common Services Pricing Guide

Validated date: 2026-05-15  
Region assumption for examples: East US / USD unless explicitly changed in Azure Pricing Calculator.  
Purpose: architecture-level cost classification, not a quote.

## Rules for interpreting Azure pricing

Azure pricing is not stable enough to maintain as hard-coded monthly numbers in a static file. Treat every dollar amount below as directional only. Final pricing must be validated in the Azure Pricing Calculator for the selected region, currency, offer, SKU, reservation/savings plan, and support agreement.

The most important pricing distinction is not the exact monthly average. It is whether a service creates a standing cost when provisioned.

| Cost behavior | Meaning | Examples |
| :--- | :--- | :--- |
| Pure consumption | No meaningful standing platform charge when unused, except dependencies such as storage/logging | Azure OpenAI standard token deployments, Functions Consumption, Logic Apps Consumption, Event Grid |
| Provisioned/hourly | Billed while the resource exists, even with no traffic | AI Search paid tiers, App Service Plan, AKS nodes, Firewall, Bastion, VPN Gateway, Application Gateway, API Management dedicated tiers |
| Capacity/storage | Billed for allocated capacity or stored data | Managed Disks, Blob Storage, Azure Files, Backup vault storage, Cosmos DB provisioned RU/s |
| Hybrid | Has both fixed provisioned components and usage components | Front Door, Application Gateway, API Management, Databricks, Synapse, ExpressRoute, Defender for Cloud |

## Corrections applied to the uploaded file

The uploaded file said it covered the “top 45 Azure services,” but the coverage was uneven and missed several services that materially affect real Azure AI and enterprise architecture costs.

Major corrections:
- Azure OpenAI is not only “tokens.” Standard deployments are token-based, but provisioned throughput, batch, fine-tuning, audio, image, and Foundry model deployments have separate pricing behavior.
- Microsoft Foundry / Azure AI Foundry was missing. The platform itself can be free to explore, but consumed models, tools, connections, hosted agents, storage, search, logging, and compute are billable.
- Azure AI Search was understated. Paid search units are billed hourly while the service exists; stopping traffic does not stop billing.
- Azure Machine Learning was too vague. The workspace itself is not usually the main cost; compute instances, compute clusters, online endpoints, managed networks, storage, container registry, Key Vault, and logs are the cost drivers.
- Azure AI Personalizer and Azure AI Anomaly Detector should be flagged as retiring on 2026-10-01. Do not recommend them for new architecture.
- AKS was too simplified. The control plane can be free in the Free tier, but production clusters incur node, storage, load balancer, public IP, NAT, logs, Defender, and optional tier/support costs.
- Microsoft Defender for Cloud cannot be summarized as “$15/node/month.” It has separate plans for servers, storage, databases, containers, APIs, AI services, CSPM, and serverless workloads.
- Load Balancer and Application Gateway rows incorrectly emphasized legacy/basic-style pricing. Modern designs usually use Standard Load Balancer and v2 Application Gateway/WAF, with associated public IP and data-processing costs.
- API Management was underexplained. Consumption is execution-based; Developer/Basic/Standard/Premium/v2 tiers have standing hourly/monthly costs.
- Missing networking costs were significant: Private Endpoint, Private DNS, Public IP, NAT Gateway, ExpressRoute, bandwidth/egress.
- Missing data/AI platform services were significant: Microsoft Fabric, Azure SQL Managed Instance, Azure Files, Event Hubs, Event Grid, Stream Analytics, Microsoft Sentinel, Storage Account transactions, and Azure Cache for Redis.

## Azure AI, Foundry, and Machine Learning Services

| Service | Correct pricing model | Idle/start cost behavior | Corrected cost notes |
| :--- | :--- | :--- | :--- |
| Azure OpenAI Service | Token-based for standard deployments; provisioned throughput for PTU; separate model-specific meters | Standard token deployments usually have no standing model charge when unused; PTU is provisioned capacity and costs while allocated | Pricing depends on model, deployment type, input/output/cached tokens, batch usage, fine-tuning, image/audio, and region. Do not describe it as only “per 1K tokens.” |
| Foundry Models | Pay-as-you-go serverless model billing or provisioned throughput, depending on model/deployment | Depends on model deployment type | Includes Azure OpenAI, DeepSeek, Llama, Mistral, Cohere, Grok, Microsoft models, and others. Treat each model as its own meter. |
| Foundry Agent Service | No extra charge for some native agent orchestration; billable dependencies and hosted-agent compute | Native agent orchestration may be $0, but models/tools/storage/logs still bill | Hosted agents are billed on underlying managed container compute. Tools/connectors such as Logic Apps, Fabric, SharePoint, Grounding with Bing, and model tokens can add cost. |
| Microsoft Foundry / Azure AI Foundry portal | Platform shell/governance experience plus separately billed services | The platform can be free to explore; consumed services bill normally | Creating a Foundry hub/project is not the same as running models, Search, storage, compute, or agents. |
| Azure AI Search | Hourly search units; add-ons such as semantic ranker, agentic retrieval, enrichment, vectorization may add costs | Paid tiers bill hourly while the service exists, even without queries | Cost depends on tier, replicas, partitions, semantic ranker, indexer/enrichment workload, storage, and query volume. Free tier is for dev/test only. |
| Azure Machine Learning | Compute, online endpoints, storage, networking, registry, logs | Workspace is not the main cost; compute/endpoints can create standing cost | Compute instances, compute clusters, managed online endpoints, AKS endpoints, storage, Key Vault, Container Registry, App Insights, Log Analytics, and managed network features drive cost. Stop/delete idle compute. |
| Azure AI Document Intelligence | Per page or transaction, depending on feature/model | Usually low/no standing cost unless containers or connected resources are deployed | Good consumption service, but high-volume document processing can become expensive. Include storage and post-processing costs. |
| Azure AI Vision / Computer Vision | Per transaction; some features have separate meters | Usually no standing API cost when unused | Vision OCR/image analysis costs depend on API feature and volume. |
| Azure AI Speech | Audio/time/character/transaction based depending on STT/TTS/translation/voice features | Usually no standing API cost when unused | Speech-to-text, text-to-speech, custom speech, batch transcription, and neural voice are priced differently. |
| Azure AI Language | Per text record/transaction; some features priced separately | Usually no standing API cost when unused | Summarization, PII, sentiment, entity recognition, custom text classification, and conversational language features can have different meters. |
| Azure AI Translator | Character-based | Usually no standing API cost when unused | Cost is driven by translated characters and feature tier. |
| Azure AI Content Safety | Text/image transaction-based | Usually no standing API cost when unused | Common in GenAI moderation pipelines. Budget for both prompt and completion moderation if used on both sides. |
| Azure AI Bot Service / Azure Bot Framework | Bot service plus channels; Direct Line and related channels can bill; hosting still separate | Bot registration alone may be low cost; App Service/Functions/Container Apps hosting can bill | Do not forget the compute hosting the bot and any OpenAI/Search/Storage dependencies. |
| Azure AI Video Indexer | Per input minute, by audio/video analysis preset | Trial/free quota exists, then usage-based | Cost depends on indexing preset and media duration. Validate current Video Indexer account model. |
| Azure AI Personalizer | Transaction-based, but service is retiring | Do not use for new projects | Retires on 2026-10-01. Existing workloads need migration planning. |
| Azure AI Anomaly Detector | Transaction-based, but service is retiring | Do not use for new projects | Retires on 2026-10-01. Existing workloads need migration planning. |
| Azure Databricks | DBUs plus underlying compute/storage/networking; serverless has its own meters | Clusters/warehouses/serverless compute cost when running | Budget for DBUs, VMs if classic compute, serverless SQL/Model Serving, storage, networking, Unity Catalog dependencies, and logs. |
| Microsoft Fabric | Capacity-based and/or per-user licensing depending on SKU/workload | Fabric capacity can create standing cost | Important for AI/data architecture. Include OneLake storage, capacity units, Power BI licensing, and workload-specific consumption. |

## Core compute, containers, and app platform

| Service | Correct pricing model | Idle/start cost behavior | Corrected cost notes |
| :--- | :--- | :--- | :--- |
| Virtual Machines | Per-second compute while running; disks/IPs/licenses separate | Deallocated VM stops compute cost, but disks, static IPs, snapshots, backup, and logs continue | Stopped inside OS is not the same as deallocated. |
| App Service | App Service Plan tier/capacity | Paid plans bill while provisioned even with zero traffic | Multiple apps can share one plan. Free/Shared are limited; Basic/Standard/Premium/Isolated have standing costs. |
| Azure Functions | Consumption, Flex Consumption, Premium, or App Service Plan | Consumption can be near-zero when idle; Premium/App Service Plan has standing cost | Storage account, Application Insights, networking, and premium pre-warmed instances can add cost. |
| Azure Container Apps | Consumption or workload profiles/dedicated | Can scale to zero in consumption mode; dedicated profiles can create standing cost | Include Log Analytics, Container Registry, managed environment, ingress, egress, and Dapr/sidecar effects. |
| AKS | Node VMs plus storage/networking/logging; optional cluster tier/features | Nodes bill while running; cluster supporting services also bill | Production clusters usually require load balancers, public IPs/NAT, disks, logs, Defender, ACR, and possibly Uptime/SLA/tier features. |
| Azure Container Registry | Tier plus storage and operations | Registry tier/storage can create small standing cost | Premium is often required for private networking, geo-replication, and higher throughput. |
| Azure Virtual Desktop | Session host compute/storage plus licensing eligibility | Host pools cost through VMs/disks while running | Autoscale/deallocate hosts to reduce idle cost. Include FSLogix/profile storage and networking. |

## Data, analytics, and integration

| Service | Correct pricing model | Idle/start cost behavior | Corrected cost notes |
| :--- | :--- | :--- | :--- |
| Blob Storage / Storage Account | Capacity, transactions, redundancy, data retrieval, egress | Stored data and some operations bill even with no app traffic | Hot/Cool/Cold/Archive, LRS/ZRS/GRS/GZRS, transactions, lifecycle, private endpoint, and egress change cost materially. |
| Azure Files | Provisioned or used capacity depending on tier; transactions; snapshots; redundancy | File shares can create standing storage cost | Important for lift-and-shift, FSLogix, and shared app storage. |
| Managed Disks | Provisioned disk/SKU size, snapshots, bursting, transactions for some SKUs | Bill while disk exists, even unattached | This is a common hidden idle cost. Delete unattached disks if not needed. |
| Azure SQL Database | DTU/vCore/serverless/hyperscale; storage/backup separate | Provisioned DBs bill while allocated; serverless may auto-pause if configured and eligible | Serverless does not always mean zero cost; storage and backup continue. |
| Azure SQL Managed Instance | Provisioned vCores/storage; reserved capacity possible | Standing cost while provisioned | Usually much more expensive than small Azure SQL Database. Critical for enterprise SQL lift-and-shift. |
| Cosmos DB | Provisioned RU/s, autoscale RU/s, serverless RU, storage, regions | Provisioned throughput bills even when idle | Multi-region writes/reads, autoscale, backup, analytical store, and indexing can materially change cost. |
| Synapse Analytics | Serverless per TB scanned; dedicated SQL pool hourly; Spark pools; storage | Dedicated pools bill when running; serverless bills by query volume | Pause dedicated pools when idle. Serverless cost depends on data scanned. |
| Data Factory | Pipeline orchestration, activity runs, data movement, integration runtime hours | Mostly usage-based, but self-hosted compute and managed VNet IR can add costs | Debug sessions and data flows can surprise budgets. |
| Event Grid | Operations/events | Near-zero when unused | Good low-cost eventing service. |
| Event Hubs | Throughput units/capacity units plus events/capture/storage | Standard/Premium/Dedicated can create standing cost | Include Capture storage and retention. |
| Service Bus | Operations for Basic/Standard; Messaging Units for Premium | Premium has standing capacity cost | Standard is usually low-cost; Premium is for isolation/performance. |
| Logic Apps | Consumption per action/connector; Standard has plan-style hosting | Consumption can be near-zero; Standard has standing hosting cost | Enterprise connectors can have different pricing. |
| API Management | Consumption per operation; Developer/Basic/Standard/Premium/v2 tier capacity | Dedicated tiers bill while provisioned | Developer is not for production. Consumption has lower idle cost but different networking/performance limits. |
| Azure Cache for Redis / Azure Managed Redis | Tier/capacity based | Bills while provisioned | Include this for web/API architectures; cache nodes are standing cost. |

## Monitoring, security, identity, and governance

| Service | Correct pricing model | Idle/start cost behavior | Corrected cost notes |
| :--- | :--- | :--- | :--- |
| Azure Monitor platform metrics | Basic platform metrics often included; alerts/logs/export may bill | Depends on feature | Separate Azure Monitor from Log Analytics ingestion. |
| Log Analytics Workspace | Data ingestion, retention, archive/search, commitment tiers | Ingestion is usage-based; retained data can bill | The “first free GB” rules vary by context and plan; do not hard-code as universal. |
| Application Insights | Usually Log Analytics-backed ingestion/retention | Usage-based, but telemetry volume can grow quickly | Sampling and retention policy matter. |
| Microsoft Sentinel | Security data ingestion/analytics, retention, automation | Usage-based but often expensive at enterprise log volumes | Built on Log Analytics; commitment tiers and Microsoft Defender data connectors affect cost. |
| Microsoft Defender for Cloud | Separate plans by workload/resource type | Foundational CSPM can be free; paid plans bill per protected workload/resource | Servers, storage, SQL, containers, APIs, databases, CSPM, and serverless all have separate pricing. |
| Entra ID | Per-user licensing by plan/features | Free tier exists; P1/P2/Governance/ID Protection features require licenses | Azure RBAC itself is not the same as Entra ID P1/P2 licensing. |
| Key Vault | Operations, keys/secrets/certificates; Managed HSM is separate | Standard secrets are usually low-cost; HSM can be expensive | Include private endpoint and logging if enabled. |
| Resource Graph | Generally free for querying Azure resources | No normal direct cost | Useful for inventory, compliance, and cost hygiene queries. |

## Networking and private connectivity

| Service | Correct pricing model | Idle/start cost behavior | Corrected cost notes |
| :--- | :--- | :--- | :--- |
| Load Balancer | Standard LB rules/data processing plus public IP costs | Standard resources can create standing/usage costs | Basic Load Balancer is legacy; use Standard for current production design. |
| Public IP Address | Hourly by SKU/allocation; IPv4 scarcity affects cost | Static public IPs can bill even when attached resource is stopped/deallocated | Common hidden cost. Delete unused static public IPs. |
| NAT Gateway | Hourly plus data processed | Bills while provisioned | Important for AKS, Container Apps, App Service VNet integration, and private outbound patterns. |
| Private Endpoint / Private Link | Hourly per endpoint plus data processed | Bills while endpoint exists | Common hidden cost in private Azure architectures. |
| Private DNS Zone | Per zone and queries | Small standing/query cost | Required for Private Link architectures. Include cross-VNet link design. |
| VPN Gateway | Hourly gateway SKU plus data transfer | Bills while gateway exists | A small test VPN gateway still has standing cost. |
| ExpressRoute | Circuit port/monthly fee, gateway, outbound data depending plan, provider charges | Significant standing cost once circuit/service key is active/provisioned | Include ExpressRoute gateway and telecom/provider costs. |
| Azure Firewall | Hourly base plus data processed; Standard/Premium/Basic differ | Bills while deployed | High standing cost. Firewall Policy, logs, and data processing add cost. |
| Application Gateway | Capacity/hourly plus data; WAF adds cost | v2/WAF has standing cost even with little traffic | Include public IP, logs, WAF policy, and autoscale capacity. |
| Azure Front Door | Profile/rules/WAF/requests/data transfer | Has baseline/profile and usage components | Usually cheaper than App Gateway for simple global static/demo cases, but WAF/rules/egress matter. |
| Azure Bastion | Hourly plus scale units/data depending SKU | Bills while deployed | Delete non-production Bastion when not needed if policy allows. |
| Azure DNS | Zone plus query charges; public and private differ | Low standing/query cost | Public DNS and Private DNS are priced differently. |

## Practical cost classification for demos

For a low-cost demo, prefer:
- Azure OpenAI standard token deployment instead of PTU.
- Azure AI Search Free/Basic only if needed, and delete paid search services after the demo.
- Functions Consumption or Container Apps Consumption rather than App Service Premium, AKS, or VM-hosted APIs.
- Blob Storage with lifecycle policy.
- Log Analytics with strict daily cap/retention.
- Avoid Azure Firewall, Application Gateway WAF, Bastion, VPN Gateway, ExpressRoute, Databricks, Fabric capacity, and SQL Managed Instance unless they are explicitly part of the demo.

For enterprise private architecture, budget separately for:
- Private Endpoints.
- Private DNS Zones and VNet links.
- NAT Gateway or Azure Firewall for outbound control.
- Log Analytics/Sentinel ingestion.
- Defender for Cloud paid plans.
- Public/static IP addresses.
- Backup and disaster recovery.
- Cross-region replication and data egress.

## Final validation statement

The corrected document is now architecturally safer than the uploaded version because it no longer presents unstable estimated monthly numbers as if they were reliable. It classifies services by cost behavior, flags retiring AI services, adds missing AI/Foundry/network/security services, and identifies idle-cost traps that usually cause unexpected Azure bills.
