// swift-tools-version:5.2
// Package.swift
//

import PackageDescription

let package = Package(
  name: "Swiggl",
  platforms: [.macOS(.v10_15)],
  products: [
    .executable(name: "Test", targets: ["Test"]),
    .library(name: "Swiggl", targets: ["Swiggl"]),
    .library(name: "Swivl", targets: ["Swivl"])
  ],
  targets: [
    .target(name: "BLAS"),
    .target(
      name: "Swiggl",
      dependencies: ["Swivl"]),
    .target(
      name: "Swivl",
      dependencies: ["BLAS"]),
    .target(
      name:"Test",
      dependencies: ["Swiggl", "BLAS"]),
    .testTarget(
      name: "SwigglTests",
      dependencies: ["Swiggl"])
  ]
)
