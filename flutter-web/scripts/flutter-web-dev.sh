#!/bin/bash

# Flutter Web Development Automation Script
# Designed for AI agents to execute common tasks

set -e

# Project settings - Use current working directory if in a Flutter project, otherwise workspace
if [ -f "pubspec.yaml" ]; then
    PROJECT_DIR="$(pwd)"
else
    PROJECT_DIR="/home/developer/workspace"
fi
BUILD_DIR="build/web"
PORT="${WEB_PORT:-8080}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Ensure we're in the project directory
cd "$PROJECT_DIR" || exit 1

# Function to check if Flutter web is properly configured
check_web_setup() {
    echo -e "${BLUE}Checking Flutter web setup...${NC}"
    
    # Check if web is enabled
    if ! flutter config | grep -q "enable-web: true"; then
        echo -e "${YELLOW}Enabling Flutter web...${NC}"
        flutter config --enable-web
    fi
    
    # Check Chrome availability
    if command -v chromium-browser &> /dev/null; then
        export CHROME_EXECUTABLE=chromium-browser
        echo -e "${GREEN}✓ Chrome found${NC}"
    else
        echo -e "${RED}✗ Chrome not found${NC}"
    fi
    
    echo -e "${GREEN}✓ Flutter web is ready${NC}"
}

# Function to install/update dependencies
update_deps() {
    echo -e "${BLUE}Updating dependencies...${NC}"
    flutter pub get
    flutter pub upgrade --major-versions
    echo -e "${GREEN}✓ Dependencies updated${NC}"
}

# Function to run automated tests
run_tests() {
    echo -e "${BLUE}Running tests...${NC}"
    
    # Unit tests
    if [ -d "test" ] && [ "$(ls -A test/*.dart 2>/dev/null)" ]; then
        flutter test
    else
        echo -e "${YELLOW}No unit tests found${NC}"
    fi
    
    # Widget tests
    if [ -f "test/widget_test.dart" ]; then
        flutter test test/widget_test.dart
    fi
    
    echo -e "${GREEN}✓ Tests complete${NC}"
}

# Function to analyze code quality
analyze_code() {
    echo -e "${BLUE}Analyzing code quality...${NC}"
    
    # Format check
    dart format --set-exit-if-changed . || {
        echo -e "${YELLOW}Formatting issues found. Fixing...${NC}"
        dart format .
    }
    
    # Lint check
    flutter analyze --no-fatal-infos
    
    # Apply fixes
    dart fix --dry-run
    
    echo -e "${GREEN}✓ Code analysis complete${NC}"
}

# Function to build for different web renderers
build_web() {
    local RENDERER=${1:-html}
    echo -e "${BLUE}Building web app with $RENDERER renderer...${NC}"
    
    flutter build web --release --web-renderer $RENDERER
    
    # Optimize images if tools are available
    if command -v optipng &> /dev/null; then
        echo -e "${YELLOW}Optimizing PNG images...${NC}"
        find $BUILD_DIR -name "*.png" -exec optipng -o5 {} \;
    fi
    
    if command -v jpegoptim &> /dev/null; then
        echo -e "${YELLOW}Optimizing JPEG images...${NC}"
        find $BUILD_DIR -name "*.jpg" -o -name "*.jpeg" -exec jpegoptim {} \;
    fi
    
    echo -e "${GREEN}✓ Build complete in $BUILD_DIR${NC}"
}

# Function to serve the web app
serve_dev() {
    echo -e "${BLUE}Starting development server on port $PORT...${NC}"
    flutter run -d web-server --web-port=$PORT --web-hostname=0.0.0.0
}

# Function to serve production build
serve_prod() {
    echo -e "${BLUE}Serving production build on port $PORT...${NC}"
    
    if [ ! -d "$BUILD_DIR" ]; then
        echo -e "${YELLOW}No build found. Building first...${NC}"
        build_web
    fi
    
    cd $BUILD_DIR
    http-server -p $PORT -a 0.0.0.0 -c-1
}

# Function to run Lighthouse audit
audit_performance() {
    echo -e "${BLUE}Running Lighthouse audit...${NC}"
    
    # Start server in background
    http-server $BUILD_DIR -p 8090 &
    SERVER_PID=$!
    
    sleep 3
    
    # Run Lighthouse
    lighthouse http://localhost:8090 \
        --output=json \
        --output-path=./lighthouse-report.json \
        --chrome-flags="--headless --no-sandbox"
    
    # Kill server
    kill $SERVER_PID
    
    # Parse results
    if [ -f "lighthouse-report.json" ]; then
        SCORE=$(jq '.categories.performance.score * 100' lighthouse-report.json)
        echo -e "${GREEN}Performance Score: ${SCORE}%${NC}"
    fi
}

# Function to create Firebase hosting config
setup_firebase_hosting() {
    echo -e "${BLUE}Setting up Firebase Hosting...${NC}"
    
    if [ ! -f "firebase.json" ]; then
        cat > firebase.json << EOF
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(eot|otf|ttf|ttc|woff|font.css)",
        "headers": [
          {
            "key": "Access-Control-Allow-Origin",
            "value": "*"
          }
        ]
      },
      {
        "source": "**/*.@(jpg|jpeg|gif|png|svg|webp|js|css|eot|otf|ttf|ttc|woff|woff2|font.css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=604800"
          }
        ]
      }
    ]
  }
}
EOF
        echo -e "${GREEN}✓ Firebase hosting configured${NC}"
    else
        echo -e "${YELLOW}Firebase already configured${NC}"
    fi
}

# Function to deploy to Firebase
deploy() {
    echo -e "${BLUE}Deploying to Firebase...${NC}"
    
    # Ensure we have a build
    if [ ! -d "$BUILD_DIR" ]; then
        build_web
    fi
    
    # Setup Firebase if needed
    setup_firebase_hosting
    
    # Deploy
    firebase deploy --only hosting --project ${GOOGLE_PROJECT_ID:-your-flutter-project-id}
}

# Main menu
case "$1" in
    setup)
        check_web_setup
        ;;
    deps)
        update_deps
        ;;
    test)
        run_tests
        ;;
    analyze)
        analyze_code
        ;;
    build)
        build_web ${2:-html}
        ;;
    serve)
        serve_dev
        ;;
    serve-prod)
        serve_prod
        ;;
    audit)
        audit_performance
        ;;
    deploy)
        deploy
        ;;
    all)
        check_web_setup
        update_deps
        analyze_code
        run_tests
        build_web
        ;;
    *)
        echo -e "${BLUE}Flutter Web Development Helper${NC}"
        echo ""
        echo "Usage: $0 [command] [options]"
        echo ""
        echo "Commands:"
        echo "  setup      - Check and setup Flutter web"
        echo "  deps       - Update dependencies"
        echo "  test       - Run all tests"
        echo "  analyze    - Analyze code quality"
        echo "  build [renderer] - Build web app (html/canvaskit)"
        echo "  serve      - Run development server"
        echo "  serve-prod - Serve production build"
        echo "  audit      - Run performance audit"
        echo "  deploy     - Deploy to Firebase"
        echo "  all        - Run all checks and build"
        ;;
esac