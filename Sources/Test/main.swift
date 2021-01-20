//  main.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Swivl
import LinearAlgebra
import simd


//func time(averagedExecutions: Int = 1, _ code: () -> Void) {
//  let start = Date()
//  for _ in 0..<averagedExecutions { code() }
//  let end = Date()
//
//  let duration = end.timeIntervalSince(start) / Double(averagedExecutions)
//
//  print("time: \(duration)")
//}
//
//extension Matrix {
//
//  @_functionBuilder
//  class MatrixBuilder {
//    static func buildBlock(_ ms: Matrix...) -> Matrix {
//      Matrix(LinAlg.vcat(ms.map(\._mat)))
//    }
//
//    static func buildBlock(_ ms: [Scalar]...) -> Matrix {
//      Matrix(LinAlg.vcat(ms.map {Mat($0, (1, $0.count)) }))
//    }
//
//    static func buildExpression(_ row: [Scalar]) -> Matrix {
//      Matrix(flat: row, shape: (1, row.count))
//    }
//
//    static func buildExpression(_ mat: Matrix) -> Matrix {
//      mat
//    }
//  }
//
//  init(@MatrixBuilder content: () -> Self) {
//    self.init(content()._mat)
//  }
//
//}
//
//
//let M: MatrixXd = [4, 3, 2]
//let A = MatrixXd { M; [1, 2, 3] }
//print(A + 5)
//                & [5, 6, 7]
//print(M)

//let M2 = [     M,        M]
//         [.eye(3), .eye(3)]

//print(M2)

//let v1: VectorXi = [1,2,3,4,5]
let v1: VectorXd = [1,2,3,4,5]
let v2: VectorXd = [-8,7,9,-6,5]
let v3: VectorXf = [1,2,3,4,5]
let v4: VectorXf = [-8,7,9,-6,5]
let v5: VectorXi = [1,2,3,4,5]
let v6: VectorXi = [-8,7,9,-6,5]

print(Vector.subtract(v1,v2))
print()
print(v1 - v2)

//print("double")
//print("+")
//v1 + v2
//print("-")
//v1 - v2
//print()
//
//print("float")
//print("+")
//v3 + v4
//print("-")
//v3 - v4
//print()
//
//print("int")
//print("+")
//v5 + v6
//print("-")
//v5 - v6
//print()
