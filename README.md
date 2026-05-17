# 🚜 Smart-Farm-GitOps (Continuous Deployment & Kubernetes Manifests)

![Kubernetes](https://img.shields.io/badge/Kubernetes-EKS-blue)
![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-red)
![AWS](https://img.shields.io/badge/AWS-EKS-orange)
![Monitoring](https://img.shields.io/badge/Monitoring-Prometheus-green)
![Grafana](https://img.shields.io/badge/Dashboard-Grafana-yellow)

---

# 📖 Overview

Welcome to the **Smart-Farm-GitOps** repository.

This repository acts as the **Single Source of Truth (SSOT)** for the Smart Agriculture Platform's Kubernetes infrastructure. It follows the **GitOps methodology** powered by **ArgoCD** to achieve fully automated, self-healing, zero-downtime deployments directly into the AWS EKS cluster.

In this architecture:

- Application source code lives in the `Smart-Farm-Monorepo`
- Kubernetes manifests and deployment configurations live in this repository
- ArgoCD continuously synchronizes Git with the live Kubernetes cluster

Any changes pushed to the `main` branch are automatically detected and applied to the infrastructure without manual intervention.

---

# 🏗️ High-Level Architecture

```text
                 ┌──────────────┐
                 │   Developers │
                 └──────┬───────┘
                        │ Git Push
                        ▼
               ┌─────────────────┐
               │ Jenkins CI/CD   │
               └──────┬──────────┘
                      │ Builds Docker Images
                      │ Updates Image Tags
                      ▼
          ┌──────────────────────────┐
          │ Smart-Farm-GitOps Repo   │
          └──────────┬───────────────┘
                     │ Watched By
                     ▼
                ┌──────────┐
                │ ArgoCD   │
                └────┬─────┘
                     │ Sync
                     ▼
          ┌────────────────────┐
          │ AWS EKS Cluster    │
          └─────────┬──────────┘
                    │
       ┌────────────┴────────────┐
       ▼                         ▼
┌─────────────┐          ┌─────────────┐
│ AI Service  │          │ IoT Service │
└──────┬──────┘          └──────┬──────┘
       │                         │
       └──────────┬──────────────┘
                  ▼
          ┌──────────────┐
          │ AWS RDS      │
          │ PostgreSQL   │
          └──────────────┘


                    Monitoring Stack
        ┌────────────────────────────────┐
        │ Prometheus + Grafana + Alerts │
        └────────────────────────────────┘
```

---

# 🎯 What is this repository?

In modern Cloud-Native architectures, deployment configuration is separated from application logic.

This repository defines:

- HOW applications are deployed
- WHERE applications run
- Kubernetes networking rules
- Monitoring & observability stack
- Infrastructure automation policies

While the main application repository contains:

- Python backend services
- AI inference logic
- Flutter frontend
- Business logic

This repository manages the Kubernetes layer responsible for running everything inside AWS EKS.

---

# 🛠️ Technologies Used

- Kubernetes (AWS EKS)
- ArgoCD (GitOps)
- Helm Charts
- Docker
- Jenkins CI/CD
- NGINX Ingress Controller
- Prometheus
- Grafana
- AWS RDS PostgreSQL
- Python Flask
- TensorFlow Lite
- Flutter Web

---

# 📁 Repository Structure

The repository follows a flat manifest architecture for easier automation and CI/CD mutation handling.

---

# 1️⃣ Application Manifests (Smart Farm Services)

These manifests deploy the custom Smart Farm microservices.

---

## `namespace.yaml`

Creates the isolated Kubernetes namespace:

```text
smart-farm
```

This namespace contains all Smart Farm workloads and resources.

---

## `database-secret.yaml`

Stores the PostgreSQL database connection string as a Kubernetes Secret.

Used by backend services to securely access the AWS RDS database.

---

## `deployment-ai.yaml`

Deploys the AI Computer Vision service.

Features:
- Flask API
- TensorFlow Lite inference
- Resource limits
- Liveness health checks
- ClusterIP internal service
- Horizontal scalability via replicas

---

## `deployment-iot.yaml`

Deploys the IoT Data Collector service.

Responsible for:
- Receiving sensor data
- Processing IoT device payloads
- Writing data into PostgreSQL

Includes:
- Environment variables from Kubernetes Secrets
- Resource management
- Health monitoring

---

## `smart-farm-ingress.yaml`

Defines the external HTTP routing rules using NGINX Ingress.

### Routing Rules

| Path | Destination |
|---|---|
| `/ai` | AI Service |
| `/api` | IoT Service |

The ingress acts as a reverse proxy and exposes internal ClusterIP services to external users.

---

# 2️⃣ Infrastructure & Observability (GitOps Managed)

These manifests bootstrap essential infrastructure components through ArgoCD.

---

## `nginx-ingress-app.yaml`

ArgoCD Application responsible for installing:

```text
NGINX Ingress Controller
```

using the official Helm chart.

The Ingress Controller provisions the AWS Load Balancer and manages all ingress traffic inside the cluster.

---

## `prometheus-app.yaml`

Deploys the full monitoring stack using:

```text
kube-prometheus-stack
```

Components include:

- Prometheus
- Grafana
- Alertmanager
- Node Exporter
- kube-state-metrics

This stack provides full observability for the Kubernetes cluster.

---

## `prometheus-alerts.yaml`

Defines custom Prometheus alert rules.

Current alerts include:
- AI Service downtime
- IoT Service downtime

Critical alerts trigger if services remain unavailable for more than one minute.

---

## `argocd-ingress.yaml`

Exposes the ArgoCD Web UI through NGINX Ingress.

---

## `grafana-ingress.yaml`

Exposes the Grafana dashboard through NGINX Ingress.

---

# 📊 Monitoring & Dashboards

| Service | URL |
|---|---|
| ArgoCD | `argocd.aws-internal.com` |
| Grafana | `grafana.aws-internal.com` |
| Smart Farm API | `farm.aws-internal.com/api` |
| AI Service | `farm.aws-internal.com/ai` |

---

# 🔄 Automated GitOps Workflow

This repository is tightly integrated with the Jenkins CI/CD pipeline.

---

## Step 1 — Continuous Integration (CI)

Jenkins:
- Builds new Docker images
- Runs CI pipelines
- Pushes images to Docker Hub

Example:
```text
hassanmaher2001/farmnet-ai-service:v15
```

---

## Step 2 — Manifest Mutation

Jenkins automatically updates:

- `deployment-ai.yaml`
- `deployment-iot.yaml`

with the latest Docker image tags.

---

## Step 3 — Commit & Push

The updated manifests are committed back into this GitOps repository.

---

## Step 4 — Continuous Deployment (CD)

ArgoCD continuously watches this repository.

When changes are detected:
- ArgoCD synchronizes the cluster
- Kubernetes performs rolling updates
- Old pods are replaced gradually
- User traffic remains uninterrupted

---

# 🔁 GitOps Deployment Flow

```text
[ Developers ]
       │
       ▼
[ Jenkins Pipeline ]
       │
       ▼
[ Docker Hub ]
       │
       ▼
[ Smart-Farm-GitOps Repo ]
       │
       ▼
[ ArgoCD ]
       │
       ▼
[ AWS EKS Cluster ]
```

---

# 🚀 Cluster Bootstrapping Instructions

To deploy the platform on a fresh AWS EKS cluster:

---

# Step 1 — Install ArgoCD

```bash
kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

---

# Step 2 — Deploy Base Resources

```bash
kubectl apply -f namespace.yaml

kubectl apply -f database-secret.yaml
```

⚠️ Ensure your PostgreSQL connection string is properly Base64 encoded before deployment.

---

# Step 3 — Deploy Infrastructure Applications

```bash
kubectl apply -f nginx-ingress-app.yaml

kubectl apply -f prometheus-app.yaml
```

These applications instruct ArgoCD to install:
- NGINX Ingress Controller
- Prometheus Stack

---

# Step 4 — Deploy Smart Farm Services

```bash
kubectl apply -f deployment-ai.yaml

kubectl apply -f deployment-iot.yaml

kubectl apply -f smart-farm-ingress.yaml
```

---

# ♻️ Why GitOps?

GitOps provides multiple operational advantages:

- Declarative Infrastructure
- Full audit history through Git
- Easy rollback capabilities
- Automated drift detection
- Self-healing infrastructure
- Consistent cluster state
- Reduced manual operational errors
- Faster deployment workflows

---

# 🔒 Security Best Practices

## No Hardcoded Production Secrets

⚠️ The current `database-secret.yaml` is intended for development/demo purposes only.

In production environments, secrets should be managed using:
- AWS Secrets Manager
- External Secrets Operator
- Bitnami Sealed Secrets

---

## Resource Isolation

All services define:
- CPU requests
- Memory requests
- Resource limits

This prevents noisy-neighbor resource exhaustion inside Kubernetes nodes.

---

## Self-Healing Infrastructure

All critical services use:

```text
livenessProbe
```

If a container freezes or becomes unhealthy:
- Kubernetes automatically restarts it
- Service availability is maintained

---

# 📈 Future Improvements

Potential production-grade enhancements:

- Horizontal Pod Autoscaler (HPA)
- AWS ALB Ingress Controller
- External Secrets Operator
- TLS Certificates via cert-manager
- GitOps App-of-Apps Pattern
- Loki Log Aggregation
- Argo Rollouts (Canary Deployments)

---

# 👨‍💻 Author

**Hassan Maher Hassan**  
Cloud Infrastructure & DevOps Engineering Student

- GitHub: `github.com/hassan-maher-dev`
- LinkedIn: `linkedin.com/in/hassan-maher-ec`

---

# ⭐ Final Notes

This repository demonstrates a complete GitOps-driven Kubernetes deployment workflow including:

- CI/CD Automation
- Kubernetes Networking
- Monitoring & Alerting
- Infrastructure as Code
- Cloud-Native Deployment Patterns
- AWS EKS Production Concepts

The project was designed to simulate real-world DevOps engineering practices used in modern cloud environments.