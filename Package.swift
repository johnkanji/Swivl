// swift-tools-version:5.3
// Package.swift
//
// Copyright (c) 2017 Alexander Taraymovich <taraymovich@me.com>
// All rights reserved.
//
// This software may be modified and distributed under the terms
// of the BSD license. See the LICENSE file for details.
import PackageDescription

let package = Package(
  name: "SwiftMat",
  platforms: [.macOS(.v10_15)],
  products: [
    .executable(name: "Test", targets: ["Test"]),
    .library(name: "SwiftMat", targets: ["SwiftMat"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name:"Test",
      dependencies: [
        "SwiftMat"
      ]),
    .target(
      name: "SwiftMat",
      dependencies: [
      ]),
    .testTarget(
      name: "SwiftMatTests",
      dependencies: ["SwiftMat"])
  ]
)
