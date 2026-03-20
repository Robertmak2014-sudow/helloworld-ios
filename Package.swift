// swift-tools-version:5.8
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
        .executableTarget(
            name: "HelloWorld",
            path: "Sources"
        )
    ]
)
