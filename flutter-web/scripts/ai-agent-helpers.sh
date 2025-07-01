#!/bin/bash

# AI Agent Helper Functions for Autonomous Development
# These commands make it easier for AI agents to work with Flutter web apps

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function to check project health
check_project() {
    echo -e "${YELLOW}🔍 Checking project health...${NC}"
    
    # Check Flutter
    flutter doctor -v
    
    # Check dependencies
    echo -e "\n${YELLOW}📦 Checking dependencies...${NC}"
    flutter pub outdated
    
    # Check for issues
    echo -e "\n${YELLOW}🔍 Analyzing code...${NC}"
    flutter analyze
    
    # Check tests
    echo -e "\n${YELLOW}🧪 Running tests...${NC}"
    flutter test || echo -e "${YELLOW}No tests found${NC}"
}

# Function to build and serve web
serve_web() {
    local PORT=${1:-8080}
    echo -e "${GREEN}🌐 Starting Flutter web server on port $PORT...${NC}"
    flutter run -d web-server --web-port=$PORT --web-hostname=0.0.0.0
}

# Function to build for production
build_production() {
    echo -e "${GREEN}🏗️ Building for production...${NC}"
    flutter build web --release --web-renderer html
    echo -e "${GREEN}✓ Build complete! Output in build/web/${NC}"
}

# Function to deploy to Firebase
deploy_firebase() {
    echo -e "${GREEN}🚀 Deploying to Firebase Hosting...${NC}"
    
    # Check if firebase.json exists
    if [ ! -f "firebase.json" ]; then
        echo -e "${YELLOW}Initializing Firebase...${NC}"
        firebase init hosting --project ${GOOGLE_PROJECT_ID:-your-flutter-project-id}
    fi
    
    # Build and deploy
    flutter build web --release
    firebase deploy --only hosting --project ${GOOGLE_PROJECT_ID:-your-flutter-project-id}
}

# Function to create a new feature
create_feature() {
    local FEATURE_NAME=$1
    if [ -z "$FEATURE_NAME" ]; then
        echo -e "${RED}Please provide a feature name${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✨ Creating feature: $FEATURE_NAME${NC}"
    
    # Create feature directory structure
    mkdir -p lib/features/$FEATURE_NAME/{widgets,screens,models,services}
    
    # Create index file
    echo "// Feature: $FEATURE_NAME" > lib/features/$FEATURE_NAME/${FEATURE_NAME}.dart
    
    echo -e "${GREEN}✓ Feature structure created${NC}"
}

# Function to run quick fix
quick_fix() {
    echo -e "${GREEN}🔧 Running quick fixes...${NC}"
    
    # Format code
    dart format .
    
    # Apply fixes
    dart fix --apply
    
    # Analyze
    flutter analyze
}

# Function to generate test coverage
test_coverage() {
    echo -e "${GREEN}📊 Generating test coverage...${NC}"
    flutter test --coverage
    
    # Generate HTML report if lcov is installed
    if command -v lcov &> /dev/null; then
        genhtml coverage/lcov.info -o coverage/html
        echo -e "${GREEN}✓ Coverage report generated in coverage/html/${NC}"
    fi
}

# Main command handler
case "$1" in
    check)
        check_project
        ;;
    serve)
        serve_web $2
        ;;
    build)
        build_production
        ;;
    deploy)
        deploy_firebase
        ;;
    feature)
        create_feature $2
        ;;
    fix)
        quick_fix
        ;;
    coverage)
        test_coverage
        ;;
    *)
        echo -e "${BLUE}AI Agent Flutter Web Helper${NC}"
        echo ""
        echo "Commands:"
        echo "  check      - Check project health"
        echo "  serve [port] - Start web server (default: 8080)"
        echo "  build      - Build for production"
        echo "  deploy     - Deploy to Firebase"
        echo "  feature <name> - Create new feature"
        echo "  fix        - Run quick fixes"
        echo "  coverage   - Generate test coverage"
        ;;
esac