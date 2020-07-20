//  LU.swift
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

  public static func LU<T>(_ a: Mat<T>, output: LUOutput = .LU) -> (L: Mat<T>, U: Mat<T>, P: Mat<T>?, Q: Mat<T>?)
  where T: SwivlFloatingPoint {
    precondition(a.shape.r == a.shape.c, "Only square matrices are supported")

    var m = Int32(a.shape.r)
    var n = Int32(a.shape.c)
    var lda = Int32(a.shape.r)
    var ipiv = [Int32](repeating: 0, count: Swift.min(a.shape.r,a.shape.c))
    var jpiv = [Int32](repeating: 0, count: output == .LUPQ ? Swift.min(a.shape.r, a.shape.c) : 1)
    var info = Int32()
    var out = LinAlg.transpose(a)

    if T.self is Double.Type {
      if output != .LUPQ {
        out.flat.withUnsafeMutableBufferPointer(as: Double.self) { ptr in
          dgetrf_(&m, &n, ptr.baseAddress!, &lda, &ipiv, &info)
        }
      } else {
        _ = out.flat.withUnsafeMutableBufferPointer(as: Double.self) { ptr in
          dgetc2_(&n, ptr.baseAddress!, &lda, &ipiv, &jpiv, &info)
        }
      }
    } else {
      if output != .LUPQ {
        out.flat.withUnsafeMutableBufferPointer(as: Float.self) { ptr in
          sgetrf_(&m, &n, ptr.baseAddress!, &lda, &ipiv, &info)
        }
      } else {
        _ = out.flat.withUnsafeMutableBufferPointer(as: Float.self) { ptr in
          sgetc2_(&n, ptr.baseAddress!, &lda, &ipiv, &jpiv, &info)
        }
      }
    }
    var P = Mat<T>(makePermutationMatrix(ipiv), a.shape)
    P = LinAlg.transpose(P)
    var L = LinAlg.triangle(LinAlg.transpose(out), .lower, diagonal: -1)
    L = Mat<T>(LinAlg.add(L.flat, LinAlg.eye(L.shape.r).flat), L.shape)
    let U = LinAlg.triangle(LinAlg.transpose(out), .upper)

    switch output {
    case .LU:
      L = LinAlg.multiplyMatrix(P, L)
      return (L: L, U: U, P: nil, Q: nil)
    case .LUP:
      return (L: L, U: U, P: P, Q: nil)
    case .LUPQ:
      let Q = Mat<T>(makePermutationMatrix(jpiv), a.shape)
      return (L: L, U: U, P: P, Q: Q)
    }
  }

  static func makePermutationMatrix<T>(_ piv: [Int32]) -> [T] where T: SwivlFloatingPoint {
    let piv = piv.map{ $0 - 1 }
    var swaps = Array(0..<piv.count)
    (0..<piv.count).forEach { i in
      if (piv[i] != -1 && piv[i] != Int32(i)) { swaps.swapAt(i, Int(piv[i])) }
    }
    var P = [T](repeating: 0, count: piv.count * piv.count)
    swaps.enumerated().forEach { i, p in P[i*piv.count + p] = 1 }
    return P
  }

}

