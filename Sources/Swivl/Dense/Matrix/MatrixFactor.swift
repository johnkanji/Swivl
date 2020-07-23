//  MatrixFactor.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import Foundation
import LinearAlgebra

public protocol MatrixFactor {
  associatedtype Scalar: SwivlFloatingPoint

  var solve: (Matrix<Scalar>) -> Matrix<Scalar> { get }

}

public class DenseMatrixFactor<Scalar: SwivlFloatingPoint>: MatrixFactor {

  public var solve: (Matrix<Scalar>) -> Matrix<Scalar> = { _ in Matrix() }

  init() {}

}


class CholeskyFactor<Scalar: SwivlFloatingPoint>: DenseMatrixFactor<Scalar> {
  private var A: [Scalar] = []
  private var tau: [Scalar] = []
  private var shape: RowCol

  init(_ a: [Scalar], _ tau: [Scalar], _ shape: RowCol) {
    self.A = a
    self.tau = tau
    self.shape = shape
  }

  public func solve(_ b: Matrix<Scalar>) -> Matrix<Scalar> {
    let x = LinAlg.solveFactorizedCholesky(A, tau)
    return Matrix(flat: x, shape: b.shape)
  }

}


class LDLFactor<Scalar: SwivlFloatingPoint>: DenseMatrixFactor<Scalar> {
  private var A: [Scalar] = []
  private var tau: [Scalar] = []
  private var shape: RowCol

  init(_ a: [Scalar], _ tau: [Scalar], _ shape: RowCol) {
    self.A = a
    self.tau = tau
    self.shape = shape
  }

  public func solve(_ b: Matrix<Scalar>) -> Matrix<Scalar> {
    let x = LinAlg.solveFactorizedLDL(A, tau)
    return Matrix(flat: x, shape: b.shape)
  }

}


class LUFactor<Scalar: SwivlFloatingPoint>: DenseMatrixFactor<Scalar> {
  private var A: [Scalar] = []
  private var tau: [Scalar] = []
  private var shape: RowCol

  init(_ a: [Scalar], _ tau: [Scalar], _ shape: RowCol) {
    self.A = a
    self.tau = tau
    self.shape = shape
  }

  public func solve(_ b: Matrix<Scalar>) -> Matrix<Scalar> {
    let x = LinAlg.solveFactorizedLU(A, tau)
    return Matrix(flat: x, shape: b.shape)
  }

}


class QRFactor<Scalar: SwivlFloatingPoint>: DenseMatrixFactor<Scalar> {
  private var A: [Scalar] = []
  private var tau: [Scalar] = []
  private var shape: RowCol

  init(_ a: [Scalar], _ tau: [Scalar], _ shape: RowCol) {
    self.A = a
    self.tau = tau
    self.shape = shape
  }

  public func solve(_ b: Matrix<Scalar>) -> Matrix<Scalar> {
    let x = LinAlg.solveFactorizedQR(A, tau)
    return Matrix(flat: x, shape: b.shape)
  }

}


extension Matrix where Scalar: SwivlFloatingPoint {

  public func factorizeCholesky() -> DenseMatrixFactor<Scalar> {
    let (A, tau) = LinAlg.factorizeCholesky(_flat, shape)
    return CholeskyFactor(A, tau, shape)
  }

  public func factorizeLDL() -> DenseMatrixFactor<Scalar> {
    let (A, tau) = LinAlg.factorizeLDL(_flat, shape)
    return LDLFactor(A, tau, shape)
  }

  public func factorizeLU() -> DenseMatrixFactor<Scalar> {
    let (A, tau) = LinAlg.factorizeLU(_flat, shape)
    return LUFactor(A, tau, shape)
  }

  public func factorizeQR() -> DenseMatrixFactor<Scalar> {
    let (A, tau) = LinAlg.factorizeQR(_flat, shape)
    return QRFactor(A, tau, shape)
  }

}
