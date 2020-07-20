//  Eig.swift
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

  public static func eig<T>(_ a: Mat<T>, vectors: SingularVectorOutput = .none)
  throws -> (values: [T], leftVectors: Mat<T>?, rightVectors: Mat<T>?) where T: SwivlFloatingPoint {
    precondition(a.shape.r == a.shape.c)
    let left = vectors == .left || vectors == .both
    let right = vectors == .right || vectors == .both

    var jobvl = (left ? ComputeVectors.compute : ComputeVectors.dontCompute).rawValue
    var jobvr = (right ? ComputeVectors.compute : ComputeVectors.dontCompute).rawValue
    var n = __CLPK_integer(a.shape.r)
    var lda = __CLPK_integer(a.shape.r)
    var ldvl = __CLPK_integer(left ? a.shape.r*a.shape.c : 1)
    var ldvr = __CLPK_integer(right ? a.shape.r*a.shape.c : 1)
    var lwork = __CLPK_integer(2*n*n)
    var info = __CLPK_integer()

    var inp = transpose(a)
    var wr = [T](repeating: 0, count: a.shape.r)
    var wi = [T](repeating: 0, count: a.shape.r)
    var vl = [T](repeating: 0, count: left ? a.shape.r*a.shape.c : 1)
    var vr = [T](repeating: 0, count: right ? a.shape.r*a.shape.c: 1)
    var W = [T](repeating: 0, count: Int(lwork))

    if T.self is Double.Type {
      inp.flat.withUnsafeMutableBufferPointer(as: Double.self) { pA in
        wr.withUnsafeMutableBufferPointer(as: Double.self) { pwr in
          wi.withUnsafeMutableBufferPointer(as: Double.self) { pwi in
            vl.withUnsafeMutableBufferPointer(as: Double.self) { pvl in
              vr.withUnsafeMutableBufferPointer(as: Double.self) { pvr in
                W.withUnsafeMutableBufferPointer(as: Double.self) { pW in
                  dgeev_(
                    &jobvl, &jobvr, &n, pA.baseAddress!, &lda,
                    pwr.baseAddress!, pwi.baseAddress!, pvl.baseAddress!, &ldvl,
                    pvr.baseAddress!, &ldvr, pW.baseAddress!, &lwork, &info)
                }}}}}}
    } else {
      inp.flat.withUnsafeMutableBufferPointer(as: Float.self) { pA in
        wr.withUnsafeMutableBufferPointer(as: Float.self) { pwr in
          wi.withUnsafeMutableBufferPointer(as: Float.self) { pwi in
            vl.withUnsafeMutableBufferPointer(as: Float.self) { pvl in
              vr.withUnsafeMutableBufferPointer(as: Float.self) { pvr in
                W.withUnsafeMutableBufferPointer(as: Float.self) { pW in
                  sgeev_(
                    &jobvl, &jobvr, &n, pA.baseAddress!, &lda,
                    pwr.baseAddress!, pwi.baseAddress!, pvl.baseAddress!, &ldvl,
                    pvr.baseAddress!, &ldvr, pW.baseAddress!, &lwork, &info)
                }}}}}}
    }
    if info != 0 {
      throw LinAlgError.eigendecompositionFailure
    }
    return (wr, left ? Mat<T>(vl, a.shape) : nil, right ? Mat<T>(vr, a.shape) : nil)
  }

}

