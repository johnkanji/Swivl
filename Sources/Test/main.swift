//  main.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Accelerate
import Swivl
import BLAS

//let v1 = Vector<Int32>([1,2,3,4])
//print(v1 + v1)
//print(v2 + v2)


//print(v2 + 3)

let M = MatrixXd(rows: [
  [0, 1, 2],
  [3, 4, 5],
  [6, 7, 8],
//  [9, 10, 11]
])
print()
var (L, U, P, Q) = M.LU(.LUPQ)
//print(L)
//print(U)
print(P!*L*U*Q!)

exit(0)

//var Ar = MatrixXf(flat: [4,3,6,3], shape: (2,2))
print("A")
let A = MatrixXd(rows: [
  [10, -7, 0],
  [-3,  2, 6],
  [ 5, -1, 5]
])
//var Ac = MatrixXf(flat: [4,6,3,3], shape: (2,2))
//
  (L, U, _, _) = A.LU()
print()
//print(A)
//print(L)
//print(U)
//print()
//print(L*U)

print("M2")
let M2 = MatrixXd(flat: [
1.0000,    0.5000,    0.3333,    0.2500,
0.5000,    1.0000,    0.6667,    0.5000,
0.3333,    0.6667,    1.0000,    0.7500,
0.2500,    0.5000,    0.7500,    1.0000
], shape: (4,4))
M2.LU()
//let (v, _, _) = M2.eig()
//print(v)


let B = MatrixXd(flat: [
  0.378589,   0.971711,   0.016087,   0.037668,   0.312398,
  0.756377,   0.345708,   0.922947,   0.846671,   0.856103,
  0.732510,   0.108942,   0.476969,   0.398254,   0.507045,
  0.162608,   0.227770,   0.533074,   0.807075,   0.180335,
  0.517006,   0.315992,   0.914848,   0.460825,   0.731980
], shape: (5,5))
print("B")
B.LU()
