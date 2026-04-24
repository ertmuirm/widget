#!/bin/bash
#
# Widgetsmith Sidestore Build Script
# Packages the app for installation via Sidestore
#
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Read version from Info.plist
cd "$(dirname "$0")"
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Info.plist 2>/dev/null || echo "8.2")
BUILD=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" Info.plist 2>/dev/null || echo "1")
APP_NAME="${APP_NAME:-Widgetsmith}"
CLEANUP=true

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name)
            APP_NAME="$2"
            shift 2
            ;;
        --no-cleanup)
            CLEANUP=false
            shift
            ;;
        -h|--help)
            echo "Usage: ./build.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -n, --name NAME          Set app name [default: Widgetsmith]"
            echo "  --no-cleanup             Keep intermediate files"
            echo "  -h, --help               Show this help message"
            echo ""
            echo "Version is read from Info.plist: $VERSION ($BUILD)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

ZIP_NAME="${APP_NAME}-v${VERSION}-b${BUILD}-unsigned.zip"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Widgetsmith Sidestore Build Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Configuration:"
echo "  - App Name: $APP_NAME"
echo "  - Version:  $VERSION"
echo "  - Build:    $BUILD"
echo "  - Output:   $ZIP_NAME"
echo ""

# Step 1: Clean up
echo -e "${YELLOW}[1/4]${NC} Cleaning up..."
rm -rf Payload/
rm -f *.zip
rm -f *.ipa

# Step 2: Strip code signatures
echo -e "${YELLOW}[2/4]${NC} Stripping code signatures..."
rm -rf _CodeSignature 2>/dev/null || true
rm -rf "PlugIns/Widget Config Intent.appex/_CodeSignature" 2>/dev/null || true
rm -rf "PlugIns/Widget Config Intent.appex/SC_Info" 2>/dev/null || true
rm -rf "PlugIns/WidgetsExtension.appex/_CodeSignature" 2>/dev/null || true
rm -rf "PlugIns/WidgetsExtension.appex/SC_Info" 2>/dev/null || true
rm -rf "Frameworks/UserMessagingPlatform.framework/_CodeSignature" 2>/dev/null || true
rm -rf "Frameworks/UserMessagingPlatform.framework/SC_Info" 2>/dev/null || true

# Remove any remaining code signatures recursively
find . -name "_CodeSignature" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "SC_Info" -type d -exec rm -rf {} + 2>/dev/null || true

echo "  ✓ Code signatures stripped"

# Step 3: Create Payload structure
echo -e "${YELLOW}[3/4]${NC} Creating Payload structure..."
mkdir -p "Payload/${APP_NAME}.app"

# Copy PlugIns
cp -R PlugIns Payload/

# Copy Frameworks
cp -R Frameworks Payload/

# Copy all file types to app bundle
for ext in otf ttf png json plist car bundle storyboardc; do
    case $ext in
        storyboardc)
            find . -maxdepth 1 -type d -name "*storyboard*" -exec cp -R {} "Payload/${APP_NAME}.app/" \; 2>/dev/null || true
            ;;
        *)
            find . -maxdepth 1 -name "*.$ext" -exec cp -R {} "Payload/${APP_NAME}.app/" \; 2>/dev/null || true
            ;;
    esac
done 2>/dev/null || true

# Copy directories
for dir in Metadata.appintents Intents.intentdefinition; do
    [ -d "$dir" ] && cp -R "$dir" "Payload/${APP_NAME}.app/" 2>/dev/null || true
done

# Copy individual files
for file in PkgInfo PrivacyInfo.xcprivacy StoreKitTest.storekit decrypt.day WeatherExample.json action_config.json indexes_en.json safeSymbols.json googleaqi.json cities.plist; do
    [ -f "$file" ] && cp "$file" "Payload/${APP_NAME}.app/" 2>/dev/null || true
done

# Copy Info.plist to root of app bundle
cp Info.plist "Payload/${APP_NAME}.app/"

# Step 4: Create zip
echo -e "${YELLOW}[4/4]${NC} Creating zip archive..."
if command -v zip &> /dev/null; then
    cd Payload
    zip -r "../$ZIP_NAME" * -x "*.DS_Store"
    cd ..
else
    echo "  Using Python zipfile module..."
    python3 << PYEOF
import zipfile
import os

zip_name = "$ZIP_NAME"
payload_dir = 'Payload'

with zipfile.ZipFile(zip_name, 'w', zipfile.ZIP_DEFLATED) as zf:
    for root, dirs, files in os.walk(payload_dir):
        dirs[:] = [d for d in dirs if d != '.DS_Store']
        for file in files:
            if file == '.DS_Store':
                continue
            file_path = os.path.join(root, file)
            arcname = os.path.relpath(file_path, os.path.dirname(payload_dir))
            zf.write(file_path, arcname)

print(f"Created {zip_name}")
PYEOF
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Build Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Output: $ZIP_NAME"
echo "Size:   $(du -h "$ZIP_NAME" | cut -f1)"
echo ""
echo "Structure (first 30 entries):"
python3 << PYEOF
import zipfile
import os

with zipfile.ZipFile("$ZIP_NAME", 'r') as zf:
    names = zf.namelist()
    for name in names[:30]:
        info = zf.getinfo(name)
        print(f"  {name}")
    if len(names) > 30:
        print(f"  ... and {len(names) - 30} more files")
PYEOF
echo ""

# Cleanup if enabled
if [ "$CLEANUP" = true ]; then
    echo "Cleaning up intermediate files..."
    rm -rf Payload/
fi

echo -e "${GREEN}Done!${NC}"
echo ""
echo "To use with Sidestore:"
echo "  1. Download the zip artifact from GitHub Actions"
echo "  2. Extract and use with Sidestore app"
echo "  3. Sidestore will sign the app with your certificate"