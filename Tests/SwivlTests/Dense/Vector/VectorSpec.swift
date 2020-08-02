//  VectorSpec.swift
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

class VectorXdSpec: QuickSpec {
  override func spec() {
    var vec: VectorXd!
    beforeEach {
      vec = VectorXd([1,2,3,4,5])
    }
    itBehavesLike(VectorBehavior.self) { vec }
    itBehavesLike(RealVectorBehavior.self) { vec }
  }
}

class VectorXfSpec: QuickSpec {
  override func spec() {
    var vec: VectorXf!
    beforeEach {
      vec = VectorXf([1,2,3,4,5])
    }
    itBehavesLike(VectorBehavior.self) { vec }
    itBehavesLike(RealVectorBehavior.self) { vec }
  }
}

class VectorXiSpec: QuickSpec {
  override func spec() {
    var vec: VectorXi!
    beforeEach {
      vec = VectorXi([1,2,3,4,5])
    }
    itBehavesLike(VectorBehavior.self) { vec }

    describe("arithmetic") {
      it("can be divided elementwise") {
        let other = VectorXi([-8,7,9,-6,5])
        expect((other ./ vec).array).to(equal([-8, 3, 3, -1, 1]))
      }
      it("can be divided by a scalar") {
        expect((vec ./ 2).array).to(equal([0, 1, 1, 2, 2]))
      }
    }

    describe("geometry") {
      it("can have it's length computed") {
        expect(vec.length).to(beCloseTo(7.4161984871))
      }
    }

  }
}
