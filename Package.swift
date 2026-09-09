// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SalaryTicker",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "SalaryTicker", targets: ["SalaryTicker"]),
        .library(name: "SalaryTickerCore", targets: ["SalaryTickerCore"]),
        .library(name: "SalaryTickerFeatures", targets: ["SalaryTickerFeatures"])
    ],
    targets: [
        .target(
            name: "SalaryTickerCore",
            path: "Core"
        ),
        .target(
            name: "SalaryTickerFeatures",
            dependencies: ["SalaryTickerCore"],
            path: "Features"
        ),
        .executableTarget(
            name: "SalaryTicker",
            dependencies: ["SalaryTickerCore", "SalaryTickerFeatures"],
            path: "App",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "SalaryTickerTests",
            dependencies: ["SalaryTickerCore"],
            path: "Tests/SalaryTickerTests"
        )
    ]
)
