//  VectorBehavior.swift
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

class VectorBehavior<T>: Behavior<Vector<T>> where T: SwivlNumeric {
  override class func spec(_ context: @escaping () -> Vector<T>) {
    var vec: Vector<T>!
    var other: Vector<T>!
    var empty: Vector<T>!
    
    beforeEach {
      vec = context()
      empty = []
    }

    describe("a vector") {

      it("has count equal to it's array") {
        expect(vec.count).to(equal(vec.array.count))
      }
      it("can be indexed") {
        expect(vec[2]).to(equal(3))
      }

//      MARK: Initializers

      describe("initialization") {
        it("can be initialized to an empty vector") {
          let v = Vector<T>()
          expect(v).to(equal(empty))
        }
        it("can be initialized with an array") {
          let v = Vector<T>([1,2,3,4,5])
          expect(v.array).to(equal([1,2,3,4,5]))
        }
        it("can be initialized with an array literal") {
          let v: Vector<T> = [1,2,3,4,5]
          expect(v.array).to(equal([1,2,3,4,5]))
        }
      }

      describe("concatenation") {
        beforeEach {
          other = [-8,7,9,-6,5]
        }
        it("has count equal to the sums of the counts") {
          expect((vec & other).count).to(equal(10))
        }
        it("concatenates the two arrays") {
          expect((vec & other).array).to(equal([1,2,3,4,5,-8,7,9,-6,5]))
        }
      }


//      MARK: Unary Operators

      describe("unary operators") {
        it("can be negated") {
          expect((-vec).array).to(equal([-1,-2,-3,-4,-5]))
        }
        describe("abs") {
          it("sets each entry to it's absolute value") {
            expect(other.abs()).to(equal([8,7,9,6,5]))
          }
          it("leaves a positive vector unchanged") {
            expect(vec.abs()).to(equal(vec))
          }
        }
        describe("max") {
          it("returns the max element") {
            expect(other.max()!).to(equal(9))
          }
          it("returns nil if the vector is empty") {
            expect(empty.max()).to(beNil())
          }
        }
        describe("max index") {
          it("returns the index of the max element") {
            expect(other.maxIndex()!).to(equal(2))
          }
          it("returns nil if the vector is empty") {
            expect(empty.maxIndex()).to(beNil())
          }
        }
        describe("min") {
          it("returns the min element") {
            expect(other.min()!).to(equal(-8))
          }
          it("returns nil if the vector is empty") {
            expect(empty.min()).to(beNil())
          }
        }
        describe("min index") {
          it("returns the index of the max element") {
            expect(other.minIndex()!).to(equal(0))
          }
          it("returns nil if the vector is empty") {
            expect(empty.minIndex()).to(beNil())
          }
        }
        it("can be summed") {
          expect(vec.sum()).to(equal(15))
        }
        it("can be averaged") {
          expect(vec.mean()).to(beCloseTo(3))
        }
        it("can be squared") {
          expect(vec.square()).to(equal([1,4,9,16,25]))
        }
        it("can be reversed") {
          expect(vec.reversed.array).to(equal([5,4,3,2,1]))
        }
      }


//      MARK: Arithmetic

      describe("arithmetic") {
        beforeEach {
          other = [-8,7,9,-6,5]
        }
        it("can have be added elementwise") {
          expect((vec + other).array).to(equal([-7,9,12,-2,10]))
        }
        it("can have a scalar added to it") {
          expect((vec + 5)).to(equal([6,7,8,9,10]))
        }
        it("can be subtracted elementwise") {
          expect((vec - other).array).to(equal([9,-5,-6,10,0]))
        }
        it("can have a scalar subtracted from it") {
          expect((vec - 5)).to(equal([-4,-3,-2,-1,0]))
        }
        it("can be multiplied elementwise") {
          expect((vec .* other).array).to(equal([-8,14,27,-24,25]))
        }
        it("can be multiplied by a scalar") {
          expect((vec .* 5)).to(equal([5,10,15,20,25]))
        }
        it("can be dotted with another vector") {
          expect(vec * other).to(equal(34))
        }
      }


//      MARK: Creation

      describe("creation") {
        it("can be initialzed to zeros") {
          let v = Vector<T>.zeros(5)
          expect(v.array).to(equal([0,0,0,0,0]))
        }
        it("can be initialzed to ones") {
          let v = Vector<T>.ones(5)
          expect(v.array).to(equal([1,1,1,1,1]))
        }
      }


//      MARK: Conversion

      describe("matrix conversion") {
        it("can be converted to a column matrix") {
          let m = vec.matrix()
          expect(m.flat).to(equal(vec.array))
          expect(m.rows).to(equal(5))
          expect(m.cols).to(equal(1))
        }
        it("can be converted to a row matrix") {
          let m = vec.matrix(.row)
          expect(m.flat).to(equal(vec.array))
          expect(m.rows).to(equal(1))
          expect(m.cols).to(equal(5))
        }
        it("can be converted to a diagonal matrix") {
          let m = vec.diag()
          expect(m.flat).to(equal([1,0,0,0,0,
                                   0,2,0,0,0,
                                   0,0,3,0,0,
                                   0,0,0,4,0,
                                   0,0,0,0,5]))
          expect(m.rows).to(equal(5))
          expect(m.cols).to(equal(5))
        }
        it("can be converted to a sparse diagonal matrix") {
          let m: SparseMatrix<T> = vec.diag()
          expect(m._values).to(equal([1,2,3,4,5]))
          expect(m._columnStarts).to(equal([0,1,2,3,4,5]))
          expect(m._rowIndices).to(equal([0,1,2,3,4]))
          expect(m.rows).to(equal(5))
          expect(m.cols).to(equal(5))
        }
      }
    }
  }
}
