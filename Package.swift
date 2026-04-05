// swift-tools-version:5.7
import PackageDescription


let package = Package(
    name: "MyApp",
    platforms: [
        .iOS(.v13) // Минимальная версия iOS
    ],
    products: [
        // Библиотека (если нужно)
        .library(
            name: "MyAppCore",
            targets: ["MyAppCore"]
        ),
        // Исполняемый файл (если это приложение)
        .executable(
            name: "MyApp",
            targets: ["MyApp"]
        )
    ],
    dependencies: [
        // Пример: добавьте зависимости, если нужны
        // .package(url: "https://github.com/some/package.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "MyApp",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "MyAppTests",
            dependencies: ["MyApp"],
            path: "Tests"
        )
    ]
)
