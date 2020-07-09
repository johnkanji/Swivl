//  MatrixTypes.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Accelerate


// MARK: MatrixXd

public typealias MatrixXd = Matrix<Double>

extension MatrixXd {
  public func float() -> MatrixXf {
    MatrixXf(flat: vDSP.doubleToFloat(flat), shape: shape)
  }
}


// MARK: MatrixXf

public typealias MatrixXf = Matrix<Float>

extension MatrixXf {
  public func double() -> MatrixXd {
    MatrixXd(flat: vDSP.floatToDouble(flat), shape: shape)
  }
}


// MARK: MatrixXi

public typealias MatrixXi = Matrix<Int32>

extension MatrixXi {}
