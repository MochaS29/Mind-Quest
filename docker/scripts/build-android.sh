#!/bin/bash

# Build Android APK using Docker

echo "🤖 Building Android APK..."

# Check Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi

# Build type (debug or release)
BUILD_TYPE=${1:-debug}

echo "📦 Building $BUILD_TYPE APK..."

if [ "$BUILD_TYPE" == "release" ]; then
    docker-compose run --rm android-build ./gradlew assembleRelease
    APK_PATH="MindLabsQuestAndroid/app/build/outputs/apk/release/app-release.apk"
else
    docker-compose run --rm android-build ./gradlew assembleDebug
    APK_PATH="MindLabsQuestAndroid/app/build/outputs/apk/debug/app-debug.apk"
fi

if [ -f "$APK_PATH" ]; then
    echo "✅ APK built successfully!"
    echo "📍 Location: $APK_PATH"
    echo "📏 Size: $(du -h $APK_PATH | cut -f1)"
    
    # Copy to desktop for easy access
    cp "$APK_PATH" ~/Desktop/MindQuest-$BUILD_TYPE.apk
    echo "📂 Copied to: ~/Desktop/MindQuest-$BUILD_TYPE.apk"
else
    echo "❌ Build failed. Check logs above for errors."
    exit 1
fi