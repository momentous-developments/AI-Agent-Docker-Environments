#!/bin/bash

# Flutter Web Docker Environment Setup Script
# This script helps users set up their environment for the first time

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Flutter Web Docker Environment Setup${NC}"
echo "========================================"
echo ""

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check for Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed. Please install Docker Compose first.${NC}"
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}📋 Creating .env file from template...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ Created .env file${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Please edit .env file with your configuration:${NC}"
    echo "   - Set your PROJECT_NAME"
    echo "   - Add your GITHUB_TOKEN"
    echo "   - Configure Google Cloud authentication"
    echo "   - Set your WORKSPACE_MOUNT path"
    echo ""
    echo -e "${YELLOW}Then run ./start.sh to start the container${NC}"
    exit 0
fi

# Create auth directory for service account (always create it)
if [ ! -d "auth" ]; then
    echo -e "${YELLOW}📁 Creating auth directory for service account keys...${NC}"
    mkdir -p auth
    echo -e "${GREEN}✓ Created auth directory${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps for authentication:${NC}"
    echo "1. Download service account key from Google Cloud Console"
    echo "2. Save it as: ./auth/service-account-key.json"
    echo "3. The container will automatically use this key"
    echo ""
    echo "See SERVICE_ACCOUNT_SETUP.md for detailed instructions"
fi

# Add auth directory to .gitignore if not already there
if [ -f .gitignore ] && ! grep -q "^auth/$" .gitignore; then
    echo "auth/" >> .gitignore
    echo -e "${GREEN}✓ Added auth/ to .gitignore${NC}"
fi

# Check gcloud installation for host auth
if [ "$USE_HOST_GCLOUD_AUTH" = "true" ]; then
    if ! command -v gcloud &> /dev/null; then
        echo -e "${YELLOW}⚠️  gcloud CLI not found on host${NC}"
        echo "For host authentication, install gcloud CLI:"
        echo "Visit: https://cloud.google.com/sdk/docs/install"
    else
        echo -e "${GREEN}✓ gcloud CLI found${NC}"
        # Check if user is authenticated
        if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q @; then
            echo -e "${YELLOW}⚠️  No active gcloud authentication found${NC}"
            echo "Run: gcloud auth login"
        else
            echo -e "${GREEN}✓ gcloud authenticated${NC}"
        fi
    fi
fi

# Build the Docker image
echo ""
echo -e "${GREEN}🔨 Building Docker image...${NC}"
docker-compose build

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Edit .env file with your configuration (if not already done)"
echo "2. Run ./start.sh to start the container"
echo "3. Access the container with: docker exec -it ${CONTAINER_NAME:-flutter-web-dev} zsh"