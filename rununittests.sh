gem install xcpretty
swift package generate-xcodeproj
xcodebuild -list -project ff-ios-client-sdk.xcodeproj
xcodebuild clean
xcodebuild -destination 'platform=iOS Simulator,name=iPhone 14' test -scheme  ff-ios-client-sdk-Package | xcpretty
