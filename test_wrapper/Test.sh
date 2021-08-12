#!/bin/sh

xcodebuild test \
-project test_wrapper.xcodeproj \
-scheme test_wrapperTests \
-destination 'platform=iOS Simulator,name=iPhone 12,OS=14.5'
