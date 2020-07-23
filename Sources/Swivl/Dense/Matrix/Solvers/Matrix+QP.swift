//  MatrixTypes.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra

extension Matrix where Scalar == Double {

  public func QP(_ q: Vector<Scalar>, _ A: Self, _ l: Vector<Scalar>, _ u: Vector<Scalar>) -> Vector<Scalar> {
    Vector(LinAlg.OSQP(self._mat, q.array, A._mat, l.array, u.array))
  }

}

extension Matrix where Scalar == Float {

  public func QP(_ q: Vector<Scalar>, _ A: Self, _ l: Vector<Scalar>, _ u: Vector<Scalar>) -> Vector<Scalar> {
    self.double().QP(q.double(), A.double(), l.double(), u.double()).float()
  }

}
