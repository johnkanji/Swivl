//  BLASMatrixProperties.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Accelerate

extension BLAS {

  public static func inverse<T>(_ a: [T], _ shape: RowCol) -> [T] where T: AccelerateNumeric {
    return []
  }

  
  public static func diag<T>(_ a: [T], _ shape: RowCol) -> [T] where T: AccelerateNumeric {
    let n = Swift.min(shape.r, shape.c)
    let diagi = (0..<n).map { $0*n + $0 }
    return BLAS.gather(a, diagi)
  }

  public static func diag<T>(_ a: [T]) -> [T] where T: AccelerateNumeric {
    let n = a.count
    var out = [T](repeating: 0, count: n*n)
    (0..<n).forEach { i in
      out[i*n+i] = a[i]
    }
    return out
  }


  public static func trace<T>(_ a: [T], _ shape: RowCol) -> T where T: AccelerateNumeric {
    return diag(a, shape).reduce(0, *)
  }


  public static func det<T>(_ a: [T], _ shape: RowCol) -> T where T: AccelerateFloatingPoint {
    precondition(shape.r == shape.c, "Only square matrices are supported")
    
    func detPerm(_ p: [T]) -> T {
      let diagp = diag(p, shape)
      let swaps = shape.r - Int(diagp.reduce(0, +));
      return swaps % 2 == 0 ? 1 : -1
    }
    
    let (_, (U, _) ,P, Q) = BLAS.LU(a, shape, output: .LUPQ)
    return detPerm(P!) * detPerm(Q!) * diag(U, shape).reduce(1, *)
  }


  public static func norm<T>(_ a: [T], _ shape: RowCol, _ norm: MatrixNorm = .frobenius) throws -> T
  where T: AccelerateFloatingPoint {
    if norm == .l2 {
      return try norm2(a, shape)
    }

    var f = norm.rawValue
    var m = __CLPK_integer(shape.r)
    var n = __CLPK_integer(shape.c)
    var lda = __CLPK_integer(shape.r)
    var A = transpose(a, shape)

    if T.self is Double.Type {
      return A.withUnsafeMutableBufferPointer(as: Double.self) { pA in
        dlange_(&f, &m, &n, pA.baseAddress!, &lda, nil) as! T
      }
    } else {
      return A.withUnsafeMutableBufferPointer(as: Float.self) { pA in
        slange_(&f, &m, &n, pA.baseAddress!, &lda, nil) as! T
      }
    }
  }

  public static func norm2<T>(_ a: [T], _ shape: RowCol) throws -> T where T: AccelerateFloatingPoint {
    let (v, _, _) = try SVD(a, shape)
    return v.max()!
  }


  public static func cond<T>(_ a: [T], _ shape: RowCol, norm: MatrixNorm = .frobenius) throws -> T
  where T: AccelerateFloatingPoint {
    if norm == .l2 {
      let (v, _, _) = try SVD(a, shape)
      return v.max()! / v.min()!
    } else {
      let nA = try Self.norm(a, shape, norm)
      let nInvA = try Self.norm(inverse(a, shape), shape, norm)
      return nA * nInvA
    }
  }
  
}
