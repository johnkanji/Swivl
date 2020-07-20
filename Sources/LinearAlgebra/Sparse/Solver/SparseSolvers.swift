//  SparseSolvers.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Accelerate
import SuperLU

extension LinAlg {

  static let sparseFactorization: [MatrixFactorization: SparseFactorization_t] = [
    .cholesky: SparseFactorizationCholesky,
    .ldl: SparseFactorizationLDLT,
    .qr: SparseFactorizationQR
  ]

  static func solveSparse<T>(_ a: SpMat<T>, _ b: [T], type: MatrixFactorization) -> [T]
  where T: SwivlFloatingPoint {
    var ri = a.ri
    var cs = a.cs
    var vs = a.v
    var rhs = b
    var x = [T](repeating: 0, count: b.count)
    let structure: SparseMatrixStructure = ri.withUnsafeMutableBufferPointer { pR in
      cs.withUnsafeMutableBufferPointer { pC in
        SparseMatrixStructure(rowCount: Int32(a.shape.r), columnCount: Int32(a.shape.c), columnStarts: pC.baseAddress!, rowIndices: pR.baseAddress!, attributes: SparseAttributes_t(), blockSize: 1)
      }
    }
    if T.self is Double.Type {
      let llt: SparseOpaqueFactorization_Double = vs.withUnsafeMutableBufferPointer(as: Double.self) { pV in
        let a = SparseMatrix_Double(structure: structure, data: pV.baseAddress!)
        let fac: SparseFactorization_t = sparseFactorization[type]!
        return SparseFactor(fac, a)
      }
      rhs.withUnsafeMutableBufferPointer(as: Double.self) { pB in
        x.withUnsafeMutableBufferPointer(as: Double.self) { pX in
          let B = DenseVector_Double(count: Int32(b.count), data: pB.baseAddress!)
          let X = DenseVector_Double(count: Int32(b.count), data: pX.baseAddress!)
          SparseSolve(llt, B, X)
        }
      }
      SparseCleanup(llt)
    } else {
      let llt: SparseOpaqueFactorization_Float = vs.withUnsafeMutableBufferPointer(as: Float.self) { pV in
        let a = SparseMatrix_Float(structure: structure, data: pV.baseAddress!)
        return SparseFactor(sparseFactorization[type]!, a)
      }
      rhs.withUnsafeMutableBufferPointer(as: Float.self) { pB in
        x.withUnsafeMutableBufferPointer(as: Float.self) { pX in
          let B = DenseVector_Float(count: Int32(b.count), data: pB.baseAddress!)
          let X = DenseVector_Float(count: Int32(b.count), data: pX.baseAddress!)
          SparseSolve(llt, B, X)
        }
      }
      SparseCleanup(llt)
    }
    return x
  }


  public static func solveCholesky<T>(_ a: SpMat<T>, _ b: [T]) -> [T] where T: SwivlFloatingPoint {
    solveSparse(a, b, type: .cholesky)
  }

  public static func solveLDL<T>(_ a: SpMat<T>, _ b: [T]) -> [T] where T: SwivlFloatingPoint {
    solveSparse(a, b, type: .ldl)
  }

  public static func solveSparseQR<T>(_ a: SpMat<T>, _ b: [T]) -> [T] where T: SwivlFloatingPoint {
    solveSparse(a, b, type: .qr)
  }

}
