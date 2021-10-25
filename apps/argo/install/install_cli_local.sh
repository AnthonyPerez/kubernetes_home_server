# Copied directly from https://github.com/argoproj/argo-workflows/releases/tag/v3.1.14

# Download the binary - make sure to select the right version for your architecture
curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v3.1.14/argo-linux-arm64.gz

# Unzip
gunzip argo-linux-arm64.gz

# Make binary executable
chmod +x argo-linux-arm64

# Move binary to path
mv ./argo-linux-arm64 /usr/local/bin/argo

# Test installation
argo version
