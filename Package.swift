// swift-tools-version:5.2
//  Package.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import PackageDescription

let package = Package(
  name: "Swiggl",
  platforms: [.macOS(.v10_15)],
  products: [
    .executable(name: "Test", targets: ["Test"]),
    .library(name: "Swiggl", targets: ["Swiggl"]),
    .library(name: "Swivl", targets: ["Swivl"]),
  ],
  dependencies: [
    .package(url: "https://github.com/Quick/Quick.git", from: "3.0.0"),
    .package(url: "https://github.com/Quick/Nimble.git", from: "9.0.0")
  ],
  targets: [
    .systemLibrary(name: "SuperLU", path: "External/SuperLU"),
    .systemLibrary(name: "OSQP", path: "External/OSQP"),
    .systemLibrary(name: "ARPACK", path: "External/ARPACK"),

    .target(
      name: "LinearAlgebra",
      dependencies: ["SuperLU", "OSQP", "ARPACK"],
      cSettings: [.unsafeFlags(["-IExternal"])],
      linkerSettings: [.unsafeFlags(["-LExternal/lib"])]
    ),
    .target(
      name: "Swiggl",
      dependencies: ["Swivl"]),
    .target(
      name: "Swivl",
      dependencies: ["LinearAlgebra"]),
    .target(
      name:"Test",
      dependencies: ["Swivl"]),
    
    .testTarget(
      name: "SwivlTests",
      dependencies: ["Swivl", "Quick", "Nimble"])
  ]
)
