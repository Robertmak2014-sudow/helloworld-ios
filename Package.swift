// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "ClickerApp",
    platforms: [
        .iOS(.v12)  // Указываем минимальную версию iOS 12
    ],
    products: [
        .executable(name: "ClickerApp", targets: ["ClickerApp"])
    ],
    targets: [
        .target(
            name: "ClickerApp",
            dependencies: []
        )
    ]
)
