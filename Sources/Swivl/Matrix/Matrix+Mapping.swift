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
  
  public func rowwise(_ closure: (Vector<T>) -> Vector<T>) -> Self {
    var out = [[T]](repeating: [], count: shape.r)
    DispatchQueue.concurrentPerform(iterations: shape.r) { r in
      out[r] = closure(self[r,...]).array
    }
    assert(out.allSatisfy{ $0.count == shape.c })
    return Self(flat: BLAS.vcat(out, shapes: [RowCol](repeating: (1,shape.c), count: shape.r)), shape: shape)
  }
  
  public func rowwise(_ closure: (Vector<T>) -> T) -> Vector<T> {
    var out = [T](repeating: 0, count: rows)
    DispatchQueue.concurrentPerform(iterations: shape.r) { r in
      out[r] = closure(self[r,...])
    }
    return Vector(column: out)
  }
  
  public func colwise(_ closure: (Vector<T>) -> Vector<T>) -> Self {
    var out = [[T]](repeating: [], count: shape.c)
    DispatchQueue.concurrentPerform(iterations: shape.c) { c in
      out[c] = closure(self[...,c]).array
    }
    assert(out.allSatisfy{ $0.count == shape.r })
    return Self(flat: BLAS.hcat(out, shapes: [RowCol](repeating: (shape.r,1), count: shape.c)), shape: shape)
  }
  
  public func colwise(_ closure: (Vector<T>) -> T) -> Vector<T> {
    var out = [T](repeating: 0, count: cols)
    DispatchQueue.concurrentPerform(iterations: shape.c) { c in
      out[c] = closure(self[...,c])
    }
    return Vector(row: out)
  }
  
  
  public func vflip() -> Self {
    self.colwise({ $0.reversed() })
  }
  
  public func hflip() -> Self {
    self.rowwise({ $0.reversed() })
  }
  
  public func rowNormalized() -> Self where T: AccelerateFloatingPoint {
    self.rowwise({ $0 / $0.length })
  }
  
  public func rowLengths() -> Vector<T> where T: AccelerateFloatingPoint {
    self.rowwise({ $0.length })
  }
  
}
