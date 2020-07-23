//  SparseMatrixTypes.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra


// MARK: SparseMatrixXd

public typealias SparseMatrixXd = SparseMatrix<Double>

extension SparseMatrixXd {

  public func float() -> SparseMatrixXf {
    SparseMatrixXf((_rowIndices, _columnStarts, LinAlg.toFloat(_values), shape))
  }

  public func integer(roundingMode: RoundingMode = .towardNearestInteger) -> SparseMatrixXi {
    SparseMatrixXi((_rowIndices,
                    _columnStarts,
                    LinAlg.toInteger(_values, roundingMode: roundingMode),
                    shape))
  }
}


// MARK: SparseMatrixXf

public typealias SparseMatrixXf = SparseMatrix<Float>

extension SparseMatrixXf {

  public func double() -> SparseMatrixXd {
    SparseMatrixXd((_rowIndices, _columnStarts, LinAlg.toDouble(_values), shape: shape))
  }

  public func integer(roundingMode: RoundingMode = .towardNearestInteger) -> SparseMatrixXi {
    SparseMatrixXi((_rowIndices,
                    _columnStarts,
                    LinAlg.toInteger(_values, roundingMode: roundingMode),
                    shape))
  }
}


// MARK: SparseMatrixXi

public typealias SparseMatrixXi = SparseMatrix<Int32>

extension SparseMatrixXi {

  public func float() -> SparseMatrixXf {
    SparseMatrixXf((_rowIndices, _columnStarts, LinAlg.toFloat(_values), shape))
  }

  public func double() -> SparseMatrixXd {
    SparseMatrixXd((_rowIndices, _columnStarts, LinAlg.toDouble(_values), shape))
  }

}
