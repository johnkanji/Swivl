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
    .library(name: "Swivl", targets: ["Swivl"]),
  ],
  targets: [
//    .systemLibrary(name: "CXSparse", path: "External/CXSparse"),
    .systemLibrary(name: "SuperLU", path: "External/SuperLU"),
    .systemLibrary(name: "OSQP", path: "External/OSQP"),

    .target(
      name: "LinearAlgebra",
      dependencies: ["SuperLU", "OSQP"],
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
    
//    .testTarget(
//      name: "SwigglTests",
//      dependencies: ["Swiggl"])
  ]
)
