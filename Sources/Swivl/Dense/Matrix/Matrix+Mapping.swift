//  Matrix+Mapping.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import BLAS

extension Matrix {
  
  public func rowwise<R>(_ closure: (Vector<Scalar>) -> Vector<R>) -> Matrix<R> {
    var out = [[R]](repeating: [], count: shape.r)
    DispatchQueue.concurrentPerform(iterations: shape.r) { r in
      out[r] = closure(self[r,...]).array
    }
    assert(out.allSatisfy{ $0.count == shape.c })
    return Matrix<R>(flat: BLAS.vcat(out, shapes: [RowCol](repeating: (1,shape.c), count: shape.r)), shape: shape)
  }
  
  public func rowwise<R>(_ closure: (Vector<Scalar>) -> R) -> Vector<R> {
    var out = [R](repeating: 0, count: rows)
    DispatchQueue.concurrentPerform(iterations: shape.r) { r in
      out[r] = closure(self[r,...])
    }
    return Vector(column: out)
  }
  
  public func colwise<R>(_ closure: (Vector<Scalar>) -> Vector<R>) -> Matrix<R> {
    var out = [[R]](repeating: [], count: shape.c)
    DispatchQueue.concurrentPerform(iterations: shape.c) { c in
      out[c] = closure(self[...,c]).array
    }
    assert(out.allSatisfy{ $0.count == shape.r })
    return Matrix<R>(flat: BLAS.hcat(out, shapes: [RowCol](repeating: (shape.r,1), count: shape.c)), shape: shape)
  }
  
  public func colwise<R>(_ closure: (Vector<Scalar>) -> R) -> Vector<R> {
    var out = [R](repeating: 0, count: cols)
    DispatchQueue.concurrentPerform(iterations: shape.c) { c in
      out[c] = closure(self[...,c])
    }
    return Vector(row: out)
  }
  
  
  public func vflip() -> Self {
    self.colwise({ $0.reversed })
  }
  
  public func hflip() -> Self {
    self.rowwise({ $0.reversed })
  }
  
  public func rowNormalized() -> Self where Scalar: AccelerateFloatingPoint {
    self.rowwise({ $0 / $0.length })
  }
  
  public func rowLengths() -> Vector<Scalar> where Scalar: AccelerateFloatingPoint {
    self.rowwise({ $0.length })
  }
  
}
