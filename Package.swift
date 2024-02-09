// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ff-ios-client-sdk",
	platforms: [
		.iOS(.v10)
	],
    products: [
        .library(
            name: "ff-ios-client-sdk",
            targets: ["ff-ios-client-sdk"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        .target(
            name: "ff-ios-client-sdk",
            dependencies: [
            ],
			path: "Sources/ff-ios-client-sdk"),
        .testTarget(
            name: "ff-ios-client-sdkTests",
            dependencies: ["ff-ios-client-sdk"],
			path: "Tests/ff-ios-client-sdkTests"),
    ],
	swiftLanguageVersions: [.v5]
)
