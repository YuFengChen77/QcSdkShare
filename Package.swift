// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "QcSdkShare", defaultLocalization: "en", platforms: [.iOS(.v17)],

    products: [
        .library(name: "QcSdkShare", targets: ["QcSdkShare", "QcSdkShareSupport"]),
        .library(name: "QcSdkShareDependencies", type: .dynamic, targets: ["QcSdkShareDependencies"])
    ],

    dependencies: [
        .package(url: "https://github.com/YuFengChen77/QcSdkCore.git", exact: "2.0.0-beta.1")
    ],

    targets: [
        .binaryTarget(name: "QcSdkShare", url: "https://github.com/YuFengChen77/QcSdkShare/releases/download/2.0.0-beta.1/QcSdkShare-2.0.0-beta.1.xcframework.zip", checksum: "db8f2f0153a5764961936b0a0a284cc7346ef63ee678f18849703cf08eb6e9eb"),

        .target(name: "QcSdkShareSupport", dependencies: ["QcSdkShare", .product(name: "QcSdkCore", package: "qcsdkcore")], path: "QcSdkShare", exclude: ["DependencySources"], sources: ["Sources"]),
        .target(name: "QcSdkShareDependencies", dependencies: [], path: "QcSdkShare", exclude: ["Sources"], sources: ["DependencySources"])
    ]
)
