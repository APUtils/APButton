#!/bin/bash

set -e

base_dir=$(dirname "$0")
cd "$base_dir"

echo ""
echo ""

echo "Building Pods project..."
set -o pipefail && xcodebuild -workspace "Pods Project/APButton.xcworkspace" -scheme "APButton-Example" -configuration "Release" -sdk iphonesimulator | xcpretty
echo ""

echo -e "Performing tests..."
simulator_id="$(xcrun simctl list devices available iPhone | grep " SE " | tail -1 | sed -e "s/.*(\([0-9A-Z-]*\)).*/\1/")"
if [ -n "${simulator_id}" ]; then
    echo "Using iPhone SE simulator with ID: '${simulator_id}'"

else
    simulator_id="$(xcrun simctl list devices available iPhone | grep "^    " | tail -1 | sed -e "s/.*(\([0-9A-Z-]*\)).*/\1/")"
    if [ -n "${simulator_id}" ]; then
        echo "Using iPhone simulator with ID: '${simulator_id}'"
        
    else
        echo  >&2 "error: Please install iPhone simulator."
        echo " "
        exit 1
    fi
fi

set -o pipefail && xcodebuild -workspace "Pods Project/APButton.xcworkspace" -sdk iphonesimulator -scheme "APButton-Example" -destination "platform=iOS Simulator,id=${simulator_id}" test | xcpretty

echo ""
echo "SUCCESS!"
echo ""
echo ""
