#!/bin/bash

# Enhanced Authentication Setup Script
# Prioritizes service account authentication for containers

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔐 Setting up authentication for container environment...${NC}"

# Function to extract project ID from service account key
extract_project_from_key() {
    local key_file=$1
    if [ -f "$key_file" ]; then
        # Extract project_id from service account JSON
        project_id=$(cat "$key_file" | jq -r '.project_id // empty' 2>/dev/null)
        if [ -n "$project_id" ] && [ "$project_id" != "null" ]; then
            echo "$project_id"
            return 0
        fi
    fi
    return 1
}

# Function to setup Google Cloud authentication
setup_gcloud_auth() {
    echo -e "${YELLOW}Setting up Google Cloud authentication...${NC}"
    
    local auth_success=false
    local service_account_email=""
    local detected_project=""
    
    # Method 1: Service Account Key File (RECOMMENDED)
    # Check multiple possible locations for service account key
    local key_locations=(
        "$GOOGLE_APPLICATION_CREDENTIALS"
        "/home/developer/.gcloud/service-account-key.json"
        "/home/developer/service-account-key.json"
        "/workspace/.gcloud/service-account-key.json"
    )
    
    for key_file in "${key_locations[@]}"; do
        if [ -n "$key_file" ] && [ -f "$key_file" ]; then
            echo -e "${GREEN}✓ Found service account key at: $key_file${NC}"
            
            # Extract service account email and project
            service_account_email=$(cat "$key_file" | jq -r '.client_email // empty' 2>/dev/null)
            detected_project=$(extract_project_from_key "$key_file")
            
            if [ -n "$service_account_email" ] && [ "$service_account_email" != "null" ]; then
                # Activate service account
                gcloud auth activate-service-account "$service_account_email" --key-file="$key_file" --quiet
                
                # Set as application default credentials
                export GOOGLE_APPLICATION_CREDENTIALS="$key_file"
                
                # Also set up ADC by copying to the standard location
                mkdir -p /home/developer/.config/gcloud
                cp "$key_file" /home/developer/.config/gcloud/application_default_credentials.json
                
                echo -e "${GREEN}✓ Service account authenticated: $service_account_email${NC}"
                auth_success=true
                break
            else
                echo -e "${RED}✗ Invalid service account key file${NC}"
            fi
        fi
    done
    
    # Method 2: Host credentials (fallback only if no service account)
    if [ "$auth_success" = false ] && [ "$USE_HOST_GCLOUD_AUTH" = "true" ] && [ -d "/home/developer/host-gcloud-config" ]; then
        echo -e "${YELLOW}No service account found, checking host credentials...${NC}"
        
        # Copy host credentials
        mkdir -p /home/developer/.config/gcloud
        cp -r /home/developer/host-gcloud-config/* /home/developer/.config/gcloud/ 2>/dev/null || true
        
        # Check if credentials are valid without triggering refresh
        if gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | grep -q '@'; then
            echo -e "${GREEN}✓ Using existing host credentials${NC}"
            echo -e "${YELLOW}⚠️  Warning: Host credentials may expire. Service account recommended.${NC}"
            auth_success=true
            
            # Try to get project from existing config
            detected_project=$(gcloud config get-value project 2>/dev/null || echo "")
        else
            echo -e "${RED}✗ Host credentials not valid or expired${NC}"
        fi
    fi
    
    # Set project if we have one
    if [ -n "$GOOGLE_PROJECT_ID" ]; then
        # Use explicitly provided project ID
        echo -e "${BLUE}Using provided project ID: $GOOGLE_PROJECT_ID${NC}"
        gcloud config set project "$GOOGLE_PROJECT_ID" --quiet 2>/dev/null || true
    elif [ -n "$detected_project" ] && [ "$detected_project" != "null" ]; then
        # Use project ID from service account
        echo -e "${BLUE}Using project from service account: $detected_project${NC}"
        export GOOGLE_PROJECT_ID="$detected_project"
        gcloud config set project "$detected_project" --quiet 2>/dev/null || true
    fi
    
    # Final verification
    if [ "$auth_success" = true ]; then
        echo -e "${GREEN}✓ Google Cloud authentication configured${NC}"
        
        # Set additional environment variables for consistency
        if [ -n "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
            echo -e "${BLUE}ℹ️  Application Default Credentials: $GOOGLE_APPLICATION_CREDENTIALS${NC}"
        fi
        
        return 0
    else
        echo -e "${RED}✗ Google Cloud authentication failed${NC}"
        echo -e "${YELLOW}To fix this, mount a service account key to the container:${NC}"
        echo -e "${YELLOW}  1. Place your key file in ./auth/service-account-key.json${NC}"
        echo -e "${YELLOW}  2. Set GOOGLE_APPLICATION_CREDENTIALS in your .env file${NC}"
        return 1
    fi
}

# Function to setup Firebase authentication
setup_firebase_auth() {
    echo -e "${YELLOW}Setting up Firebase authentication...${NC}"
    
    # Firebase automatically uses Google Cloud credentials
    if [ -n "$GOOGLE_APPLICATION_CREDENTIALS" ] && [ -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
        echo -e "${GREEN}✓ Firebase will use service account credentials${NC}"
        
        # Set Firebase project if available
        if [ -n "$GOOGLE_PROJECT_ID" ]; then
            firebase use "$GOOGLE_PROJECT_ID" --add 2>/dev/null || \
            firebase use "$GOOGLE_PROJECT_ID" 2>/dev/null || true
            echo -e "${GREEN}✓ Firebase project set to: $GOOGLE_PROJECT_ID${NC}"
        fi
        
        return 0
    elif gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | grep -q '@'; then
        echo -e "${GREEN}✓ Firebase will use Google Cloud credentials${NC}"
        
        # Try to set Firebase project
        if [ -n "$GOOGLE_PROJECT_ID" ]; then
            firebase use "$GOOGLE_PROJECT_ID" 2>/dev/null || true
        fi
        
        return 0
    else
        echo -e "${YELLOW}⚠️  No Firebase authentication available${NC}"
        echo -e "${YELLOW}Firebase will use the same authentication as Google Cloud${NC}"
        return 1
    fi
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
            
            # Setup git credential helper
            gh auth setup-git 2>/dev/null || true
        else
            echo -e "${RED}✗ GitHub authentication failed${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠️  No GitHub token configured${NC}"
        echo "Set GITHUB_TOKEN in your .env file for GitHub access"
        return 1
    fi
    
    return 0
}

# Function to setup Git configuration
setup_git_config() {
    echo -e "${YELLOW}Setting up Git configuration...${NC}"
    
    # Remove any existing .gitconfig to avoid conflicts
    rm -f /home/developer/.gitconfig 2>/dev/null || true
    
    if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
        git config --global user.name "$GIT_USER_NAME"
        git config --global user.email "$GIT_USER_EMAIL"
        echo -e "${GREEN}✓ Git configured for: $GIT_USER_NAME <$GIT_USER_EMAIL>${NC}"
        
        # Set up credential helper for GitHub token
        if [ -n "$GITHUB_TOKEN" ]; then
            git config --global credential.helper store
            # Create credentials file with token
            mkdir -p /home/developer
            echo "https://oauth2:$GITHUB_TOKEN@github.com" > /home/developer/.git-credentials
            chmod 600 /home/developer/.git-credentials
            echo -e "${GREEN}✓ Git credentials configured${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Git user not configured${NC}"
        echo "Set GIT_USER_NAME and GIT_USER_EMAIL in your .env file"
    fi
    
    return 0
}

# Function to setup Claude authentication
setup_claude_auth() {
    echo -e "${YELLOW}Setting up Claude authentication...${NC}"
    
    if [ -n "$ANTHROPIC_API_KEY" ]; then
        echo -e "${GREEN}✓ Claude API key configured${NC}"
        # API key is used via environment variable
    else
        echo -e "${YELLOW}⚠️  No Claude API key configured${NC}"
        echo "Set ANTHROPIC_API_KEY in your .env file for Claude access"
    fi
    
    return 0
}

# Main authentication setup
main() {
    echo -e "${BLUE}🚀 Container Authentication Setup${NC}"
    echo -e "${BLUE}Container: ${AGENT_NAME:-unknown}${NC}"
    echo ""
    
    # Track authentication status
    local auth_summary=""
    
    # Setup each authentication method
    if setup_gcloud_auth; then
        auth_summary="${auth_summary}✓ Google Cloud "
    else
        auth_summary="${auth_summary}✗ Google Cloud "
    fi
    
    if setup_firebase_auth; then
        auth_summary="${auth_summary}✓ Firebase "
    else
        auth_summary="${auth_summary}✗ Firebase "
    fi
    
    if setup_github_auth; then
        auth_summary="${auth_summary}✓ GitHub "
    else
        auth_summary="${auth_summary}✗ GitHub "
    fi
    
    setup_git_config
    auth_summary="${auth_summary}✓ Git "
    
    setup_claude_auth
    if [ -n "$ANTHROPIC_API_KEY" ]; then
        auth_summary="${auth_summary}✓ Claude "
    else
        auth_summary="${auth_summary}✗ Claude "
    fi
    
    echo ""
    echo -e "${GREEN}🎉 Authentication setup complete!${NC}"
    echo -e "${BLUE}Status:${NC} $auth_summary"
    echo ""
    
    # Create status file for debugging
    cat > /home/developer/.auth-status << EOF
# Authentication Status
# Generated: $(date)
# Container: ${AGENT_NAME:-unknown}

GOOGLE_AUTH_METHOD=$([ -n "$GOOGLE_APPLICATION_CREDENTIALS" ] && echo "service-account" || echo "host-credentials")
GOOGLE_PROJECT=$GOOGLE_PROJECT_ID
GOOGLE_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | head -n1 || echo "none")
GITHUB_AUTH=$(gh auth status &>/dev/null && echo "authenticated" || echo "not-authenticated")
GIT_USER=$(git config --global user.name 2>/dev/null || echo "not-configured")
FIREBASE_PROJECT=$(firebase use 2>/dev/null | grep "Active Project" | cut -d' ' -f3 || echo "none")
CLAUDE_AUTH=$([ -n "$ANTHROPIC_API_KEY" ] && echo "configured" || echo "not-configured")
SERVICE_ACCOUNT_KEY=$GOOGLE_APPLICATION_CREDENTIALS
EOF
    
    echo -e "${BLUE}💡 Authentication details saved to: ~/.auth-status${NC}"
}

# Run main function
main