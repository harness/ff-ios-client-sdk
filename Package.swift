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
        .package(url: "https://github.com/apple/swift-atomics.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/peterprokop/SwiftConcurrentCollections.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "ff-ios-client-sdk",
            dependencies: [
                .product(name: "Atomics", package: "swift-atomics"),
                .product(name: "SwiftConcurrentCollections", package: "SwiftConcurrentCollections")
            ],
			path: "Sources/ff-ios-client-sdk"),
        .testTarget(
            name: "ff-ios-client-sdkTests",
            dependencies: ["ff-ios-client-sdk"],
			path: "Tests/ff-ios-client-sdkTests"),
    ],
	swiftLanguageVersions: [.v5]
)
