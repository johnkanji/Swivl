//  MatrixProperties.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Accelerate

extension LinAlg {

  public static func inverse<T>(_ a: Mat<T>) -> Mat<T> where T: SwivlNumeric {
    return ([],a.shape)
  }

  
  public static func diag<T>(_ a: Mat<T>) -> [T] where T: SwivlNumeric {
    let n = Swift.min(a.shape.r, a.shape.c)
    let diagi = (0..<n).map { $0*n + $0 }
    return LinAlg.gather(a.flat, diagi)
  }

  public static func diag<T>(_ a: [T]) -> Mat<T> where T: SwivlNumeric {
    let n = a.count
    var out = [T](repeating: 0, count: n*n)
    (0..<n).forEach { i in
      out[i*n+i] = a[i]
    }
    return (out, (n,n))
  }


  public static func trace<T>(_ a: Mat<T>) -> T where T: SwivlNumeric {
    return diag(a).sum()
  }


  public static func det<T>(_ a: Mat<T>) -> T where T: SwivlFloatingPoint {
    precondition(a.shape.r == a.shape.c, "Only square matrices are supported")
    
    func detPerm(_ p: Mat<T>) -> T {
      let diagp = diag(p)
      let swaps = p.shape.r - Int(diagp.sum());
      return swaps % 2 == 0 ? 1 : -1
    }
    
    let (_, U ,P, Q) = LinAlg.LU(a, output: .LUPQ)
    return detPerm(P!) * detPerm(Q!) * diag(U).prod()
  }


  public static func norm<T>(_ a: Mat<T>, _ norm: MatrixNorm = .frobenius) throws -> T
  where T: SwivlFloatingPoint {
    if norm == .l2 {
      return try norm2(a)
    }

    var f = norm.rawValue
    var m = __CLPK_integer(a.shape.r)
    var n = __CLPK_integer(a.shape.c)
    var lda = __CLPK_integer(a.shape.r)
    var A = transpose(a)

    if T.self is Double.Type {
      return A.flat.withUnsafeMutableBufferPointer(as: Double.self) { pA in
        dlange_(&f, &m, &n, pA.baseAddress!, &lda, nil) as! T
      }
    } else {
      return A.flat.withUnsafeMutableBufferPointer(as: Float.self) { pA in
        slange_(&f, &m, &n, pA.baseAddress!, &lda, nil) as! T
      }
    }
  }

  public static func norm2<T>(_ a: Mat<T>) throws -> T where T: SwivlFloatingPoint {
    let (v, _, _) = try SVD(a)
    return v.max()!
  }


  public static func cond<T>(_ a: Mat<T>, norm: MatrixNorm = .frobenius) throws -> T
  where T: SwivlFloatingPoint {
    if norm == .l2 {
      let (v, _, _) = try SVD(a)
      return v.max()! / v.min()!
    } else {
      let nA = try Self.norm(a, norm)
      let nInvA = try Self.norm(inverse(a), norm)
      return nA * nInvA
    }
  }
  
}
