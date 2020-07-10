//  BLASMatrixDecompositions.swift
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
  
//  MARK: Cholesky

  public static func chol<T>(_ a: [T], _ shape: RowCol, type: TriangularType = .upper) throws -> [T]
  where T: AccelerateFloatingPoint {
    precondition(shape.r == shape.c, "Matrix must be symmetric")
    var uplo = Int8(Character("U").asciiValue!)
    var n = __CLPK_integer(shape.r)
    var out = a
    var lda = __CLPK_integer(shape.r)
    var info = __CLPK_integer()
    
    if T.self is Double.Type {
      _ = out.withUnsafeMutableBufferPointer(as: Double.self) { ptr in
        dpotrf_(&uplo, &n, ptr.baseAddress!, &lda, &info)
      }
    } else {
      _ = out.withUnsafeMutableBufferPointer(as: Float.self) { ptr in
        spotrf_(&uplo, &n, ptr.baseAddress!, &lda, &info)
      }
    }
    if info > 0 { throw BLASError.invalidMatrix("Matrix must be positive-definite") }
    (out, _) = BLAS.triangle(out, shape, type: type)
    return out
  }

  
//  MARK: LU
  
  public static func LU<T>(_ a: [T], _ shape: RowCol, output: LUOutput = .LU)
    -> (L: ([T], RowCol), U: ([T], RowCol), P: [T]?, Q: [T]?) where T: AccelerateFloatingPoint {
    precondition(shape.r == shape.c, "Only square matrices are supported")

    var m = __CLPK_integer(shape.r)
    var n = __CLPK_integer(shape.c)
    var lda = __CLPK_integer(shape.r)
    var ipiv = [__CLPK_integer](repeating: 0, count: Swift.min(shape.r,shape.c))
    var jpiv = [__CLPK_integer](repeating: 0, count: output == .LUPQ ? Swift.min(shape.r, shape.c) : 1)
    var info = __CLPK_integer()
    var out = BLAS.transpose(a, shape)
    
    if T.self is Double.Type {
      if output != .LUPQ {
        _ = out.withUnsafeMutableBufferPointer(as: Double.self) { ptr in
          dgetrf_(&m, &n, ptr.baseAddress!, &lda, &ipiv, &info)
        }
      } else {
        _ = out.withUnsafeMutableBufferPointer(as: Double.self) { ptr in
          dgetc2_(&n, ptr.baseAddress!, &lda, &ipiv, &jpiv, &info)
        }
      }
    } else {
      if output != .LUPQ {
        _ = out.withUnsafeMutableBufferPointer(as: Float.self) { ptr in
          sgetrf_(&m, &n, ptr.baseAddress!, &lda, &ipiv, &info)
        }
      } else {
        _ = out.withUnsafeMutableBufferPointer(as: Float.self) { ptr in
          sgetc2_(&n, ptr.baseAddress!, &lda, &ipiv, &jpiv, &info)
        }
      }
    }
    var P: [T] = makePermutationMatrix(ipiv)
    P = BLAS.transpose(P, shape)
    var (L, shapeL) = BLAS.triangle(BLAS.transpose(out, shape), shape, type: .lower, diagonal: -1)
    L = BLAS.add(L, BLAS.eye(shape.r))
    let (U, shapeU) = BLAS.triangle(BLAS.transpose(out, shape), shape, type: .upper)

    switch output {
    case .LU:
      (L, _) = BLAS.multiplyMatrix(P, shape, L, shape)
      return (L: (L, shapeL), U: (U, shapeU), P: nil, Q: nil)
    case .LUP:
      return (L: (L, shapeL), U: (U, shapeU), P: P, Q: nil)
    case .LUPQ:
      let Q: [T] = makePermutationMatrix(jpiv)
      return (L: (L, shapeL), U: (U, shapeU), P: P, Q: Q)
    }
  }
  
  static func makePermutationMatrix<T>(_ piv: [Int32]) -> [T] where T: AccelerateFloatingPoint {
    let piv = piv.map{ $0 - 1 }
    var swaps = Array(0..<piv.count)
    (0..<piv.count).forEach { i in
      if (piv[i] != -1 && piv[i] != Int32(i)) { swaps.swapAt(i, Int(piv[i])) }
    }
    var P = [T](repeating: 0, count: piv.count * piv.count)
    swaps.enumerated().forEach { i, p in P[i*piv.count + p] = 1 }
    return P
  }
  
  public enum LUOutput {
    case LU
    case LUP
    case LUPQ
  }
  
  
//  MARK: QR
  //  TODO: STUB
  public static func QR<T>(_ a: [T], _ shape: RowCol) -> (Q: [T], R: [T]) where T: AccelerateFloatingPoint {
    return ([],[])
  }

  
//  MARK: Eigen
  
  public static func eig<T>(
    _ a: [T], _ shape: RowCol,
    vectors: EigenvectorOutput = .none
  ) -> (values: [T], leftVectors: [T]?, rightVectors: [T]?) where T: AccelerateFloatingPoint {
    precondition(shape.r == shape.c)
    let left = vectors == .left || vectors == .both
    let right = vectors == .right || vectors == .both
    
    var joblv = Int8(Character(left ? "V" : "N").asciiValue!)
    var jobrv = Int8(Character(right ? "V" : "N").asciiValue!)
    var n = __CLPK_integer(shape.r)
    var lda = __CLPK_integer(shape.r)
    var lvl = __CLPK_integer(left ? shape.r*shape.c : 1)
    var lvr = __CLPK_integer(right ? shape.r*shape.c : 1)
    var lwork = __CLPK_integer(2*shape.r*shape.c)
    var info = __CLPK_integer()
    
    if T.self is Double.Type {
      var inp: [__CLPK_doublereal] = a as! [Double]
      var wr = [__CLPK_doublereal](repeating: 0, count: shape.r)
      var wi = [__CLPK_doublereal](repeating: 0, count: shape.r)
      var vl = [__CLPK_doublereal](repeating: 0, count: left ? shape.r*shape.c : 1)
      var vr = [__CLPK_doublereal](repeating: 0, count: right ? shape.r*shape.c: 1)
      var work = [__CLPK_doublereal](repeating: 0, count: 2*shape.r*shape.c)
      dgeev_(&joblv, &jobrv, &n, &inp, &lda, &wr, &wi, &vl, &lvl, &vr, &lvr, &work, &lwork, &info)
      return (wr as! [T], nil, (vr as! [T]))
    } else {
      var inp: [__CLPK_real] = a as! [Float]
      var wr = [__CLPK_real](repeating: 0, count: shape.r)
      var wi = [__CLPK_real](repeating: 0, count: shape.r)
      var vl = [__CLPK_real](repeating: 0, count: left ? shape.r*shape.c : 1)
      var vr = [__CLPK_real](repeating: 0, count: right ? shape.r*shape.c: 1)
      var work = [__CLPK_real](repeating: 0, count: 2*shape.r*shape.c)
      sgeev_(&joblv, &jobrv, &n, &inp, &lda, &wr, &wi, &vl, &lvl, &vr, &lvr, &work, &lwork, &info)
      return (wr as! [T], nil, (vr as! [T]))
    }
  }
  
  public enum EigenvectorOutput {
    case left
    case right
    case both
    case none
  }
  

  //  MARK: SVD
  //  TODO: STUB
  public static func SVD<T>(_ a: [T], _ shape: RowCol) -> (Q: [T], R: [T]) where T: AccelerateFloatingPoint {
    return ([],[])
  }
  
}
