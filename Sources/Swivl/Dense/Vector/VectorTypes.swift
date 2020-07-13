//  VectorTypes.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import BLAS


public typealias VectorXd = Vector<Double>

extension VectorXd {
  
  public func float() -> VectorXf {
    VectorXf(BLAS.toFloat(array))
  }
  
  public func integer(roundingMode: RoundingMode = .towardNearestInteger) -> VectorXi {
    VectorXi(BLAS.toInteger(array, roundingMode: roundingMode))
  }
  
}


public typealias VectorXf = Vector<Float>

extension VectorXf {
  
  public func double() -> VectorXd {
    VectorXd(BLAS.toDouble(array))
  }
  
  public func integer(roundingMode: RoundingMode = .towardNearestInteger) -> VectorXi {
    VectorXi(BLAS.toInteger(array, roundingMode: roundingMode))
  }
  
}


public typealias VectorXi = Vector<Int32>

extension VectorXi {
  
  public func float() -> VectorXf {
    VectorXf(BLAS.toFloat(array))
  }
  
  public func double() -> VectorXd {
    VectorXd(BLAS.toDouble(array))
  }
  
  public var length: Double {
    sqrt(Double(array.map { $0*$0 }.sum()))
  }
  
}
