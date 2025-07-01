#!/bin/bash

# Enhanced Authentication Setup Script
# This script runs on container startup and configures all authentication

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔐 Setting up authentication for AI agents...${NC}"

# Function to setup Google Cloud authentication
setup_gcloud_auth() {
    echo -e "${YELLOW}Setting up Google Cloud authentication...${NC}"
    
    # Method 1: Service Account Key File (RECOMMENDED for containers)
    if [ -n "$GOOGLE_APPLICATION_CREDENTIALS" ] && [ -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
        echo -e "${GREEN}✓ Using service account key file${NC}"
        gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
        export GOOGLE_APPLICATION_CREDENTIALS="$GOOGLE_APPLICATION_CREDENTIALS"
        
    # Method 2: Host gcloud credentials (fallback)
    elif [ "$USE_HOST_GCLOUD_AUTH" = "true" ] && [ -d "/home/developer/host-gcloud-config" ]; then
        echo -e "${GREEN}✓ Using host gcloud credentials${NC}"
        cp -r /home/developer/host-gcloud-config/* /home/developer/.config/gcloud/ 2>/dev/null || true
        
        # Set project from service account if not already set
        if [ -z "$GOOGLE_PROJECT_ID" ]; then
            GOOGLE_PROJECT_ID=$(gcloud config get-value project 2>/dev/null || echo "")
        fi
        
    # Method 2: Host gcloud credentials (ADC)
    elif [ "$USE_HOST_GCLOUD_AUTH" = "true" ] && [ -d "/home/developer/host-gcloud-config" ]; then
        echo -e "${GREEN}✓ Using host gcloud credentials${NC}"
        cp -r /home/developer/host-gcloud-config/* /home/developer/.config/gcloud/ 2>/dev/null || true
        
    # Method 3: Check for mounted service account in container
    elif [ -f "/home/developer/service-account-key.json" ]; then
        echo -e "${GREEN}✓ Using mounted service account key${NC}"
        gcloud auth activate-service-account --key-file="/home/developer/service-account-key.json"
        export GOOGLE_APPLICATION_CREDENTIALS="/home/developer/service-account-key.json"
        
    else
        echo -e "${YELLOW}⚠️  No Google Cloud authentication configured${NC}"
        echo "AI agents will need to authenticate manually with 'gcloud auth login'"
        return 1
    fi
    
    # Set project (container-specific, doesn't affect host)
    if [ -n "$GOOGLE_PROJECT_ID" ]; then
        gcloud config set project "$GOOGLE_PROJECT_ID"
        echo -e "${GREEN}✓ Container project set to: $GOOGLE_PROJECT_ID${NC}"
        echo -e "${BLUE}ℹ️  This setting is isolated to this container${NC}"
    fi
    
    # Verify authentication
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q '@'; then
        echo -e "${GREEN}✓ Google Cloud authentication successful${NC}"
        return 0
    else
        echo -e "${RED}✗ Google Cloud authentication failed${NC}"
        return 1
    fi
}

# Function to setup Firebase authentication
setup_firebase_auth() {
    echo -e "${YELLOW}Setting up Firebase authentication...${NC}"
    
    # Firebase uses the same Google Cloud credentials
    if [ -n "$FIREBASE_TOKEN" ]; then
        echo -e "${GREEN}✓ Using Firebase CI token${NC}"
        export FIREBASE_TOKEN="$FIREBASE_TOKEN"
        firebase login:ci --token "$FIREBASE_TOKEN" 2>/dev/null || true
        
    elif gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q '@'; then
        echo -e "${GREEN}✓ Firebase will use Google Cloud credentials${NC}"
        # Firebase CLI automatically uses gcloud credentials
        
    else
        echo -e "${YELLOW}⚠️  No Firebase authentication configured${NC}"
        echo "AI agents will need to authenticate manually with 'firebase login'"
        return 1
    fi
    
    # Set Firebase project (container-specific)
    if [ -n "$GOOGLE_PROJECT_ID" ]; then
        firebase use "$GOOGLE_PROJECT_ID" --token "$FIREBASE_TOKEN" 2>/dev/null || \
        firebase use "$GOOGLE_PROJECT_ID" 2>/dev/null || true
        echo -e "${GREEN}✓ Firebase project set to: $GOOGLE_PROJECT_ID${NC}"
        echo -e "${BLUE}ℹ️  Firebase config is isolated to this container${NC}"
    fi
    
    return 0
}

# Function to setup GitHub authentication
setup_github_auth() {
    echo -e "${YELLOW}Setting up GitHub authentication...${NC}"
    
    if [ -n "$GITHUB_TOKEN" ]; then
        echo -e "${GREEN}✓ Using GitHub token${NC}"
        echo "$GITHUB_TOKEN" | gh auth login --with-token
        
        # Verify authentication
        if gh auth status &>/dev/null; then
            echo -e "${GREEN}✓ GitHub authentication successful${NC}"
        else
            echo -e "${RED}✗ GitHub authentication failed${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠️  No GitHub token configured${NC}"
        echo "AI agents will need to authenticate manually with 'gh auth login'"
        return 1
    fi
    
    return 0
}

# Function to setup Git configuration
setup_git_config() {
    echo -e "${YELLOW}Setting up Git configuration...${NC}"
    
    # Always create a fresh .gitconfig in the container
    rm -f /home/developer/.gitconfig 2>/dev/null || true
    touch /home/developer/.gitconfig
    
    if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
        git config --global user.name "$GIT_USER_NAME"
        git config --global user.email "$GIT_USER_EMAIL"
        echo -e "${GREEN}✓ Git configured for: $GIT_USER_NAME <$GIT_USER_EMAIL>${NC}"
        
        # Set up credential helper to use GitHub token if available
        if [ -n "$GITHUB_TOKEN" ]; then
            git config --global credential.helper store
            echo "https://oauth2:$GITHUB_TOKEN@github.com" > ~/.git-credentials
            echo -e "${GREEN}✓ Git credentials configured for GitHub${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Git user configuration not provided${NC}"
        echo "AI agents can still use git but commits may need manual configuration"
    fi
    
    return 0
}

# Function to setup Claude authentication
setup_claude_auth() {
    echo -e "${YELLOW}Setting up Claude authentication...${NC}"
    
    if [ -n "$ANTHROPIC_API_KEY" ]; then
        echo -e "${GREEN}✓ Claude API key configured${NC}"
        # The API key is already set as environment variable
        # Claude Code will pick it up automatically
    else
        echo -e "${YELLOW}⚠️  No Claude API key configured${NC}"
        echo "AI agents will need to authenticate manually with 'claude login'"
    fi
    
    return 0
}

# Function to setup Docker registry authentication
setup_docker_auth() {
    if [ -n "$DOCKER_USERNAME" ] && [ -n "$DOCKER_PASSWORD" ]; then
        echo -e "${YELLOW}Setting up Docker registry authentication...${NC}"
        echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin
        echo -e "${GREEN}✓ Docker registry authentication configured${NC}"
    fi
    
    return 0
}

# Main authentication setup
main() {
    echo -e "${BLUE}🚀 Starting authentication setup for agent: ${AGENT_NAME:-unknown}${NC}"
    echo ""
    
    # Track authentication status
    AUTH_SUMMARY=""
    
    # Setup each authentication method
    if setup_gcloud_auth; then
        AUTH_SUMMARY="${AUTH_SUMMARY}✓ Google Cloud "
    fi
    
    if setup_firebase_auth; then
        AUTH_SUMMARY="${AUTH_SUMMARY}✓ Firebase "
    fi
    
    if setup_github_auth; then
        AUTH_SUMMARY="${AUTH_SUMMARY}✓ GitHub "
    fi
    
    setup_git_config
    AUTH_SUMMARY="${AUTH_SUMMARY}✓ Git "
    
    setup_claude_auth
    if [ -n "$ANTHROPIC_API_KEY" ]; then
        AUTH_SUMMARY="${AUTH_SUMMARY}✓ Claude "
    fi
    
    setup_docker_auth
    if [ -n "$DOCKER_USERNAME" ]; then
        AUTH_SUMMARY="${AUTH_SUMMARY}✓ Docker "
    fi
    
    echo ""
    echo -e "${GREEN}🎉 Authentication setup complete!${NC}"
    echo -e "${BLUE}Configured services:${NC} $AUTH_SUMMARY"
    echo ""
    
    # Create authentication status file for AI agents
    cat > /home/developer/.auth-status << EOF
# Authentication Status for AI Agents
# Generated: $(date)

GCLOUD_AUTH=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 | sed 's/@.*//' || echo "not-configured")
GITHUB_AUTH=$(gh auth status &>/dev/null && echo "configured" || echo "not-configured")
GIT_USER=$(git config --global user.name || echo "not-configured")
FIREBASE_AUTH=$(firebase projects:list &>/dev/null && echo "configured" || echo "not-configured")
CLAUDE_AUTH=$([ -n "$ANTHROPIC_API_KEY" ] && echo "configured" || echo "not-configured")
DOCKER_AUTH=$(docker info &>/dev/null && echo "configured" || echo "not-configured")
EOF
    
    echo -e "${BLUE}💡 AI agents can check authentication status at: ~/.auth-status${NC}"
}

# Run main function
main