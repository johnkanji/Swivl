//  SparseSolveLU.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SuperLU

extension LinAlg {

  public static func solveLU<T>(_ a: SpMat<T>, _ b: [T]) -> [T] where T: SwivlFloatingPoint {
    let m = Int32(a.shape.r)
    let n = Int32(a.shape.c)
    let nnz = Int32(a.v.count)
    var v = a.v
    var ri = a.ri
    var cs = a.cs.map(Int32.init)
    var rhs = b

    var A = SuperMatrix()
    var B = SuperMatrix()
    var L = SuperMatrix()
    var U = SuperMatrix()
    var opt = superlu_options_t()
    set_default_options(&opt)
    var stat = SuperLUStat_t()
    StatInit(&stat)
    var perm_r = [Int32](repeating: 0, count: a.shape.r)
    var perm_c = [Int32](repeating: 0, count: a.shape.c)
    var info = Int32()

    v.withUnsafeMutableBufferPointer(as: Double.self) { pV in
      rhs.withUnsafeMutableBufferPointer(as: Double.self) { pB in
        dCreate_CompCol_Matrix(&A, m, n, nnz, pV.baseAddress!, &ri, &cs, SLU_NC, SLU_D, SLU_GE)
        dCreate_Dense_Matrix(&B, m, 1, pB.baseAddress!, m, SLU_DN, SLU_D, SLU_GE)
      }}
    dgssv(&opt, &A, &perm_c, &perm_r, &L, &U, &B, &stat, &info)
    let store = B.Store.assumingMemoryBound(to: DNformat.self)
    let x = store.pointee.nzval.assumingMemoryBound(to: T.self)
    return Array(UnsafeBufferPointer(start: x, count: b.count))
  }

}
