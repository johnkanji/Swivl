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
import CLapacke

extension BLAS {
  
//  MARK: Cholesky

  public static func chol<T>(_ a: [T], _ shape: RowCol, triangle: TriangularType = .upper) throws -> [T]
  where T: AccelerateFloatingPoint {
    precondition(shape.r == shape.c, "Matrix must be symmetric")
    var uplo = triangle.rawValue
    var n = __CLPK_integer(shape.r)
    var out = transpose(a, shape)
    var lda = __CLPK_integer(shape.r)
    var info = __CLPK_integer()
    
    if T.self is Double.Type {
      out.withUnsafeMutableBufferPointer(as: Double.self) { ptr in
        Accelerate.dpotrf_(&uplo, &n, ptr.baseAddress!, &lda, &info)
      }
    } else {
      out.withUnsafeMutableBufferPointer(as: Float.self) { ptr in
        Accelerate.spotrf_(&uplo, &n, ptr.baseAddress!, &lda, &info)
      }
    }
    if info > 0 { throw BLASError.invalidMatrix("Matrix must be positive-definite") }
    (out, _) = BLAS.triangle(transpose(out, shape), shape, triangle)
    return out
  }

  
//  MARK: LU
  
  public static func LU<T>(_ a: [T], _ shape: RowCol, output: LUOutput = .LU)
    -> (L: ([T], RowCol), U: ([T], RowCol), P: [T]?, Q: [T]?) where T: AccelerateFloatingPoint {
    precondition(shape.r == shape.c, "Only square matrices are supported")

    var m = Int32(shape.r)
    var n = Int32(shape.c)
    var lda = Int32(shape.r)
    var ipiv = [Int32](repeating: 0, count: Swift.min(shape.r,shape.c))
    var jpiv = [Int32](repeating: 0, count: output == .LUPQ ? Swift.min(shape.r, shape.c) : 1)
    var info = Int32()
    var out = BLAS.transpose(a, shape)
    
    if T.self is Double.Type {
      if output != .LUPQ {
        out.withUnsafeMutableBufferPointer(as: Double.self) { ptr in
          Accelerate.dgetrf_(&m, &n, ptr.baseAddress!, &lda, &ipiv, &info)
        }
      } else {
        _ = out.withUnsafeMutableBufferPointer(as: Double.self) { ptr in
          dgetc2_(&n, ptr.baseAddress!, &lda, &ipiv, &jpiv, &info)
        }
      }
    } else {
      if output != .LUPQ {
        out.withUnsafeMutableBufferPointer(as: Float.self) { ptr in
          Accelerate.sgetrf_(&m, &n, ptr.baseAddress!, &lda, &ipiv, &info)
        }
      } else {
        _ = out.withUnsafeMutableBufferPointer(as: Float.self) { ptr in
          sgetc2_(&n, ptr.baseAddress!, &lda, &ipiv, &jpiv, &info)
        }
      }
    }
    var P: [T] = makePermutationMatrix(ipiv)
    P = BLAS.transpose(P, shape)
    var (L, shapeL) = BLAS.triangle(BLAS.transpose(out, shape), shape, .lower, diagonal: -1)
    L = BLAS.add(L, BLAS.eye(shape.r))
    let (U, shapeU) = BLAS.triangle(BLAS.transpose(out, shape), shape, .upper)

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
  
  
//  MARK: LDL
  
  public static func LDL<T>(_ a: [T], _ shape: RowCol, triangle: TriangularType = .lower)
  -> (L: [T], D: [T]) where T: AccelerateFloatingPoint {
    precondition(shape.r == shape.c, "Only square matrices are supported")
    var uplo = triangle.rawValue
    var n = __CLPK_integer(shape.r)
    var lda = __CLPK_integer(shape.r)
    var out = transpose(a, shape)
    var ipiv = [__CLPK_integer](repeating: 0, count: shape.r)
    var lwork = __CLPK_integer(2*shape.r*shape.c)
    var info = __CLPK_integer()
    
    if T.self is Double.Type {
      var work = [Double](repeating: 0, count: 2*shape.r*shape.c)
      out.withUnsafeMutableBufferPointer(as: Double.self) { p in
        Accelerate.dsytrf_(&uplo, &n, p.baseAddress!, &lda, &ipiv, &work, &lwork, &info)
      }
    } else {
      var work = [Float](repeating: 0, count: 2*shape.r*shape.c)
      out.withUnsafeMutableBufferPointer(as: Float.self) { p in
        Accelerate.ssytrf_(&uplo, &n, p.baseAddress!, &lda, &ipiv, &work, &lwork, &info)
      }
    }
    out = transpose(out, shape)
    //  TODO: Parse output
    print(out)
    print(ipiv)
    return ([], [])
  }
  
  
//  MARK: QR

  public static func QR<T>(_ a: [T], _ shape: RowCol) -> (Q: [T], R: [T]) where T: AccelerateFloatingPoint {
    var m1 = __CLPK_integer(shape.r)
    var m2 = __CLPK_integer(shape.r)
    var n = __CLPK_integer(shape.c)
    var k = __CLPK_integer(shape.c)
    var lda = __CLPK_integer(shape.r)
    var lwork = __CLPK_integer(100*shape.c)
    var info = __CLPK_integer()
    var out = transpose(a, shape)
    var tau = [T](repeating: 0, count: Swift.min(shape.r, shape.c))
    var work = [T](repeating: 0, count: Int(lwork))

    if T.self is Double.Type {
      out.withUnsafeMutableBufferPointer(as: Double.self) { pO in
      tau.withUnsafeMutableBufferPointer(as: Double.self) { pT in
      work.withUnsafeMutableBufferPointer(as: Double.self) { pW in
        Accelerate.dgeqrf_(&m1, &n, pO.baseAddress!, &lda, pT.baseAddress!, pW.baseAddress!, &lwork, &info)
        Accelerate.dorgqr_(&m1, &m2, &k, pO.baseAddress!, &lda, pT.baseAddress!, pW.baseAddress!, &lwork, &info)
      }}}
    } else {
      out.withUnsafeMutableBufferPointer(as: Float.self) { pO in
      tau.withUnsafeMutableBufferPointer(as: Float.self) { pT in
      work.withUnsafeMutableBufferPointer(as: Float.self) { pW in
        Accelerate.sgeqrf_(&m1, &n, pO.baseAddress!, &lda, pT.baseAddress!, pW.baseAddress!, &lwork, &info)
        Accelerate.sorgqr_(&m1, &m2, &k, pO.baseAddress!, &lda, pT.baseAddress!, pW.baseAddress!, &lwork, &info)
      }}}
    }
    out = transpose(out, (shape.c, shape.r))
    let Q = block(out, shape, startIndex: (0,0), shapeOut: (shape.r, shape.r))
    let (R, _) = triangle(out, shape, .upper)
    return (Q, R)
  }

  
//  MARK: Eigen
  
  public static func eig<T>(
    _ a: [T], _ shape: RowCol, vectors: SingularVectorOutput = .none
  ) throws -> (values: [T], leftVectors: [T]?, rightVectors: [T]?) where T: AccelerateFloatingPoint {
    precondition(shape.r == shape.c)
    let left = vectors == .left || vectors == .both
    let right = vectors == .right || vectors == .both
    
    let jobvl = (left ? ComputeVectors.compute : ComputeVectors.dontCompute).rawValue
    let jobvr = (right ? ComputeVectors.compute : ComputeVectors.dontCompute).rawValue
    let n = Int32(shape.r)
    let lda = Int32(shape.r)
    let ldvl = Int32(left ? shape.r*shape.c : 1)
    let ldvr = Int32(right ? shape.r*shape.c : 1)
    var info = Int32()
    
    if T.self is Double.Type {
      var inp = a as! [Double]
      var wr = [Double](repeating: 0, count: shape.r)
      var wi = [Double](repeating: 0, count: shape.r)
      var vl = [Double](repeating: 0, count: left ? shape.r*shape.c : 1)
      var vr = [Double](repeating: 0, count: right ? shape.r*shape.c: 1)
      info = LAPACKE_dgeev(rowMajor, jobvl, jobvr, n, &inp, lda, &wr, &wi, &vl, ldvl, &vr, ldvr)
      if info != 0 {
        throw BLASError.eigendecompositionFailure
      }
      return (wr as! [T], left ? (vl as! [T]) : nil, right ? (vr as! [T]) : nil)
    } else {
      var inp = a as! [Float]
      var wr = [Float](repeating: 0, count: shape.r)
      var wi = [Float](repeating: 0, count: shape.r)
      var vl = [Float](repeating: 0, count: left ? shape.r*shape.c : 1)
      var vr = [Float](repeating: 0, count: right ? shape.r*shape.c: 1)
      info = LAPACKE_sgeev(rowMajor, jobvl, jobvr, n, &inp, lda, &wr, &wi, &vl, ldvl, &vr, ldvr)
      if info != 0 {
        throw BLASError.eigendecompositionFailure
      }
      return (wr as! [T], left ? (vl as! [T]) : nil, right ? (vr as! [T]) : nil)
    }
  }
  

//  MARK: SVD
  //  TODO: STUB
  public static func SVD<T>(_ a: [T], _ shape: RowCol, vectors: SingularVectorOutput = .none)
  throws -> (values: [T], leftVectors: [T]?, rightVectors: [T]?) where T: AccelerateFloatingPoint {
    return ([], nil, nil)
  }
  
  
//  MARK: Helpers
  
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
  
}
