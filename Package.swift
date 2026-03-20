// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "HelloWorld",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .executable(name: "HelloWorld", targets: ["HelloWorld"])
    ],
    targets: [
        .target(
            name: "HelloWorld",
            path: "Sources"
        )
    ]
)
