// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "Cloudinary",
    dependencies: [
      .Package(url: "https://github.com/PerfectlySoft/Perfect-CURL", majorVersion: 2)
    ]
)
