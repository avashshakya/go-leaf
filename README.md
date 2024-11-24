# Go-Leaf

A Go application deployment infrastructure using AWS EKS, with separate production and staging environments. The project uses Terraform for infrastructure provisioning, GitHub Actions for CI/CD, and Helm for Kubernetes deployments.

##  Architecture Overview

The project sets up:
- A VPC and EKS clusters for production and staging environments each
- Automated CI/CD pipeline using GitHub Actions
- Containerized Go application with Docker
- Kubernetes deployments managed through Helm

##  Infrastructure Details

### VPC Configuration
- Production VPC (CIDR: 10.0.0.0/16)
  - Private subnets: 10.0.1.0/24, 10.0.2.0/24
  - Public subnets: 10.0.4.0/24, 10.0.5.0/24
  - Multiple NAT Gateways (one per AZ)

- Staging VPC (CIDR: 10.1.0.0/16)
  - Private subnets: 10.1.1.0/24, 10.1.2.0/24
  - Public subnets: 10.1.4.0/24, 10.1.5.0/24
  - Single NAT Gateway

### EKS Configuration
- Separate clusters for production and staging: `go-leaf-prod` and `go-leaf-staging`
- Public endpoint access enabled
- Managed node groups with configurable:
  - Instance types
  - Desired/min/max node counts
  - ON_DEMAND capacity type

##  CI/CD Pipeline

The project uses GitHub Actions for continuous integration and deployment:

### Triggers
- Push to `main` branch → Production deployment
- Push to `staging` branch → Staging deployment

### Pipeline Stages

1. **Build**
   - Sets up Go
   - Builds the application
   - Creates Docker image with format: `avashskya/go-leaf:<branch>-<commit-message>`
   - Pushes image to Docker Hub

2. **Deploy**
   - Configures AWS credentials
   - Updates kubeconfig for the appropriate environment
   - Installs Helm
   - Deploys/updates application using Helm chart

##  Setup Instructions

### 1. Infrastructure Deployment

```bash
# Initialize Terraform
terraform init

# Review changes
terraform plan

# Apply changes
terraform apply
```
__pwd.auto.tfvars used for storing AWS credentials, however passing the variables in the plan/apply command can be done as well__

### 2. Application Deployment
Push to the appropriate branch:
- `main` branch for production
- `staging` branch for staging environment

The GitHub Actions pipeline will automatically:
1. Build the application
2. Create and push a Docker image
3. Deploy to the appropriate EKS cluster

##  Infrastructure Outputs

The Terraform configuration provides these outputs:
- `cluster_endpoints`: EKS cluster API endpoints
- `cluster_security_group_ids`: Security group IDs for cluster control planes
- `cluster_iam_role_names`: IAM role names for clusters
