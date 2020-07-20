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


// MARK: MatrixXd

public typealias MatrixXd = Matrix<Double>

extension MatrixXd {

  public func float() -> MatrixXf {
    MatrixXf(flat: LinAlg.toFloat(_flat), shape: shape)
  }
  
  public func integer(roundingMode: RoundingMode = .towardNearestInteger) -> MatrixXi {
    MatrixXi(flat: LinAlg.toInteger(_flat, roundingMode: roundingMode), shape: shape)
  }
}


// MARK: MatrixXf

public typealias MatrixXf = Matrix<Float>

extension MatrixXf {

  public func double() -> MatrixXd {
    MatrixXd(flat: LinAlg.toDouble(_flat), shape: shape)
  }
  
  public func integer(roundingMode: RoundingMode = .towardNearestInteger) -> MatrixXi {
    MatrixXi(flat: LinAlg.toInteger(_flat, roundingMode: roundingMode), shape: shape)
  }
}


// MARK: MatrixXi

public typealias MatrixXi = Matrix<Int32>

extension MatrixXi {
  
  public func float() -> MatrixXf {
    MatrixXf(flat: LinAlg.toFloat(_flat), shape: shape)
  }
  
  public func double() -> MatrixXd {
    MatrixXd(flat: LinAlg.toDouble(_flat), shape: shape)
  }
  
}
