#!/bin/bash

# Firebase Setup Helper for Flutter Apps
# This script helps set up Firebase configuration

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📱 Firebase Configuration Helper${NC}"
echo -e "${YELLOW}Project: ${GOOGLE_PROJECT_ID:-your-flutter-project-id}${NC}"
echo ""

# Check if we're in a Flutter project
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${YELLOW}Please run this script from your Flutter project root${NC}"
    exit 1
fi

PROJECT_NAME=$(grep "^name:" pubspec.yaml | cut -d' ' -f2)
echo -e "${GREEN}Flutter App: $PROJECT_NAME${NC}"

# Get package name from Android manifest
PACKAGE_NAME="com.example.flutter_starter_app"
if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
    PACKAGE_NAME=$(grep -o 'package="[^"]*"' android/app/src/main/AndroidManifest.xml | cut -d'"' -f2) || PACKAGE_NAME="com.example.flutter_starter_app"
fi

echo -e "${GREEN}Android Package: $PACKAGE_NAME${NC}"
echo ""

echo -e "${YELLOW}To get your google-services.json file:${NC}"
echo ""
echo "1. Go to: https://console.firebase.google.com/project/flutter-material3-starter/settings/general"
echo ""
echo "2. Under 'Your apps', look for your Android app"
echo "   - If you don't see one, click 'Add app' > 'Android'"
echo "   - Use package name: ${GREEN}$PACKAGE_NAME${NC}"
echo ""
echo "3. Download google-services.json"
echo ""
echo "4. Place it in: ${GREEN}android/app/google-services.json${NC}"
echo ""

# Check if file exists
if [ -f "android/app/google-services.json" ]; then
    echo -e "${GREEN}✓ google-services.json found!${NC}"
    echo ""
    echo "Verifying configuration..."
    
    # Extract project ID from the file
    PROJECT_ID=$(grep '"project_id"' android/app/google-services.json | cut -d'"' -f4)
    if [ "$PROJECT_ID" = "${GOOGLE_PROJECT_ID:-your-flutter-project-id}" ]; then
        echo -e "${GREEN}✓ Correct project configured!${NC}"
    else
        echo -e "${YELLOW}⚠️  Project mismatch. Found: $PROJECT_ID${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  google-services.json not found${NC}"
    echo ""
    echo "Would you like me to create a template? (You'll still need to download the real one)"
    echo "Press Enter to skip..."
fi

# Add Firebase dependencies if missing
echo ""
echo -e "${BLUE}Checking Firebase dependencies...${NC}"

if ! grep -q "firebase_core:" pubspec.yaml; then
    echo -e "${YELLOW}Adding Firebase dependencies to pubspec.yaml...${NC}"
    echo ""
    echo "Add these to your pubspec.yaml dependencies:"
    echo ""
    echo "  firebase_core: ^3.8.0"
    echo "  firebase_auth: ^5.4.0"
    echo "  cloud_firestore: ^5.6.0"
    echo "  firebase_analytics: ^11.5.0"
    echo "  firebase_messaging: ^15.3.0"
    echo "  firebase_storage: ^12.4.0"
else
    echo -e "${GREEN}✓ Firebase dependencies found${NC}"
fi

echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Download google-services.json from Firebase Console"
echo "2. Place it in android/app/"
echo "3. Run: flutter pub get"
echo "4. Initialize Firebase in your main.dart:"
echo ""
echo "   import 'package:firebase_core/firebase_core.dart';"
echo ""
echo "   void main() async {"
echo "     WidgetsFlutterBinding.ensureInitialized();"
echo "     await Firebase.initializeApp();"
echo "     runApp(MyApp());"
echo "   }"