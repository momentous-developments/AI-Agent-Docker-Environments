#!/bin/bash

# Container Authentication Script
# This script runs on container startup to authenticate with GCP/Firebase

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🔐 Initializing GCP/Firebase Authentication...${NC}"

# Set project
export GOOGLE_PROJECT_ID="${GOOGLE_PROJECT_ID:-your-flutter-project-id}"
export CLOUDSDK_CORE_PROJECT="$GOOGLE_PROJECT_ID"

# Method 1: Check for mounted gcloud config (ADC)
if [ -d "/home/developer/.config/gcloud" ] && [ -f "/home/developer/.config/gcloud/application_default_credentials.json" ]; then
    echo -e "${GREEN}✓ Found Application Default Credentials${NC}"
    
    # Set the project
    gcloud config set project "$GOOGLE_PROJECT_ID" 2>/dev/null || true
    
    # Test authentication
    if gcloud auth list 2>/dev/null | grep -q "ACTIVE"; then
        echo -e "${GREEN}✓ Google Cloud authentication successful${NC}"
        
        # Configure Firebase to use the same project
        firebase use "$GOOGLE_PROJECT_ID" --add 2>/dev/null || firebase use "$GOOGLE_PROJECT_ID" 2>/dev/null || true
        
        echo -e "${GREEN}✓ Authentication complete!${NC}"
        echo -e "${GREEN}Project: $GOOGLE_PROJECT_ID${NC}"
        exit 0
    fi
fi

# Method 2: Check for service account key (if org policy allows)
if [ -f "/secrets/service-account-key.json" ]; then
    echo -e "${YELLOW}Found service account key${NC}"
    
    # Activate service account
    gcloud auth activate-service-account --key-file="/secrets/service-account-key.json"
    export GOOGLE_APPLICATION_CREDENTIALS="/secrets/service-account-key.json"
    
    # Set project
    gcloud config set project "$GOOGLE_PROJECT_ID"
    
    echo -e "${GREEN}✓ Service account authentication successful${NC}"
    exit 0
fi

# Method 3: Use host machine's gcloud auth (mounted)
if [ -d "/home/developer/host-gcloud-config" ]; then
    echo -e "${YELLOW}Using host machine's gcloud configuration${NC}"
    
    # Create gcloud config directory if it doesn't exist
    mkdir -p /home/developer/.config/gcloud
    
    # Copy host config to container's home
    cp -r /home/developer/host-gcloud-config/* /home/developer/.config/gcloud/ 2>/dev/null || true
    
    # Test authentication
    if gcloud auth list 2>/dev/null | grep -q "ACTIVE"; then
        echo -e "${GREEN}✓ Host authentication inherited successfully${NC}"
        gcloud config set project "$GOOGLE_PROJECT_ID"
        exit 0
    fi
fi

# No authentication found
echo -e "${RED}⚠️  No authentication credentials found!${NC}"
echo -e "${YELLOW}To authenticate this container, use one of these methods:${NC}"
echo ""
echo "1. Mount your gcloud config:"
echo "   docker run -v ~/.config/gcloud:/home/developer/.config/gcloud:ro ..."
echo ""
echo "2. Run interactive login inside container:"
echo "   gcloud auth login"
echo "   gcloud auth application-default login"
echo ""
echo -e "${YELLOW}Container is running without GCP/Firebase authentication${NC}"

# Don't fail - allow container to run
exit 0