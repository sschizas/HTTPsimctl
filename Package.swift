// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "HTTPsimctl",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "4.0.0"))
    ],
    targets: [
        .target(
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
                )
            ]
        ),
        .executableTarget(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(
            name: "AppTests",
            dependencies:
                [
                    .target(name: "App"),
                    .product(name: "XCTVapor", package: "vapor")
                ]
        )
    ]
)

#if !RELEASE
package.dependencies.append(.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"))
#endif
