// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "HTTPsimctl",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0")
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ],
            swiftSettings: [
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)),
                .unsafeFlags(
                    [
                        "-Xfrontend",
                        "-warn-long-function-bodies=20",
                        "-Xfrontend",
                        "-warn-long-expression-type-checking=20"
                    ],
                    .when(configuration: .debug)
                ),
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "VaporTesting", package: "vapor")
            ]
        )
    ]
)

#if !RELEASE
package.dependencies.append(.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"))
#endif
