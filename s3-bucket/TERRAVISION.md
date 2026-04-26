# Terravision - AWS Architecture Diagram

This document explains how to generate AWS architecture diagrams using Terravision, a tool that creates professional cloud architecture diagrams from Terraform code automatically.

## Generated Diagram

The file **`architecture-terravision.png`** contains an automatically generated AWS architecture diagram showing:
- S3 Bucket (`jorge-roldan-solutions-architect-example-bucket`)
- S3 Object (`hello-world.html`)  
- S3 Bucket Policy (IP-based access control)
- Resource relationships and dependencies

## About Terravision

- **GitHub**: https://github.com/patrickchugh/terravision
- **Features**: Automatic diagram generation from Terraform code
- **Supports**: AWS, Google Cloud, and Azure
- **Output Formats**: PNG, SVG, PDF, JPG, DrawIO
- **Requires**: Docker (no local installation needed)

## Prerequisites

- Docker installed and running
- Terraform configuration files
- LocalStack running (for this project) OR valid AWS credentials

## How to Regenerate the Diagram

### Step 1: Start LocalStack (if using local development)

```bash
cd ..
make start
```

### Step 2: Generate Terraform Plan

```bash
# Create temporary directory without backend configuration
mkdir -p terravision-temp
cp -r *.tf s3/ terraform.tfvars hello-world.html Makefile terravision-temp/
cd terravision-temp
rm -f backend.tf  # Remove S3 backend to use local state

# Initialize and create plan
terraform init -reconfigure
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
terraform graph > terraform.dot
```

### Step 3: Run Terravision

```bash
docker run --rm --network host \
  -v "$(pwd):/project" \
  -w /project \
  patrickchugh/terravision draw \
    --planfile /project/tfplan.json \
    --graphfile /project/terraform.dot \
    --source /project \
    --outfile architecture-terravision \
    --format png
```

### Step 4: Copy Generated Diagram

```bash
cp architecture-terravision-aws.dot.png ../architecture-terravision.png
cd ..
rm -rf terravision-temp
```

## Alternative: One-Liner Script

Save this as `generate-diagram.sh`:

```bash
#!/bin/bash
set -e

echo "🎨 Generating Terravision architecture diagram..."

# Create temp directory
mkdir -p terravision-temp
cp -r *.tf s3/ terraform.tfvars hello-world.html Makefile terravision-temp/ 2>/dev/null || true
cd terravision-temp
rm -f backend.tf

# Generate Terraform artifacts
echo "📝 Generating Terraform plan..."
terraform init -reconfigure -input=false > /dev/null
terraform plan -out=tfplan -input=false > /dev/null
terraform show -json tfplan > tfplan.json
terraform graph > terraform.dot

# Run Terravision
echo "🏗️  Running Terravision..."
docker run --rm --network host \
  -v "$(pwd):/project" \
  -w /project \
  patrickchugh/terravision draw \
    --planfile /project/tfplan.json \
    --graphfile /project/terraform.dot \
    --source /project \
    --outfile architecture-terravision \
    --format png

# Copy and cleanup
cp architecture-terravision-aws.dot.png ../architecture-terravision.png
cd ..
rm -rf terravision-temp

echo "✅ Diagram generated: architecture-terravision.png"
```

Usage:
```bash
chmod +x generate-diagram.sh
./generate-diagram.sh
```

## Terravision Options

### Output Formats

```bash
--format png      # PNG image (default)
--format svg      # SVG vector image
--format pdf      # PDF document
--format jpg      # JPEG image
--format drawio   # Draw.io format (editable)
```

### Simplified View

For high-level diagrams showing only services (not individual resources):

```bash
--simplified
```

### Custom Annotations

Add custom labels and descriptions:

```bash
--annotate annotations.yaml
```

Example `annotations.yaml`:
```yaml
resources:
  module.s3.aws_s3_bucket.example_bucket:
    label: "Main Storage Bucket"
    description: "Stores hello-world.html with IP-based access"
```

### AI-Generated Annotations

Use AI to generate annotations automatically:

```bash
--ai-annotate bedrock  # AWS Bedrock
--ai-annotate ollama   # Local Ollama
```

## Troubleshooting

### Issue: "No changes" error

**Problem**: Terraform detects no changes because infrastructure already exists.

**Solution**: Remove backend configuration and use local state:
```bash
rm backend.tf
terraform init -reconfigure
```

### Issue: LocalStack connection refused

**Problem**: LocalStack isn't running.

**Solution**:
```bash
cd ..
make start
sleep 10  # Wait for LocalStack to be ready
```

### Issue: Docker permission denied

**Problem**: User doesn't have Docker permissions.

**Solution**:
```bash
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

### Issue: Path spaces causing errors

**Problem**: Repository path contains spaces.

**Solution**: Use quoted paths in Docker commands:
```bash
docker run --rm -v "$(pwd):/project" ...
```

## Comparison with Manual Diagrams

This project includes multiple diagram formats:

| File | Tool | Pros | Cons |
|------|------|------|------|
| `architecture-terravision.png` | Terravision | Automatic, accurate, AWS icons | Requires Docker, complex setup |
| `architecture.md` | Mermaid | Easy to edit, version-friendly | Manual updates needed |
| `architecture.puml` | PlantUML | Detailed control | Requires Graphviz |
| `architecture_diagram.py` | Python Diagrams | Programmable | Requires Python deps |

**Recommendation**: Use Terravision for automatic generation after major infrastructure changes, and Mermaid for quick manual diagrams during development.

## Resources

- [Terravision GitHub](https://github.com/patrickchugh/terravision)
- [Terravision Documentation](https://github.com/patrickchugh/terravision/blob/main/README.md)
- [Docker Hub - Terravision](https://hub.docker.com/r/patrickchugh/terravision)
