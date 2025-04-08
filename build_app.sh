#!/bin/bash

# Set up directories
APP_NAME="Filtora"
BUILD_DIR="build"
APP_DIR="$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    TARGET_ARCH="arm64-apple-macosx13.0"
else
    TARGET_ARCH="x86_64-apple-macosx13.0"
fi

echo "Building for architecture: $ARCH"

# Clean up previous build
rm -rf "$BUILD_DIR" "$APP_DIR"

# Create necessary directories
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

# Create Info.plist
cat > "$CONTENTS_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.$APP_NAME</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2024. All rights reserved.</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

echo "Compiling Swift files..."

# Compile Swift files
swiftc -v -o "$MACOS_DIR/$APP_NAME" \
    -sdk $(xcrun --show-sdk-path) \
    -F $(xcrun --show-sdk-path)/../../../Developer/Library/Frameworks \
    -framework SwiftUI \
    -framework AppKit \
    -framework Foundation \
    -target $TARGET_ARCH \
    Filtora/Models/BlockerManager.swift \
    Filtora/Views/ContentView.swift \
    Filtora/Views/SettingsView.swift \
    Filtora/Views/MenuBarView.swift \
    Filtora/Views/MainWindowView.swift \
    Filtora/FiltoraApp.swift

if [ $? -ne 0 ]; then
    echo "Compilation failed!"
    exit 1
fi

echo "Making app executable..."

# Make the app executable
chmod +x "$MACOS_DIR/$APP_NAME"

echo "Copying resources..."

# Copy resources
cp -r Filtora/Resources/* "$RESOURCES_DIR/" 2>/dev/null || :

# Copy scripts
cp blocker.sh "$RESOURCES_DIR/"
cp unblocker.sh "$RESOURCES_DIR/"
cp list.txt "$RESOURCES_DIR/"

# Make scripts executable
chmod +x "$RESOURCES_DIR/blocker.sh"
chmod +x "$RESOURCES_DIR/unblocker.sh"

echo "Build complete. Running app..."

# Run the app
open "$APP_DIR" 