// swift-tools-version:5.1

/**
 *  https://github.com/tadija/AECli
 *  Copyright © 2020 Marko Tadić
 *  Licensed under the MIT license
 */

import PackageDescription

let package = Package(
    name: "AECli",
    products: [
        .library(
            name: "AECli",
            targets: ["AECli"]
        )
    ],
    targets: [
        .target(
            name: "AECli"
        ),
        .testTarget(
            name: "AECliTests",
            dependencies: ["AECli"]
        )
    ]
)
