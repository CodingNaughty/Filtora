#!/bin/bash

# Create the Xcode project
xcodebuild -create-xcproject \
    -project WebsiteBlocker.xcodeproj \
    -target WebsiteBlocker \
    -configuration Release

# Build the app
xcodebuild -project WebsiteBlocker.xcodeproj \
    -scheme WebsiteBlocker \
    -configuration Release \
    -derivedDataPath build

# Create the app bundle
mkdir -p WebsiteBlocker.app/Contents/{MacOS,Resources}
cp -r build/Build/Products/Release/WebsiteBlocker.app/* WebsiteBlocker.app/

# Make the app executable
chmod +x WebsiteBlocker.app/Contents/MacOS/WebsiteBlocker

# Run the app
open WebsiteBlocker.app 