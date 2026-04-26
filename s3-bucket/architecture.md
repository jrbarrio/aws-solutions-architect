# S3 Bucket Architecture

## Architecture Diagram

```mermaid
graph TB
    subgraph External["🌐 External Access"]
        User["👤 Whitelisted User<br/>IP: 176.83.52.247/32"]
    end

    subgraph AWS["☁️ AWS Account"]
        subgraph Security["🔒 Security Layer"]
            Policy["IAM Bucket Policy<br/>━━━━━━━━━━━━━━<br/>Condition: IpAddress<br/>Variable: aws:SourceIP<br/>Action: s3:GetObject<br/>Effect: Allow"]
        end

        subgraph Storage["📦 Storage Layer"]
            Bucket["S3 Bucket<br/>━━━━━━━━━━━━━━<br/>Name: jorge-roldan-solutions-<br/>architect-example-bucket<br/><br/>Tags:<br/>• Name: Dev<br/>• Project: Codely Course"]
            Object["📄 S3 Object<br/>━━━━━━━━━━━━━━<br/>Key: hello-world<br/>Source: hello-world.html<br/>Type: text/html"]
        end

        subgraph Backend["💾 Terraform Backend<br/>(State Management)"]
            StateS3["S3 State Bucket<br/>━━━━━━━━━━━━━━<br/>Bucket: aws-solutions-architect-<br/>tf-states<br/>Key: s3-bucket/terraform.tfstate<br/>Encryption: Enabled"]
            StateDDB["DynamoDB Lock Table<br/>━━━━━━━━━━━━━━<br/>Table: aws-solutions-architect-<br/>tf-states-locks"]
        end
    end

    User -->|"🔑 GetObject Request<br/>(HTTPS)"| Policy
    Policy -->|"✅ IP Validated"| Bucket
    Bucket -->|"contains"| Object
    Bucket -.->|"stores state"| StateS3
    Bucket -.->|"locks state"| StateDDB

    style User fill:#e1f5ff,stroke:#0066cc,stroke-width:3px
    style Policy fill:#ffcccc,stroke:#cc0000,stroke-width:3px
    style Bucket fill:#ff9900,stroke:#cc6600,stroke-width:4px,color:#000
    style Object fill:#ffcc99,stroke:#cc6600,stroke-width:2px
    style StateS3 fill:#d9d9d9,stroke:#666,stroke-width:2px
    style StateDDB fill:#d9d9d9,stroke:#666,stroke-width:2px
    style External fill:#f0f8ff,stroke:#0066cc,stroke-width:3px
    style Security fill:#fff0f0,stroke:#cc0000,stroke-width:3px
    style Storage fill:#fff5e6,stroke:#cc6600,stroke-width:3px
    style Backend fill:#f5f5f5,stroke:#666,stroke-width:3px
```

## Architecture Overview

This infrastructure demonstrates a simple S3 bucket with IP-based access control and remote state management.

### Components

#### 1. External Access Layer
- **User**: Whitelisted IP address (176.83.52.247/32)
- **Access Method**: HTTPS requests to S3
- **Permission**: Read-only (`s3:GetObject`)

#### 2. Security Layer
- **S3 Bucket Policy**: IAM policy attached to bucket
- **Condition**: Source IP must match whitelist
- **Principal**: `AWS: *` (public with IP restriction)
- **Action**: `s3:GetObject` only

#### 3. Storage Layer
- **S3 Bucket**: `jorge-roldan-solutions-architect-example-bucket`
  - Tags: `Name=Dev`, `Project=Codely Course`
- **Object**: `hello-world.html`
  - Key: `hello-world`
  - Content-Type: `text/html`

#### 4. Backend State Management
- **S3 State Bucket**: `aws-solutions-architect-tf-states`
  - Stores Terraform state files
  - State file: `s3-bucket/terraform.tfstate`
  - Encryption enabled
- **DynamoDB Lock Table**: `aws-solutions-architect-tf-states-locks`
  - Prevents concurrent state modifications
  - Ensures state consistency

## Request Flow

1. User from whitelisted IP (176.83.52.247/32) sends GetObject request
2. S3 Bucket Policy evaluates the request
3. Policy checks `aws:SourceIP` condition
4. If IP matches whitelist → Access granted ✅
5. If IP doesn't match → Access denied ❌
6. User retrieves `hello-world.html` object

## Security Model

**Access Control:**
- IP-based restriction (not authentication-based)
- Only specific CIDR block allowed: `176.83.52.247/32`
- Public bucket with restricted access via bucket policy

**Limitations:**
- No user authentication required
- IP spoofing possible (use VPN/proxy for additional security)
- Suitable for development/learning environments

**Best Practices Applied:**
- Read-only access (principle of least privilege)
- Explicit allow policy
- Remote state with locking

## Terraform Configuration

### Module Structure
```
s3-bucket/
├── main.tf              # Root configuration
├── provider.tf          # AWS/LocalStack provider
├── backend.tf           # Remote state configuration
├── variables.tf         # Input variables
├── terraform.tfvars     # Variable values
└── s3/
    ├── main.tf         # S3 module resources
    └── variables.tf    # Module variables
```

### Key Resources
- `aws_s3_bucket` - Main bucket
- `aws_s3_object` - hello-world.html file
- `aws_s3_bucket_policy` - IP whitelist policy
- `data.aws_iam_policy_document` - Policy definition

## LocalStack Configuration

When running locally with LocalStack:
- **Endpoint**: `http://s3.localhost.localstack.cloud:4566`
- **Region**: `us-east-1`
- **Credentials**: access_key=test, secret_key=test
- **Services**: S3, DynamoDB, IAM

## Related Files

- [Main Configuration](./main.tf)
- [S3 Module](./s3/main.tf)
- [Backend Config](./backend.tf)
- [Provider Setup](./provider.tf)
