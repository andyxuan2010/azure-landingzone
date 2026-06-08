# AKS Beginner's Guide: Operations, Authentication, and Deployment

This guide covers everything you need to know to get started with Azure Kubernetes Service (AKS). It includes authentication, common `kubectl` commands, RBAC, monitoring, logging, and simple demo applications to test your cluster.

## 1. Prerequisites

Before interacting with the AKS cluster, ensure you have the following tools installed locally:

- **Azure CLI (`az`)**: For authenticating and managing Azure resources.
- **`kubectl`**: The Kubernetes command-line tool for interacting with the cluster.
- **`kubelogin`**: A client-go credential (exec) plugin implementing Microsoft Entra ID (Azure AD) authentication.

You can install `kubectl` and `kubelogin` via the Azure CLI:
```bash
az aks install-cli
```

---

## 2. Authentication & Cluster Access

AKS integrated with Microsoft Entra ID requires you to fetch credentials using the Azure CLI.

### Fetch Credentials
To download the `kubeconfig` file to your local machine:
```bash
az account set --subscription "<your-subscription-id>"
az aks get-credentials --resource-group "<your-resource-group>" --name "<your-aks-cluster-name>"
```

### Convert Kubeconfig for Kubelogin
If your cluster uses Azure AD and Azure RBAC, convert your kubeconfig to use `kubelogin`:
```bash
kubelogin convert-kubeconfig -l azurecli
```
This allows `kubectl` to use your existing Azure CLI session for authentication.

---

## 3. Common Operations (`kubectl` Basics)

Here are the most common commands you will use daily to interact with your workloads.

### Viewing Resources
- **List all nodes (virtual machines running your apps):**
  ```bash
  kubectl get nodes
  ```
- **List all pods in the current namespace:**
  ```bash
  kubectl get pods
  ```
- **List pods across all namespaces:**
  ```bash
  kubectl get pods -A
  ```
- **List services (load balancers, cluster IPs):**
  ```bash
  kubectl get svc
  ```
- **List all deployments:**
  ```bash
  kubectl get deployments
  ```

### Inspecting Resources
- **Get detailed information about a pod (useful for troubleshooting):**
  ```bash
  kubectl describe pod <pod-name>
  ```
- **View logs for a specific pod:**
  ```bash
  kubectl logs <pod-name>
  ```
- **Stream/Tail logs (like `tail -f`):**
  ```bash
  kubectl logs -f <pod-name>
  ```

### Interacting with Pods
- **Execute an interactive shell inside a running pod:**
  ```bash
  kubectl exec -it <pod-name> -- /bin/bash
  # Or /bin/sh depending on the container image
  ```
- **Port-forward a local port to a pod (useful for testing internal apps locally):**
  ```bash
  kubectl port-forward <pod-name> 8080:80
  ```

---

## 4. RBAC and Roles

AKS supports mapping Azure Entra ID (Azure AD) users and groups to Kubernetes roles.

### Azure RBAC vs Kubernetes RBAC
- **Azure RBAC:** You can manage cluster access directly via the Azure Portal. Assigning the `Azure Kubernetes Service RBAC Cluster Admin` or `Azure Kubernetes Service RBAC Reader` role to a user gives them access without touching internal Kubernetes RoleBindings.
- **Kubernetes Native RBAC:** You create `Roles` / `ClusterRoles` and bind them to Azure AD object IDs using `RoleBindings` / `ClusterRoleBindings`.

### Verifying Access
To check if you have permission to perform an action (e.g., create deployments):
```bash
kubectl auth can-i create deployments --namespace default
```

---

## 5. Monitoring & Logging

When AKS Diagnostics (Log Analytics) is enabled, logs and metrics are forwarded to Azure Monitor.

### Container Insights
Navigate to your AKS cluster in the Azure Portal and select **Insights**. Here you can view:
- Node CPU/Memory utilization
- Pod lifecycle states
- Live stdout/stderr logs from containers

### Log Analytics Queries
You can run Kusto Query Language (KQL) queries in the attached Log Analytics workspace.
- **View Container Logs:**
  ```kql
  ContainerLog
  | where TimeGenerated > ago(1h)
  | project TimeGenerated, PodName, LogEntry
  ```
- **View KubeEvents (OOMKilled, Pod Evictions):**
  ```kql
  KubeEvents
  | where TimeGenerated > ago(1h)
  | where Reason == "OOMKilled" or Reason == "Failed"
  ```

---

## 6. Demo Applications

Below are simple examples to deploy applications to your AKS cluster for testing purposes.

### Demo 1: Deploy a simple NGINX web server

Create a file named `nginx-demo.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

**Deploy the app:**
```bash
kubectl apply -f nginx-demo.yaml
```

**Test the app:**
1. Wait for the external IP to be provisioned (this takes 1-2 minutes).
   ```bash
   kubectl get svc nginx-service -w
   ```
2. Once the `EXTERNAL-IP` changes from `<pending>` to a public IP, copy the IP.
3. Open your browser and navigate to `http://<EXTERNAL-IP>`. You should see the "Welcome to nginx!" screen.

### Demo 2: Deploy an AKS "Hello World" App (Azure Vote)

This is a standard multi-container app provided by Microsoft. Create a file named `azure-vote.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-back
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-back
  template:
    metadata:
      labels:
        app: azure-vote-back
    spec:
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
      - name: azure-vote-back
        image: mcr.microsoft.com/oss/bitnami/redis:6.0.8
        env:
        - name: ALLOW_EMPTY_PASSWORD
          value: "yes"
        ports:
        - containerPort: 6379
          name: redis
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-back
spec:
  ports:
  - port: 6379
  selector:
    app: azure-vote-back
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-front
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-front
  template:
    metadata:
      labels:
        app: azure-vote-front
    spec:
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
      - name: azure-vote-front
        image: mcr.microsoft.com/azuredocs/azure-vote-front:v1
        env:
        - name: REDIS
          value: "azure-vote-back"
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-front
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: azure-vote-front
```

**Deploy the app:**
```bash
kubectl apply -f azure-vote.yaml
```

**Clean up the demos:**
When you are done testing, you can delete the resources to save costs (specifically the Load Balancer IP).
```bash
kubectl delete -f nginx-demo.yaml
kubectl delete -f azure-vote.yaml
```

---

## Conclusion
This guide covers the essentials for managing an AKS cluster. For advanced operations like setting up Ingress controllers, integrating with Azure Key Vault via CSI provider, or implementing Network Policies, refer to the official [Microsoft AKS Documentation](https://learn.microsoft.com/en-us/azure/aks/).