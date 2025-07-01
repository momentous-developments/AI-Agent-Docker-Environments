#!/bin/bash

# Flutter Web Docker Container Start Script

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo -e "${RED}❌ .env file not found!${NC}"
    echo "Run ./setup.sh first to create your environment configuration"
    exit 1
fi

echo -e "${GREEN}🚀 Starting ${PROJECT_NAME:-Flutter Web} Development Container${NC}"
echo ""

# Check if container is already running
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME:-flutter-web-dev}$"; then
    echo -e "${YELLOW}⚠️  Container ${CONTAINER_NAME:-flutter-web-dev} is already running${NC}"
    echo ""
    echo "To access it:"
    echo -e "${BLUE}docker exec -it ${CONTAINER_NAME:-flutter-web-dev} zsh${NC}"
    exit 0
fi

# Check if image exists
if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^flutter-web-dev:latest$'; then
    echo -e "${GREEN}✓ Flutter development image already exists${NC}"
else
    echo -e "${YELLOW}🔨 Building Docker image...${NC}"
    docker-compose build
fi

# Start the container
echo -e "${GREEN}🐳 Starting new container...${NC}"
docker-compose up -d

# Wait for container to be ready
echo -e "${YELLOW}Waiting for container to initialize...${NC}"
sleep 5

# Show container status
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME:-flutter-web-dev}$"; then
    echo -e "${GREEN}✓ Container started successfully!${NC}"
    echo ""
    
    # Display container information
    echo -e "${GREEN}📋 Container Information:${NC}"
    echo "Name: ${CONTAINER_NAME:-flutter-web-dev}"
    echo "Workspace: ${WORKSPACE_MOUNT}"
    echo "Project: ${PROJECT_NAME}"
    echo "Web Port: ${WEB_PORT:-8080}"
    echo ""
    
    echo -e "${GREEN}🔧 Available Commands:${NC}"
    echo "Access container:  docker exec -it ${CONTAINER_NAME:-flutter-web-dev} zsh"
    echo "View logs:         docker logs ${CONTAINER_NAME:-flutter-web-dev}"
    echo "Stop container:    docker stop ${CONTAINER_NAME:-flutter-web-dev}"
    echo "Remove container:  docker rm -f ${CONTAINER_NAME:-flutter-web-dev}"
    echo ""
    
    echo -e "${GREEN}🎯 Next Steps:${NC}"
    echo "1. Access the container:"
    echo "   docker exec -it ${CONTAINER_NAME:-flutter-web-dev} zsh"
    echo ""
    echo "2. Navigate to your project:"
    echo "   cd /home/developer/workspace"
    echo ""
    echo "3. Run Flutter web app:"
    echo "   flutter run -d web-server --web-port=${WEB_PORT:-8080} --web-hostname=0.0.0.0"
    echo ""
    
    # Check authentication status
    echo -e "${GREEN}🔐 Authentication Status:${NC}"
    docker exec ${CONTAINER_NAME:-flutter-web-dev} bash -c "
        if gcloud auth list --filter=status:ACTIVE --format='value(account)' | grep -q @; then
            echo '✓ Google Cloud: Authenticated'
        else
            echo '❌ Google Cloud: Not authenticated'
        fi
        
        if gh auth status &>/dev/null; then
            echo '✓ GitHub: Authenticated'
        else
            echo '❌ GitHub: Not authenticated'
        fi
    " 2>/dev/null || echo "Authentication status check failed"
    
else
    echo -e "${RED}❌ Failed to start container${NC}"
    echo "Check logs with: docker-compose logs"
    exit 1
fi