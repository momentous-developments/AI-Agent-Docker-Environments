#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🐳 Container Configuration Status${NC}"
echo "=================================="
echo ""

echo -e "${YELLOW}📋 Project Configuration:${NC}"
echo "Container Name: ${AGENT_NAME:-$(hostname)}"
echo "Google Cloud Project: $(gcloud config get-value project 2>/dev/null || echo 'Not set')"
echo "Firebase Project: $(firebase use 2>/dev/null | head -n1 || echo 'Not set')"
echo ""

echo -e "${YELLOW}🔐 Authentication Status:${NC}"

# Google Cloud Authentication
GCLOUD_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | head -n1)
if [ -n "$GCLOUD_ACCOUNT" ]; then
    echo -e "Google Cloud: ${GREEN}✓ $GCLOUD_ACCOUNT${NC}"
    
    # Test actual GCloud connectivity
    if gcloud projects describe $(gcloud config get-value project) &>/dev/null; then
        echo -e "  Project Access: ${GREEN}✓ $(gcloud config get-value project)${NC}"
    else
        echo -e "  Project Access: ${RED}❌ No access to project${NC}"
    fi
else
    echo -e "Google Cloud: ${RED}❌ Not authenticated${NC}"
fi

# Firebase Authentication  
if command -v firebase &>/dev/null; then
    if firebase projects:list &>/dev/null; then
        FIREBASE_PROJECT=$(firebase use 2>/dev/null | grep "Active Project" | cut -d' ' -f3 || echo "default")
        echo -e "Firebase: ${GREEN}✓ Connected (Project: $FIREBASE_PROJECT)${NC}"
        
        # Test Firebase project access
        if firebase projects:list | grep -q "$(gcloud config get-value project)"; then
            echo -e "  Project Match: ${GREEN}✓ Firebase project matches GCloud${NC}"
        else
            echo -e "  Project Match: ${YELLOW}⚠️  Firebase project differs from GCloud${NC}"
        fi
    else
        echo -e "Firebase: ${RED}❌ Not authenticated or no access${NC}"
    fi
else
    echo -e "Firebase: ${RED}❌ Firebase CLI not available${NC}"
fi

# GitHub Authentication
if gh auth status &>/dev/null; then
    GH_USER=$(gh api user --jq .login 2>/dev/null || echo "authenticated")
    echo -e "GitHub: ${GREEN}✓ $GH_USER${NC}"
    
    # Test repository access - check if we're in a git repo
    if [ -d .git ] && gh repo view &>/dev/null; then
        REPO_NAME=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "current repo")
        echo -e "  Repo Access: ${GREEN}✓ $REPO_NAME${NC}"
    elif gh api user/repos --limit 1 &>/dev/null; then
        echo -e "  Repo Access: ${GREEN}✓ Can access GitHub repos${NC}"
    else
        echo -e "  Repo Access: ${YELLOW}⚠️  No specific repo context${NC}"
    fi
else
    echo -e "GitHub: ${RED}❌ Not authenticated${NC}"
fi

# Claude API
if [ -n "$ANTHROPIC_API_KEY" ]; then
    echo -e "Claude API: ${GREEN}✓ Configured${NC}"
    
    # Test Claude Code availability
    if command -v claude &>/dev/null; then
        echo -e "  Claude Code: ${GREEN}✓ Available${NC}"
    else
        echo -e "  Claude Code: ${YELLOW}⚠️  CLI not found${NC}"
    fi
else
    echo -e "Claude API: ${YELLOW}⚠️  Not configured${NC}"
fi

# Service Account Key Validation
if [ -n "$GOOGLE_APPLICATION_CREDENTIALS" ] && [ -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    SERVICE_ACCOUNT=$(cat "$GOOGLE_APPLICATION_CREDENTIALS" | jq -r '.client_email' 2>/dev/null || echo "invalid")
    if [ "$SERVICE_ACCOUNT" != "invalid" ] && [ "$SERVICE_ACCOUNT" != "null" ]; then
        echo -e "Service Account: ${GREEN}✓ $SERVICE_ACCOUNT${NC}"
    else
        echo -e "Service Account: ${RED}❌ Invalid key file${NC}"
    fi
fi

echo ""
echo -e "${YELLOW}🌐 Network & Ports:${NC}"
echo "Web Server Port: ${WEB_PORT:-8080}"
echo "Host IP: $(hostname -I | awk '{print $1}' 2>/dev/null || echo 'N/A')"
echo ""

echo -e "${YELLOW}🛠️  Available Tools:${NC}"
echo "Flutter: $(flutter --version | head -n1)"
echo "Python: $(python3 --version)"
echo "Node.js: $(node --version 2>/dev/null || echo 'Not available')"
echo "Chrome: $(google-chrome --version 2>/dev/null || chromium --version 2>/dev/null || echo 'Not available')"
echo "Git: $(git --version)"
echo "Docker: $(docker --version 2>/dev/null || echo 'Not available')"
echo "Java: $(java -version 2>&1 | head -n1 | cut -d'"' -f2 || echo 'Not available')"
echo ""

echo -e "${YELLOW}🐍 Python Packages:${NC}"
python3 -c "
import sys
# Map package names to their import names
package_map = {
    'requests': 'requests',
    'beautifulsoup4': 'bs4',
    'Pillow': 'PIL',
    'pandas': 'pandas',
    'numpy': 'numpy',
    'lxml': 'lxml',
    'selenium': 'selenium'
}
for pkg_name, import_name in package_map.items():
    try:
        __import__(import_name)
        print(f'✓ {pkg_name}')
    except ImportError:
        print(f'✗ {pkg_name}')
" 2>/dev/null || echo "Error checking Python packages"
echo ""

echo -e "${YELLOW}🌐 NPM Global Tools:${NC}"
npm list -g --depth=0 2>/dev/null | grep -E "(lighthouse|puppeteer|playwright|firebase-tools|@anthropic-ai/claude-code)" | sed 's/.*── /✓ /' || echo "NPM tools not fully installed"
echo ""

echo -e "${BLUE}💡 This configuration is isolated to this container and won't affect your host system.${NC}"