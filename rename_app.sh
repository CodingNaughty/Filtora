#!/bin/bash

# Create new directory structure
mkdir -p Filtora/Models
mkdir -p Filtora/Views
mkdir -p Filtora/Resources

# Move files to their new locations
mv Filtora/WebsiteBlocker/BlockerManager.swift Filtora/Models/
mv Filtora/WebsiteBlocker/ContentView.swift Filtora/Views/
mv Filtora/WebsiteBlocker/SettingsView.swift Filtora/Views/
mv Filtora/WebsiteBlocker/MenuBarView.swift Filtora/Views/
mv Filtora/WebsiteBlocker/Views.swift Filtora/Views/MainWindowView.swift
mv Filtora/WebsiteBlocker/WebsiteBlockerApp.swift Filtora/FiltoraApp.swift
mv Filtora/WebsiteBlocker/Info.plist Filtora/
mv Filtora/WebsiteBlocker/WebsiteBlocker.entitlements Filtora/Filtora.entitlements

# Clean up old directories
rm -rf Filtora/WebsiteBlocker

# Update file contents
find Filtora -type f -name "*.swift" -exec sed -i '' 's/WebsiteBlocker/Filtora/g' {} +
find Filtora -type f -name "*.plist" -exec sed -i '' 's/WebsiteBlocker/Filtora/g' {} +
find Filtora -type f -name "*.entitlements" -exec sed -i '' 's/WebsiteBlocker/Filtora/g' {} +

# Update bundle identifiers
find Filtora -type f -name "*.plist" -exec sed -i '' 's/com\.websiteblocker/com.filtora/g' {} +

echo "App renamed successfully to Filtora!" 