// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "QcSdkShare", defaultLocalization: "en", platforms: [.iOS(.v17)],

    products: [
        .library(name: "QcSdkShare", targets: ["QcSdkShare", "QcSdkShareSupport"])
    ],

    dependencies: [
        .package(url: "https://github.com/YuFengChen77/QcSdkCore.git", exact: "1.1.5")
    ],

    targets: [
        .binaryTarget(name: "QcSdkShare", url: "https://github.com/YuFengChen77/QcSdkShare/releases/download/1.1.2/QcSdkShare-1.1.2.xcframework.zip", checksum: "15feb76881decc3a2c0e0e08a41632bb889ab91c91c911ea01922209d3f9fa44"),

        .target(name: "QcSdkShareSupport", dependencies: ["QcSdkShare", .product(name: "QcSdkCore", package: "qcsdkcore")], path: "QcSdkShare", sources: ["Sources"])
    ]
)
