//  VectorProtocol.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Accelerate
import BLAS


public protocol VectorProtocol where Element: Numeric {
  associatedtype Element

  // MARK: - Arithmetic: Vector-Vector

  /// Perform vector addition.
  ///
  /// Alternatively, `add(lhs, rhs)` can be executed with `a + b`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: elementwise vector sum of a and b
  static func add(_ lhs: Self , _ rhs: Self) -> Self

  
  /// Perform vector subtraction.
  ///
  /// Alternatively, `subtract(lhs, rhs)` can be executed with `a - b`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: elementwise vector difference of a and b
  static func subtract(_ lhs: Self, _ rhs: Self) -> Self

  
  /// Perform vector multiplication.
  ///
  /// Alternatively, `multiply(lhs, rhs)` can be executed with `a .* b`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: elementwise vector product of a and b
  static func multiply(_ lhs: Self, _ rhs: Self) -> Self


  /// Perform vector right division.
  ///
  /// Alternatively, `divide(lhs, rhs)` can be executed with `a ./ b`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: result of elementwise division of a by b
  static func divide(_ lhs: Self, _ rhs: Self) -> Self


//  /// Perform vector left division.
//  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///     - lhs: left vector
//  ///     - rhs: right vector
//  /// - Returns: result of elementwise division of b by a
//  static func ldivide(_ lhs: Self, _ rhs: Self) -> Self

  
  /// Perform vector dot product operation.
  ///
  /// Alternatively, `dot(lhs, rhs)` can be executed with `a * b`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: dot product of a and b
  static func dot(_ lhs: Self, _ rhs: Self) -> Element


  // MARK: - Arithmetic operations on vector and scalar

  /// Perform vector and scalar addition.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector addition is performed.
  ///
  /// Alternatively, `add(lhs, rhs)` can be executed with `a + b`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: elementwise sum of vector a and scalar b
  static func add(_ lhs: Self, _ rhs: Element) -> Self

  
  /// Perform vector and scalar subtraction.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector subtraction is performed.
  ///
  /// Alternatively, `subtract(lhs, rhs)` can be executed with `a - b`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: elementwise difference of vector a and scalar b
  static func subtract(_ lhs: Self, _ rhs: Element) -> Self


  /// Perform vector and scalar multiplication.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector multiplication is performed.
  ///
  /// Alternatively, `multiply(lhs, rhs)` can be executed with `a .* b`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: elementwise product of vector a and scalar b
  static func multiply(_ lhs: Self, _ rhs: Element) -> Self


  /// Perform vector and scalar right division.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector right division is performed.
  ///
  /// Alternatively, `divide(lhs, rhs)` can be executed with `a ./ b`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: result of elementwise division of vector a by scalar b
  static func divide(_ lhs: Self, _ rhs: Element) -> Self

  
//  /// Perform scalar and vector right division.
//  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  /// and elementwise vector right division is performed.
//  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///     - lhs: scalar
//  ///     - rhs: vector
//  /// - Returns: result of elementwise division of scalar a by vector b
//  static func divide<Scalar>(_ lhs: Scalar, _ rhs: Self) -> Self where Scalar: Numeric

  
//  /// Perform vector and scalar left division.
//  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  /// and elementwise vector left division is performed.
//  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///     - lhs: vector
//  ///     - rhs: scalar
//  /// - Returns: result of elementwise division of scalar b by vector a
//  static func ldivide<Scalar>(_ lhs: Self, _ rhs: Scalar) -> Self where Scalar: Numeric

  
//  /// Perform scalar and vector left division.
//  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  /// and elementwise vector left division is performed.
//  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///     - lhs: scalar
//  ///     - rhs: vector
//  /// - Returns: result of elementwise division of vector b by scalar a
//  static func ldivide<Scalar>(_ lhs: Scalar, _ rhs: Self) -> Self where Scalar: Numeric
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

//  /// Absolute value of vector.
//  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///     - lhs: vector
//  /// - Returns: vector of absolute values of elements of vector a
//  func abs(_ lhs: Self) -> Self


  /// Negation of vector.
  ///
  /// Alternatively, `negate(a)` can be executed with `-a`.
  ///
  /// - Parameters
  ///     - lhs: vector
  /// - Returns: vector of negated values of elements of vector a
  static func negate(_ lhs: Self) -> Self

//  /// Threshold function on vector.
//  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///     - lhs: vector
//  /// - Returns: vector with values less than certain value set to 0
//  ///            and keeps the value otherwise
//  static func thr<Scalar>(_ lhs: Self, _ t: Scalar) -> Self where Scalar: Numeric

  
// MARK: Vector Creation
  
  /// Create a vector of zeros.
  ///
  /// - Parameters:
  ///    - count: number of elements
  /// - Returns: zeros vector of specified size
  static func zeros(_ count: Int) -> Self

  /// Create a vector of ones.
  ///
  /// - Parameters:
  ///    - count: number of elements
  /// - Returns: ones vector of specified size
  static func ones(_ count: Int) -> Self

//  /// Create a vector of uniformly distributed on [0, 1) interval random values.
//  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///    - count: number of elements
//  /// - Returns: random values vector of specified size
//  static func rand(_ count: Int) -> Self
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///    - count: number of elements
//  /// - Returns: random values vector of specified size
//  static func randn(_ count: Int) -> Self

  
}


extension VectorProtocol {

  static func add(_ a: Element, _ b: Self) -> Self {
    return Self.add(b, a)
  }

  static func subtract(_ a: Element, _ b: Self) -> Self {
    return Self.negate(Self.subtract(b, a))
  }

  static func multiply(_ a: Element, _ b: Self) -> Self {
    return Self.multiply(b, a)
  }

  
  // MARK: - Operators: Vector-Vector

  /// Perform vector addition.
  ///
  /// Alternatively, `a + b` can be executed with `add(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: elementwise vector sum of a and b
  static func + (_ lhs: Self , _ rhs: Self) -> Self {
    Self.add(lhs, rhs)
  }

  
  /// Perform vector subtraction.
  ///
  /// Alternatively, `a - b` can be executed with `subtract(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: elementwise vector difference of a and b
  static func - (_ lhs: Self, _ rhs: Self) -> Self {
    Self.subtract(lhs, rhs)
  }

  
  /// Perform vector multiplication.
  ///
  /// Alternatively, `a .* b` can be executed with `multiply(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: elementwise vector product of a and b
  static func .* (_ lhs: Self, _ rhs: Self) -> Self {
    Self.multiply(lhs, rhs)
  }


  /// Perform vector right division.
  ///
  /// Alternatively, `a ./ b` can be executed with `divide(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: result of elementwise division of a by b
  static func ./ (_ lhs: Self, _ rhs: Self) -> Self {
    Self.divide(lhs, rhs)
  }

//  /// Perform vector left division.
//  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///     - lhs: left vector
//  ///     - rhs: right vector
//  /// - Returns: result of elementwise division of b by a
//  static func ./. (_ lhs: Self, _ rhs: Self) -> Self {
//    Self.ldivide(lhs, rhs)
//  }

  
  /// Perform vector dot product operation.
  ///
  /// Alternatively, `a * b` can be executed with `dot(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: dot product of a and b
  static func * (_ lhs: Self, _ rhs: Self) -> Element {
    Self.dot(lhs, rhs)
  }
  
  
//  MARK: Operators: Vector-Scalar

  /// Perform vector and scalar addition.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector addition is performed.
  ///
  /// Alternatively, `a + b` can be executed with `add(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: elementwise sum of vector a and scalar b
  static func + (_ lhs: Self, _ rhs: Element) -> Self {
    Self.add(lhs, rhs)
  }
  /// Perform scalar and vector addition.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector addition is performed.
  ///
  /// Alternatively, `a + b` can be executed with `add(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: scalar
  ///     - rhs: vector
  /// - Returns: elementwise sum of scalar a and vector b
  static func + (_ lhs: Element, _ rhs: Self) -> Self {
    Self.add(lhs, rhs)
  }

  
  /// Perform vector and scalar subtraction.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector subtraction is performed.
  ///
  /// Alternatively, `a - b` can be executed with `subtract(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: elementwise difference of vector a and scalar b
  static func - (_ lhs: Self, _ rhs: Element) -> Self {
    Self.subtract(lhs, rhs)
  }
  /// Perform scalar and vector subtraction.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector addition is performed.
  ///
  /// Alternatively, `a - b` can be executed with `subtract(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: scalar
  ///     - rhs: vector
  /// - Returns: elementwise difference of scalar a and vector b
  static func - (_ lhs: Element, _ rhs: Self) -> Self {
    Self.subtract(lhs, rhs)
  }

  
  /// Perform vector and scalar multiplication.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector multiplication is performed.
  ///
  /// Alternatively, `a .* b` can be executed with `multiply(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: elementwise product of vector a and scalar b
  static func .* (_ lhs: Self, _ rhs: Element) -> Self {
    Self.multiply(lhs, rhs)
  }
  /// Perform scalar and vector multiplication.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector multiplication is performed.
  ///
  /// Alternatively, `a .* b` can be executed with `multiply(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: scalar
  ///     - rhs: vector
  /// - Returns: elementwise product of scalar a and vector b
  static func .* (_ lhs: Element, _ rhs: Self) -> Self {
    Self.multiply(lhs, rhs)
  }
  /// Perform vector and scalar multiplication.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector multiplication is performed.
  ///
  /// Alternatively, `a * b` can be executed with `multiply(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: elementwise product of vector a and scalar b
  static func * (_ lhs: Self, _ rhs: Element) -> Self {
    Self.multiply(lhs, rhs)
  }
  /// Perform scalar and vector multiplication.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector multiplication is performed.
  ///
  /// Alternatively, `a * b` can be executed with `multiply(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: scalar
  ///     - rhs: vector
  /// - Returns: elementwise product of scalar a and vector b
  static func * (_ lhs: Element, _ rhs: Self) -> Self {
    Self.multiply(lhs, rhs)
  }

  
  /// Perform vector and scalar right division.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector right division is performed.
  ///
  /// Alternatively, `a ./ b` can be executed with `divide(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: result of elementwise division of vector a by scalar b
  static func ./ (_ lhs: Self, _ rhs: Element) -> Self {
    Self.divide(lhs, rhs)
  }
  /// Perform vector and scalar right division.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector right division is performed.
  ///
  /// Alternatively, `a / b` can be executed with `divide(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: result of elementwise division of vector a by scalar b
  static func / (_ lhs: Self, _ rhs: Element) -> Self {
    Self.divide(lhs, rhs)
  }

//  /// Perform scalar and vector right division.
//  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  /// and elementwise vector right division is performed.
//  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///     - lhs: scalar
//  ///     - rhs: vector
//  /// - Returns: result of elementwise division of scalar a by vector b
//  static func ./ <Scalar> (_ lhs: Scalar, _ rhs: Self) -> Self where Scalar: Numeric {
//    Self.divide(lhs, rhs)
//  }


//  /// Perform vector and scalar left division.
//  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  /// and elementwise vector left division is performed.
//  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///     - lhs: vector
//  ///     - rhs: scalar
//  /// - Returns: result of elementwise division of scalar b by vector a
//  static func ./. <Scalar> (_ lhs: Self, _ rhs: Scalar) -> Self where Scalar: Numeric {
//    Self.ldivide(lhs, rhs)
//  }
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  /// and elementwise vector left division is performed.
//  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
  ///     - lhs: scalar
//  ///     - rhs: vector
//  /// - Returns: result of elementwise division of vector b by scalar a
//  static func ./. <Scalar> (_ lhs: Scalar, _ rhs: Self) -> Self where Scalar: Numeric {
//    Self.ldivide(lhs, rhs)
//  }

  /// Negation of vector.
  ///
  /// Alternatively, `-a` can be executed with `negate(a)`.
  ///
  /// - Parameters
  ///     - lhs: vector
  /// - Returns: vector of negated values of elements of vector a
  static prefix func - (_ lhs: Self) -> Self {
    Self.negate(lhs)
  }
}
