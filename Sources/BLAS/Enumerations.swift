//  Enumerations.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Accelerate
import CLapacke


// MARK: Public Enums

public enum MatrixDimension {
  case row
  case col
}


public enum MatrixLayout: Int32 {
  case rowMajor = 101
  case columnMajor = 102
  case diagonal
  
  public static var defaultLayout = rowMajor
}


public enum TriangularType: Int8 {
  case upper = 85
  case lower = 76
}


public enum LUOutput {
  case LU
  case LUP
  case LUPQ
}


public enum SingularVectorOutput {
  case left
  case right
  case both
  case none
}


public typealias RoundingMode = vDSP.RoundingMode


public enum BLASError: Error {
  case invalidType
  case invalidMatrix(String)
  case eigendecompositionFailure
  case linearLeastSquaresFaliure
}


// MARK: Internal Enums

enum Transpose: Int8 {
  case trans = 84
  case noTrans = 78
}

enum ComputeVectors: Int8 {
  case compute = 86
  case dontCompute = 78
}

enum Distribution: Int32 {
  case uniform = 1
  case normal = 3
}
