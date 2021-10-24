# Copied directly from https://github.com/argoproj/argo-workflows/releases/tag/v3.1.14

# Download the binary
curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v3.1.14/argo-linux-amd64.gz

# Unzip
gunzip argo-linux-amd64.gz

# Make binary executable
chmod +x argo-linux-amd64

# Move binary to path
mv ./argo-linux-amd64 /usr/local/bin/argo

# Test installation
argo version
