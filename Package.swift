// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "2fa-vlv",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "2FA-vlv", targets: ["TwoFAvlv"])
    ],
    targets: [
        .target(
            name: "TwoFACore",
            path: "Sources/TwoFACore"
        ),
        .executableTarget(
            name: "TwoFAvlv",
            dependencies: ["TwoFACore"],
            path: "Sources/TwoFAvlv"
        ),
        .testTarget(
            name: "TwoFACoreTests",
            dependencies: ["TwoFACore"],
            path: "Tests/TwoFACoreTests"
        )
    ]
)
