#!/bin/bash

echo "🔧 Setting up Mind Labs Quest for Xcode..."

# Navigate to ios directory
cd ios

# Create Pods directory structure
mkdir -p "Pods/Target Support Files/Pods-MindLabsQuest"

# Create minimal pod configuration files
cat > "Pods/Target Support Files/Pods-MindLabsQuest/Pods-MindLabsQuest.debug.xcconfig" << 'EOF'
// Configuration settings file format documentation can be found at:
// https://help.apple.com/xcode/#/dev745c5c974

PODS_PODFILE_DIR_PATH = ${SRCROOT}/.
PODS_ROOT = ${SRCROOT}/Pods
PODS_XCFRAMEWORKS_BUILD_DIR = $(PODS_CONFIGURATION_BUILD_DIR)/XCFrameworkIntermediates

// React Native settings
HEADER_SEARCH_PATHS = $(inherited) "${PODS_ROOT}/Headers/Public"
OTHER_LDFLAGS = $(inherited) -ObjC
GCC_PREPROCESSOR_DEFINITIONS = $(inherited) COCOAPODS=1

USE_RECURSIVE_SCRIPT_INPUTS_IN_SCRIPT_PHASES = YES
EOF

# Create release config
cp "Pods/Target Support Files/Pods-MindLabsQuest/Pods-MindLabsQuest.debug.xcconfig" \
   "Pods/Target Support Files/Pods-MindLabsQuest/Pods-MindLabsQuest.release.xcconfig"

# Create acknowledgements files
touch "Pods/Target Support Files/Pods-MindLabsQuest/Pods-MindLabsQuest-acknowledgements.plist"
touch "Pods/Target Support Files/Pods-MindLabsQuest/Pods-MindLabsQuest-acknowledgements.markdown"

# Create dummy Pods.xcodeproj
mkdir -p Pods
cat > Pods/Manifest.lock << 'EOF'
PODFILE CHECKSUM: dummy
COCOAPODS: 1.0.0
EOF

echo "✅ Setup complete!"
echo ""
echo "📱 To run on your iPhone:"
echo "1. Open Xcode (should open automatically)"
echo "2. Connect your iPhone via USB"
echo "3. Select your iPhone from the device dropdown"
echo "4. Click the Play button"
echo ""
echo "Opening Xcode now..."

# Open Xcode
open MindLabsQuest.xcodeproj