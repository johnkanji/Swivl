//  VectorTypes.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Accelerate


public typealias VectorXd = Vector<Double>

extension VectorXd {
  public func float() -> VectorXf {
    VectorXf(vDSP.doubleToFloat(array))
  }
}


public typealias VectorXf = Vector<Float>

extension VectorXf {
  public func double() -> VectorXd {
    VectorXd(vDSP.floatToDouble(array))
  }
}


public typealias VectorXi = Vector<Int32>

extension VectorXi {
  public var length: Double {
    sqrt(Double(array.map { $0*$0 }.sum()))
  }
}
