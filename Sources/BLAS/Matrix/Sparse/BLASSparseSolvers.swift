//  BLASSparseSolvers.swift
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

extension BLAS {

  public static func solveCholesky<T>(_ a: SpMat<T>, _ b: [T]) -> [T] where T: AccelerateFloatingPoint {
    var rs = a.r
    var cs = a.c.map(Int.init)
    var vs = a.v
    var rhs = b
    var x = [T](repeating: 0, count: b.count)
    let structure: SparseMatrixStructure = rs.withUnsafeMutableBufferPointer { pR in
      cs.withUnsafeMutableBufferPointer { pC in
        SparseMatrixStructure(rowCount: 5, columnCount: 5, columnStarts: pC.baseAddress!, rowIndices: pR.baseAddress!, attributes: SparseAttributes_t(), blockSize: 1)
      }
    }
    if T.self is Double.Type {
      let llt: SparseOpaqueFactorization_Double = vs.withUnsafeMutableBufferPointer(as: Double.self) { pV in
        let a = SparseMatrix_Double(structure: structure, data: pV.baseAddress!)
        return SparseFactor(SparseFactorizationCholesky, a)
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
        return SparseFactor(SparseFactorizationCholesky, a)
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

//  public static func solveLU<T>(_ a: SpMat<T>, _ b: [T]) -> [T] where T: AccelerateFloatingPoint {
//    dgssv()
//  }

}
