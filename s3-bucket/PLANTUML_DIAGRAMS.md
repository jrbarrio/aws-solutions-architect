# PlantUML Architecture Diagrams

This folder contains PlantUML diagrams for the s3-bucket infrastructure. These diagrams are written as code and can be rendered in VSCode or any PlantUML-compatible viewer.

## 📊 Available Diagrams

### 1. **architecture.puml** - Infrastructure Diagram
Shows the complete AWS infrastructure with all components and their relationships.

**Components:**
- External user with whitelisted IP
- S3 Bucket Policy (security layer)
- S3 Bucket and Object (storage layer)
- Terraform backend (S3 + DynamoDB)

**Best for:** Understanding the overall architecture and security model.

### 2. **architecture-sequence.puml** - Request Flow
Shows the sequence of events when a user requests an object from S3.

**Flow:**
1. User sends GetObject request
2. Bucket Policy validates source IP
3. If valid → Object returned
4. If invalid → Access denied (403)

**Best for:** Understanding the request/response flow and access control logic.

### 3. **architecture-component.puml** - Terraform Module Structure
Shows how Terraform configuration files are organized and how they create AWS resources.

**Components:**
- Root module files (main.tf, variables.tf, etc.)
- Child s3 module
- AWS resources created
- Backend state management

**Best for:** Understanding the Terraform code organization.

## 🎨 How to View

### Option 1: VSCode with PlantUML Extension

1. Install the PlantUML extension:
   - Open VSCode
   - Go to Extensions (Ctrl+Shift+X)
   - Search for "PlantUML"
   - Install "PlantUML" by jebbs

2. Install Graphviz (required for rendering):
   ```bash
   # Ubuntu/Debian
   sudo apt-get install graphviz
   
   # macOS
   brew install graphviz
   
   # Arch Linux
   sudo pacman -S graphviz
   ```

3. Open any `.puml` file and press **Alt+D** to preview

### Option 2: Online Viewer

Copy the contents of any `.puml` file and paste into:
- **PlantUML Web Server**: http://www.plantuml.com/plantuml/uml/
- **PlantText**: https://www.planttext.com/

### Option 3: Generate PNG/SVG Files

```bash
# Install PlantUML
sudo apt install plantuml   # Ubuntu/Debian
brew install plantuml       # macOS

# Generate PNG
plantuml architecture.puml

# Generate SVG
plantuml -tsvg architecture.puml

# Generate all diagrams
plantuml *.puml
```

## 📁 Output Files

After running PlantUML, you'll get:
```
architecture.png
architecture-sequence.png
architecture-component.png
```

## 🔧 Troubleshooting

### "Cannot run program '/opt/local/bin/dot'"

**Problem:** Graphviz is not installed or not in PATH.

**Solution:**
```bash
# Install Graphviz
sudo apt-get install graphviz

# Verify installation
dot -V

# Restart VSCode
```

### Diagram doesn't render in VSCode

**Problem:** PlantUML extension needs Graphviz.

**Solution:**
1. Install Graphviz (see above)
2. Restart VSCode
3. Open `.puml` file
4. Press **Alt+D** or use Command Palette: "PlantUML: Preview Current Diagram"

### "Error: Cannot find Java"

**Problem:** PlantUML requires Java.

**Solution:**
```bash
# Install Java
sudo apt install default-jre  # Ubuntu/Debian
brew install openjdk          # macOS

# Verify
java -version
```

## 🎯 Diagram Features

### Color Coding
- **Light Pink/Rose** → Security components
- **Light Yellow** → Storage components  
- **Gray** → Backend/State management
- **Light Blue** → External users/actors

### Arrows
- **Solid arrows (→)** → Request flow / API calls
- **Dotted arrows (..>)** → State management / backend operations
- **Down arrows** → Contains / References

### Notes
- Additional context and configuration details
- IP addresses, tags, and settings
- Important security information

## 📝 Editing Diagrams

PlantUML uses a simple text-based syntax. To modify:

1. Open any `.puml` file in VSCode
2. Edit the text
3. Preview updates automatically (Alt+D)

### Common Elements

```plantuml
' Comments start with '

' Define actors
actor "User" as user

' Define components
rectangle "Component" as comp
storage "S3" as s3
database "DynamoDB" as db

' Arrows
user -> comp : Label
comp --> s3 : Another label
s3 .> db : Dotted arrow

' Notes
note right of user
  Additional information
end note

' Colors
rectangle "Name" as item #color
```

## 🆚 Comparison with Other Formats

| Format | Tool | Pros | Cons |
|--------|------|------|------|
| **PlantUML** | VSCode + Extension | Detailed, professional, text-based | Requires Graphviz |
| Mermaid | VSCode (native) | No dependencies, GitHub renders | Less detailed |
| Terravision | Docker | Automatic from Terraform | Complex setup |
| Python Diagrams | Python script | Programmable | Requires Python |

**Best Use Cases:**
- **PlantUML**: Documentation, detailed architecture diagrams, presentations
- **Mermaid**: Quick diagrams, version control friendly
- **Terravision**: Automatic generation after code changes

## 📚 Resources

- [PlantUML Official Site](https://plantuml.com/)
- [PlantUML Language Reference](https://plantuml.com/guide)
- [AWS Architecture Icons](https://aws.amazon.com/architecture/icons/)
- [VSCode PlantUML Extension](https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml)

## 🔄 Keeping Diagrams Updated

When you modify the Terraform configuration:

1. **Manual Update**: Edit the `.puml` files to reflect changes
2. **Automatic**: Use Terravision (see `TERRAVISION.md`)

For this project, PlantUML diagrams should be manually updated when:
- New resources are added
- Security policies change
- Module structure changes
- Backend configuration changes
