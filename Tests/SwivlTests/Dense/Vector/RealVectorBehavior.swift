//  RealVectorBehavior.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Quick
import Nimble
import Swivl

class RealVectorBehavior<T>: Behavior<Vector<T>> where T: SwivlFloatingPoint {
  override class func spec(_ context: @escaping () -> Vector<T>) {
    var vec: Vector<T>!
    var other: Vector<T>!
    var empty: Vector<T>!
    beforeEach {
      vec = context()
      empty = []
    }

    func err(_ actual: T, _ expected: T) -> T {
      abs(actual - expected)
    }

    func maxErr(_ actual: [T], _ expected: [T]) -> T {
      zip(actual, expected).map { abs($0 - $1) }.max()!
    }

    describe("a real vector") {

      describe("arithmetic") {
        beforeEach {
          other = [-8,7,9,-6,5]
        }

        it("can be divided elementwise") {
          let error = maxErr((other ./ vec).array, [-8.0, 3.5, 3.0, -1.5, 1.0])
          expect(error).to(beLessThan(T.approximateEqualityTolerance))
        }
        it("can be divided by a scalar") {
          let error = maxErr((vec ./ 2).array, [0.5, 1.0, 1.5, 2.0, 2.5])
          expect(error).to(beLessThan(T.approximateEqualityTolerance))
        }
      }

      describe("geometry") {
        beforeEach {
          other = [-8,7,9,-6,5]
        }

        it("has length equal to it's 2-norm") {
          let v: T = vec.length
          expect(err(v, 7.4161984871)).to(beLessThan(T.approximateEqualityTolerance))
        }
        it("can be normalized") {
          expect(err(vec.normalized.length, 1)).to(beLessThan(T.approximateEqualityTolerance))
        }
        it("can compute distance to a point") {
          let distance = vec.dist(to: other)
          expect(err(distance, 15.556349186104045)).to(beLessThan(T.approximateEqualityTolerance))
        }
      }

      describe("creation") {
        it("can be initialized to a linear interpolation") {
          let v = Vector<T>.linear(0, 1, 5)
          expect(v.array).to(equal([0.0, 0.25, 0.5, 0.75, 1.0]))
        }
      }

    }
  }
}
