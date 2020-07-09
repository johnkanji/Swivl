//  BLASMatrixMap.swift
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
  
  public static func mapRows<T>(_ a: [T], _ shape: RowCol, _ body: (UnsafeBufferPointer<T>) -> T) -> [T]
  where T:AccelerateNumeric {
    var c = [T](repeating: 0, count: shape.r)
    c.withUnsafeMutableBufferPointer { ptrC in
      a.withUnsafeBufferPointer { ptrA in
        DispatchQueue.concurrentPerform(iterations: shape.r) { r in
          let ptrR = UnsafeBufferPointer(start: ptrA.baseAddress! + r*shape.c, count: shape.c)
          ptrC[r] = body(ptrR)
        }
      }
    }
    return c
  }
  
  public static func mapRowsInPlace<T>(_ a: [T], _ shape: RowCol, _ body: (UnsafeMutableBufferPointer<T>) -> ()) -> [T]
  where T:AccelerateNumeric {
    var c = a
    c.withUnsafeMutableBufferPointer { ptrC in
      DispatchQueue.concurrentPerform(iterations: shape.r) { r in
        body(UnsafeMutableBufferPointer<T>(start: ptrC.baseAddress! + r*shape.c, count: shape.c))
      }
    }
    return c
  }
  
  public static func mapRows<T>(_ a: [T], _ shape: RowCol, _ body: (UnsafePointer<T>) -> [T]) -> [T]
  where T:AccelerateNumeric {
    var c = a
    a.withUnsafeBufferPointer { ptrA in
      DispatchQueue.concurrentPerform(iterations: shape.r) { r in
        let row = ptrA.baseAddress! + r*shape.c
        BLAS.setBlock(&c, shape, body(row), (1,shape.c), startIndex: RowCol(r, 0))
      }
    }
    return c
  }
  
  public static func mapCols<T>(_ a: [T], _ shape: RowCol, _ body: (UnsafeBufferPointer<T>) -> T) -> [T]
  where T:AccelerateNumeric {
    let b = BLAS.transpose(a, shape)
    var c = [T](repeating: 0, count: shape.c)
    c.withUnsafeMutableBufferPointer { ptrC in
      b.withUnsafeBufferPointer { ptrB in
        DispatchQueue.concurrentPerform(iterations: shape.c) { c in
          let ptrR = UnsafeBufferPointer(start: ptrB.baseAddress! + c*shape.r, count: shape.r)
          ptrC[c] = body(ptrR)
        }
      }
    }
    return c
  }
  
  public static func mapCols<T>(_ a: [T], _ shape: RowCol, _ body: (UnsafePointer<T>) -> [T]) -> [T]
  where T:AccelerateNumeric {
    let a = BLAS.transpose(a, shape)
    return BLAS.transpose(mapRows(a, shape, body), (shape.c, shape.r))
  }
  
}
