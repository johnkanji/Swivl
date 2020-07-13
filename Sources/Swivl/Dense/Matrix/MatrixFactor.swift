//  MatrixFactor.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import Foundation
import BLAS

public protocol MatrixFactor {
  associatedtype Scalar: AccelerateFloatingPoint

  func solve(_ b: Matrix<Scalar>) -> Matrix<Scalar>

}


struct CholeskyFactor<Scalar: AccelerateFloatingPoint>: MatrixFactor {
  var A: [Scalar] = []
  var tau: [Scalar] = []
  var shape: RowCol

  public func solve(_ b: Matrix<Scalar>) -> Matrix<Scalar> {
    let x = BLAS.solveFactorizedCholesky(A, tau)
    return Matrix(flat: x, shape: b.shape)
  }

}


struct LDLFactor<Scalar: AccelerateFloatingPoint>: MatrixFactor {
  var A: [Scalar] = []
  var tau: [Scalar] = []
  var shape: RowCol

  public func solve(_ b: Matrix<Scalar>) -> Matrix<Scalar> {
    let x = BLAS.solveFactorizedLDL(A, tau)
    return Matrix(flat: x, shape: b.shape)
  }

}


struct LUFactor<Scalar: AccelerateFloatingPoint>: MatrixFactor {
  var A: [Scalar] = []
  var tau: [Scalar] = []
  var shape: RowCol

  public func solve(_ b: Matrix<Scalar>) -> Matrix<Scalar> {
    let x = BLAS.solveFactorizedLU(A, tau)
    return Matrix(flat: x, shape: b.shape)
  }

}


struct QRFactor<Scalar: AccelerateFloatingPoint>: MatrixFactor {
  var A: [Scalar] = []
  var tau: [Scalar] = []
  var shape: RowCol

  public func solve(_ b: Matrix<Scalar>) -> Matrix<Scalar> {
    let x = BLAS.solveFactorizedQR(A, tau)
    return Matrix(flat: x, shape: b.shape)
  }

}


extension Matrix where Scalar: AccelerateFloatingPoint {

  public func factorizeCholesky() -> some MatrixFactor {
    let (A, tau) = BLAS.factorizeCholesky(_flat, shape)
    return CholeskyFactor(A: A, tau: tau, shape: shape)
  }

  public func factorizeLDL() -> some MatrixFactor {
    let (A, tau) = BLAS.factorizeLDL(_flat, shape)
    return LDLFactor(A: A, tau: tau, shape: shape)
  }

  public func factorizeLU() -> some MatrixFactor {
    let (A, tau) = BLAS.factorizeLU(_flat, shape)
    return LUFactor(A: A, tau: tau, shape: shape)
  }

  public func factorizeQR() -> some MatrixFactor {
    let (A, tau) = BLAS.factorizeQR(_flat, shape)
    return QRFactor(A: A, tau: tau, shape: shape)
  }

}
