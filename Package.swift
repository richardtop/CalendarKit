// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "CalendarKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v11),
        .tvOS(.v11)
    ],
    products: [
        .library(
            name: "CalendarKit",
            targets: ["CalendarKit"]),
    ],
    targets: [
        .target(name: "CalendarKit",
                path: "Sources")
    ]
)
