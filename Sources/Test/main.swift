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


let nonPSD = MatrixXd([
  [1, 1,  1,  1,  1],
  [1, 2,  3,  4,  5],
  [1, 3,  6, 10, 15],
  [1, 4, 10, 20, 35],
  [1, 5, 15, 35, 69]])

print(try? nonPSD.chol())
print(nonPSD.isDefinite)

let PSD = MatrixXd([
  [1, 0, 1],
  [0, 2, 0],
  [1, 0, 3]
])

print(try? PSD.chol())
print(PSD.isDefinite)

exit(0)
  
var M = MatrixXd(rows: [
  [7, 1, 2],
  [3, 4, 5],
  [6, 7, 8],
  [9, 10, 11]
])
print("\n1")

//var (L, U, P, Q) = M.LU(.LUPQ)
//print(P!*L*U*Q! == M)
//(L, U, P, Q) = M.LU(.LUP)
//print(P!*L*U == M)
//(L, U, P, Q) = M.LU(.LU)
//print(L*U == M)

M = MatrixXd(rows: [
  [10, -7, 0],
  [-3,  2, 6],
  [ 5, -1, 5]
])
print("\n2")
var (L, U, P, Q) = M.LU(.LUPQ)
print(P!*L*U*Q! == M)
(L, U, P, Q) = M.LU(.LUP)
print(P!*L*U == M)
(L, U, P, Q) = M.LU(.LU)
print(L*U == M)

M = MatrixXd(flat: [
1.0000,    0.5000,    0.3333,    0.2500,
0.5000,    1.0000,    0.6667,    0.5000,
0.3333,    0.6667,    1.0000,    0.7500,
0.2500,    0.5000,    0.7500,    1.0000
], shape: (4,4))
print("\n3")
(L, U, P, Q) = M.LU(.LUPQ)
print(P!*L*U*Q! == M)
(L, U, P, Q) = M.LU(.LUP)
print(P!*L*U == M)
(L, U, P, Q) = M.LU(.LU)
print(L*U == M)


M = MatrixXd(flat: [
  0.378589,   0.971711,   0.016087,   0.037668,   0.312398,
  0.756377,   0.345708,   0.922947,   0.846671,   0.856103,
  0.732510,   0.108942,   0.476969,   0.398254,   0.507045,
  0.162608,   0.227770,   0.533074,   0.807075,   0.180335,
  0.517006,   0.315992,   0.914848,   0.460825,   0.731980
], shape: (5,5))
print("\n4")
(L, U, P, Q) = M.LU(.LUPQ)
print(P!*L*U*Q! == M)
(L, U, P, Q) = M.LU(.LUP)
print(P!*L*U == M)
(L, U, P, Q) = M.LU(.LU)
print(L*U == M)
