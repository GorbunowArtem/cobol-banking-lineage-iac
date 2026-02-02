# COBOL Banking Lineage Infrastructure as Code (IaC)

## 📖 Overview

This repository is a **Proof of Concept (PoC)** for automating COBOL banking application data lineage integration with OpenMetadata. It demonstrates how legacy COBOL systems can be integrated into modern data governance platforms, enabling comprehensive lineage tracking from mainframe databases to cloud analytics platforms.

### Purpose

This PoC serves as an infrastructure and automation layer for the COBOL Banking application lineage tracking, specifically focused on:

- **Legacy System Integration**: Bridging COBOL/mainframe data with modern data governance
- **Data Lineage Automation**: Tracking data flows from SQL Server source systems through transformation pipelines
- **CI/CD for Lineage**: Automated validation and deployment of lineage metadata
- **Proof of Concept**: Demonstrating feasibility of COBOL data lineage tracking in OpenMetadata

## 🏗️ Repository Structure

```text
cobol-banking-lineage-iac/
├── .cicd/                       # CI/CD pipeline configurations
│   ├── validate.yml             # CodeBuild buildspec for validation
│   └── scripts/                 # Pipeline automation scripts
│       ├── init.sh              # Environment initialization
│       ├── validate.sh          # PR validation script
│       └── deploy.sh            # Deployment script
├── connectors/                  # OpenMetadata connector configurations
│   └── s3/                      # S3 connector configurations (placeholder)
├── iac/                         # Infrastructure as Code (Terragrunt/Terraform)
│   └── (empty - reserved for future infrastructure)
├── .gitignore                   # Git ignore patterns
├── OPENMETADATA_INSTALL.md      # OpenMetadata installation guide
└── README.md                    # This file
```

## 🚀 Key Features

- **COBOL Data Lineage Support**: Designed for COBOL banking application data flows
- **CI/CD Pipeline**: Automated validation via AWS CodeBuild
- **OpenMetadata Integration**: Direct integration with OpenMetadata for lineage visualization
- **Connector Framework**: Structured approach to defining data source connectors (S3, databases, etc.)

## 📋 Prerequisites

- AWS Account with CodeBuild access
- OpenMetadata instance (see [OPENMETADATA_INSTALL.md](OPENMETADATA_INSTALL.md))
- Git repository with CI/CD webhook configuration
- Valid JWT token for OpenMetadata authentication (stored in AWS Parameter Store or local `jwt` file)

## 🔗 Related Projects

This PoC works in conjunction with the main COBOL Banking application:

- **[cobol-banking](https://github.com/your-org/cobol-banking)** - Main COBOL banking application with lineage extraction
- **[open-metadata-iac](https://github.com/your-org/open-metadata-iac)** - Full-featured OpenMetadata IaC repository with CSV-to-SDK processing tools

## 🛠️ Setup & Usage

### CI/CD Pipeline

The repository includes an AWS CodeBuild-based CI/CD pipeline configured via [.cicd/validate.yml](.cicd/validate.yml).

For local testing with the full toolset, clone the related repository:

```bash
git clone https://github.com/your-org/open-metadata-iac.git
cd open-metadata-iac
```

### 2. Set Up Python Environment

```bash
# Create virtual environment
python -m venv .venv

# Activate virtual environment
# Windows:
.venv\Scripts\activate
# Linux/macOS:
source .venv/bin/activate

# Install dependencies
pip install -r csv-to-sdk/requirements.txt
```

### 3. Configure Authentication

Create a `jwt` file in the root directory with your OpenMetadata JWT token:

```bash
echo "your-jwt-token-here" > jwt
```

## 📊 CSV Data Lineage Format

The system processes CSV files with the following columns:

| Column | Description | Example |
|--------|-------------|---------|
| `fromEntityFQN` | Source entity fully qualified name | `Postgres.database.schema.table` |
| `toEntityFQN` | Target entity fully qualified name | `Snowflake.warehouse.database.table` |
| `fromChildEntityFQN` | Source column/field FQN | `Postgres.database.schema.table.column_name` |
| `toChildEntityFQN` | Target column/field FQN | `Snowflake.warehouse.database.table.column_name` |
| `fromServiceType` | Source service type | `Postgres`, `Kafka`, `S3`, etc. |
| `toServiceType` | Target service type | `Snowflake`, `DynamoDB`, etc. |

### Supported Service Types

- **Postgres** - PostgreSQL databases
- **Snowflake** - Snowflake data warehouse
- **Kafka** - Apache Kafka topics
- **DynamoDB** - Amazon DynamoDB tables
- **S3** - Amazon S3 containers
- **CustomMessaging** - Custom messaging systems

## 🔄 Usage

### Column Lineage Verification & Fixing Tools

**NEW**: Three specialized scripts for validating and fixing column lineage issues:

#### 1. Verify Column Lineage

Validates that column mappings in CSV files exist in OpenMetadata and splits valid/invalid rows:

```bash
python verify_column_lineage.py <csv_file> --split-output [--verbose]
```

**Output:**

- `*-ready.csv` - Valid mappings that exist in OpenMetadata
- `*-issues.csv` - Invalid or missing column mappings

#### 2. Fix Column Lineage Issues

Automatically fixes common formatting issues (quotes, case, similar names):

```bash
python fix_column_lineage_issues.py <issues_csv> [--verbose] [--debug]
```

**Output:**

- `*-fixed.csv` - Successfully corrected rows
- `*-fixed-unfixable.csv` - Rows that couldn't be auto-fixed

#### 3. Analyze Unfixable Issues

Provides detailed analysis of why certain mappings can't be fixed:

```bash
python analyze_unfixable_lineage.py <unfixable_csv>
```

**Shows:** Missing fields, available fields, and actionable recommendations.

📖 **Full documentation:** See [COLUMN_LINEAGE_QUICKSTART.md](./COLUMN_LINEAGE_QUICKSTART.md) and [COLUMN_LINEAGE_WORKFLOW.md](./COLUMN_LINEAGE_WORKFLOW.md)

### Local Development

#### Dry Run (Validation)

```bash
python csv-to-sdk/csv-to-sdk.py --dry-run
```

This will:

- Validate all CSV files in `om-iac/` directory
- Check existing lineages in OpenMetadata
- Generate `lineage_summary.md` report
- Show what would be created/updated without making changes

#### Force Update

```bash
python csv-to-sdk/csv-to-sdk.py --force
```

This will:

- Process all lineages regardless of existing state
- Create new lineages and update existing ones
- Apply all changes to OpenMetadata

#### Standard Processing

```bash
python csv-to-sdk/csv-to-sdk.py
```

This will:

- Only create new lineages or update changed ones
- Skip lineages that already exist with same column mappings

### CI/CD Pipeline

The repository includes automated CI/CD workflows:

#### Pull Request Validation

- Triggers on PRs to `main` branch
- Runs dry-run validation
- Posts lineage summary as PR comment
- Validates CSV format and OpenMetadata connectivity

#### Main Branch Deployment

- Triggers on pushes to `main` branch
- Executes force update to apply all lineages
- Updates OpenMetadata with latest lineage data

#### Webhook Trigger for AWS CI/CD

A dedicated GitHub Actions workflow (`.github/workflows/rag-creator.yml`) is configured to trigger **only when code is pushed to the `main` branch** (typically after a PR is merged).
This workflow sets up or updates a webhook to notify the AWS CI/CD system via a configured endpoint:

```
https://your-webhook-endpoint.example.com/om-iac-change
```

**How it works:**

- The workflow runs automatically on every push to `main`.
- It checks if the webhook exists and creates or updates it as needed.
- The webhook is used for downstream automation in AWS CI/CD.

**Relevant file:**
`.github/workflows/rag-creator.yml`

## 🏗️ Infrastructure Management

### Terragrunt Configuration

The `iac/` directory contains Terragrunt configurations for AWS infrastructure:

```bash
# Navigate to specific environment
cd iac/resources/dev/codebuild/lineage-validate

# Plan infrastructure changes
terragrunt plan

# Apply infrastructure changes
terragrunt apply
```

### Environment Variables

Required environment variables for Terragrunt:

- `TF_DEPLOYMENT_BUCKET` - S3 bucket for Terraform state
- `ENVIRONMENT_NAME` - Environment identifier (e.g., dev, prod)
- `ENVIRONMENT_TYPE` - Environment type (e.g., dev, staging, prod)

## 📝 Example CSV Files

### Basic Table-to-Table Lineage

```csv
fromEntityFQN,toEntityFQN,fromChildEntityFQN,toChildEntityFQN,fromServiceType,toServiceType
Postgres.ecommerce.public.orders,Snowflake.analytics.staging.orders_fact,Postgres.ecommerce.public.orders.order_id,Snowflake.analytics.staging.orders_fact.order_id,Postgres,Snowflake
```

### Kafka Topic Lineage

```csv
fromEntityFQN,toEntityFQN,fromChildEntityFQN,toChildEntityFQN,fromServiceType,toServiceType
Kafka."events.orders.created",DynamoDB.order_events,Kafka."events.orders.created".payload.order_id,DynamoDB.order_events.order_id,Kafka,DynamoDB
```

## 🔧 Configuration

### OpenMetadata Connection

The script connects to OpenMetadata using:

- **Host**: `http://your-openmetadata-host.internal.example.com:8585/api`
- **Authentication**: JWT token from `jwt` file
- **SSL Verification**: Configurable based on environment

### File Processing

- **Source Directory**: `om-iac/` (configurable via `SCV_SOURCE_FOLDER`)
- **Recursive Processing**: Automatically finds all `.csv` files in subdirectories
- **Output Reports**: Generates `lineage_summary.md` for PR reviews

## 🐛 Debugging

### Debug Script

Use the debug utility for troubleshooting:

```bash
python csv-to-sdk/debug_lineage_check.py
```

### Common Issues

1. **JWT Token Expired**

   ```text
   Error: Authentication failed
   ```

   Solution: Update the `jwt` file with a fresh token

2. **Entity Not Found**

   ```text
   Warning: Could not find entities for [FQN] -> [FQN]
   ```

   Solution: Verify entity FQNs exist in OpenMetadata

3. **Column Mapping Errors**

   ```text
   Warning: Could not find column [column_fqn] in [table_fqn]
   ```

   Solution: Check column names and parent entity structure

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Add your CSV lineage files** to appropriate subdirectories in `om-iac/`
4. **Test locally**: Run `python csv-to-sdk/csv-to-sdk.py --dry-run`
5. **Commit changes**: `git commit -am 'Add new lineage mappings'`
6. **Push to branch**: `git push origin feature/your-feature-name`
7. **Create Pull Request**: The CI/CD pipeline will automatically validate your changes

### CSV File Guidelines

- Place CSV files in logical subdirectories under `om-iac/`
- Use descriptive filenames (e.g., `orders-to-analytics.csv`)
- Ensure all required columns are present
- Test with dry-run before submitting PR

## 📊 Monitoring & Reports

### PR Summary Reports

The pipeline generates detailed reports including:

- **New Lineages**: Count and details of lineages to be created
- **Updated Lineages**: Changes to existing lineage mappings
- **Unchanged Lineages**: Existing lineages that remain the same
- **Column Mappings**: Detailed source-to-target field mappings

### Example Report Output

```markdown
# 🔗 Data Lineage Changes Summary

## 📊 Overview
| Status | Count | Description |
|--------|-------|-------------|
| 🆕 New | 5 | New lineages to be created |
| 🔄 Update | 2 | Existing lineages to be updated |
| ⏭️ Skip | 8 | Existing lineages (no changes needed) |
```

## 📚 Additional Resources

- [OpenMetadata Documentation](https://docs.open-metadata.org/)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
- [AWS CodeBuild User Guide](https://docs.aws.amazon.com/codebuild/)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For questions or issues:

1. **Check existing issues** in the GitHub repository
2. **Create a new issue** with detailed description and logs
3. **Contact the team** for urgent infrastructure matters

## 🖥️ Install OpenMetadata (OM) server from scratch

This section shows a minimal, working way to install OpenMetadata on an EC2 instance (Amazon Linux / RHEL / CentOS family) using Docker Compose.

Recommended EC2: m6i.xlarge with GP3 100 GiB root volume (or larger), security group allowing inbound TCP 8585 (and any other ports you need).

1. Update and install Docker

```bash
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
# Log out/in (or reboot) so the group change takes effect
exit
```

2. Verify Docker

```bash
docker --version
docker ps
```

3. Install Docker Compose v2 CLI plugin (binary path used by Docker)

```bash
sudo mkdir -p /usr/libexec/docker/cli-plugins
sudo curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" -o /usr/libexec/docker/cli-plugins/docker-compose
sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose
sudo systemctl restart docker
docker compose version
```

4. Download OpenMetadata docker-compose and start

```bash
mkdir ~/openmetadata-docker && cd ~/openmetadata-docker
curl -sL -o docker-compose.yml https://github.com/open-metadata/OpenMetadata/releases/download/1.9.12-release/docker-compose.yml
docker compose -f docker-compose.yml up --detach
docker ps
```

5. Verify OM is running

- Check containers: docker ps
- Tail logs: docker compose -f docker-compose.yml logs -f
- Open UI: http://<EC2_PUBLIC_IP>:8585 (ensure security group and OS firewall allow port 8585)

6. Stopping / Removing

```bash
# stop and remove containers (preserves volumes by default)
docker compose -f docker-compose.yml down
# to remove volumes as well:
docker compose -f docker-compose.yml down --volumes
rm -rf ~/openmetadata-docker
```

Notes:

- The docker-compose.yml used above is for OpenMetadata 1.9.12; update the URL for other releases.
- For production deployments, use a managed database (Postgres), external storage, and configure environment variables in the compose file per OpenMetadata docs.
- Ensure proper IAM, security groups, and backup strategies for the EC2 instance and persistent volumes.

### 🔐 Credentials

- OpenMetadata JWT
  - The repository expects a `jwt` file in the project root containing a valid OpenMetadata JWT token (already documented above). Do NOT commit this file to the repository.
- Kafka / Confluent credentials
  - Kafka credentials used by related IaC are stored and managed in a separate repository or credential management system.
- **Kafka Production Credentials**:
   In production, retrieve the required credentials from AWS SSM Parameter Store at:
   `/infrastructure/prod/confluent/open-metadata-connector`

## Auto-start OpenMetadata on EC2 reboot

To ensure the OpenMetadata Docker stack starts automatically after an EC2 instance reboot, create a systemd service unit and enable it.

1. Create the unit file:

```bash
sudo vi /etc/systemd/system/om-ai.service
```

2. Paste the following content into `/etc/systemd/system/om-ai.service`:

```ini
[Unit]
Description=AI Agentic Open Metadata
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStartPre=/usr/bin/docker compose -f /home/ec2-user/openmetadata-docker/docker-compose.yml pull
ExecStart=/usr/bin/docker compose -f /home/ec2-user/openmetadata-docker/docker-compose.yml up --no-color
ExecStop=/usr/bin/docker compose -f /home/ec2-user/openmetadata-docker/docker-compose.yml down

[Install]
WantedBy=multi-user.target
```

3. Set permissions, reload systemd, enable and start the service:

```bash
sudo chmod 644 /etc/systemd/system/om-ai.service
sudo systemctl daemon-reload
sudo systemctl enable --now om-ai.service
```

4. Useful troubleshooting / status commands:

```bash
# Stop running containers (if needed)
docker compose -f /home/ec2-user/openmetadata-docker/docker-compose.yml down

# Check containers
docker ps

# Check service status
sudo systemctl status om-ai.service
```

Notes:

- Adjust the docker-compose file path if your compose file is located elsewhere.
- Ensure the `docker compose` binary path (`/usr/bin/docker compose`) matches your system; you may need `/usr/local/bin/docker-compose` or `docker-compose` depending on your setup.
- `Type=oneshot` + `RemainAfterExit=yes` is used to keep the unit active after the compose up command completes; change this if you prefer a long-running service type.

---

**Repository**: `your-org/cobol-banking-lineage-iac`
**Branch**: `main`
**Last Updated**: February 2026
