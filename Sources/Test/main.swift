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
import CLapacke

var attributes = SparseAttributes_t()
attributes.triangle = SparseLowerTriangle
attributes.kind = SparseSymmetric

// Symmetric
//var row: [Int32] =      [ 0,   1,   3,    1,    2,   3,   2,   3]
//var column: [Int32] =   [ 0,   0,   0,    1,    1,   1,   2,   3]
//var values =            [10.0, 1.0, 2.5, 12.0, -0.3, 1.1, 9.5, 6.0]

// M = [  10    1    0 2.5 ]
//     [   1   12 -0.3 1.1 ]
//     [   0 -0.3  9.5   0 ]
//     [ 2.5  1.1    0   6 ]

//var row: [Int32] = [0, 1, 3, 0, 1, 2, 3, 1, 2, 0, 1, 3]
//var column: [Int32] = [0, 0, 0, 1, 1, 1, 1, 2, 2, 3, 3, 3]
//var values: [Double] = [10, 1, 2.5, 1, 12, -0.3, 1.1, -0.3, 9.5, 2.5, 1.1, 6.0]

// rowIndices = [
//   0, 1, 3,
//   0, 1, 2, 3,
//   1, 2,
//   0, 1, 3
// ]
// columnStarts = [0, 3, 7, 9, 12]


//let M = SparseMatrix(row, column, values)
//print(M)


let X = MatrixXd(flat: [
  3, 2, -1,
  2, -3, -5,
  -1, -4, -3
], shape: (3,3))
print(X.rank)


let M = MatrixXd([
  [0, 1, 0, 2, 0],
  [0, 5, 0, 0, 7],
  [8, 9, 0, 4, 0]
])


let rows: [Int] = [0, 0, 1, 1, 2, 2, 2]
let cols: [Int] = [1, 3, 1, 4, 0, 1, 3]
let vals: [Double] = [1, 2, 5, 7, 8, 9, 4]

let A = SparseMatrix(rows, cols, vals)
print(A)

let B = SparseMatrix(M)
print(B)

let C = SparseMatrix<Double>(.eye(4))
print(C)

let D = SparseMatrix<Double>.eye(4)
print(D)
print(D.dense())


let v1 = Vector3d([1,2,3])
let v2 = Vector3d([10,10,10])
print(v1)
print()
print(v1+v2)
print(v1-v2)
print(v1/v2)
print(v1.*v2)
print(v1*v2)


//  TODO: wtf
//  func simd_mul(simd_float2x4, simd_float2x2) -> simd_float2x4
//  Returns the product of two matrices.

//  func simd_mul(simd_float3x4, simd_float2x3) -> simd_float2x4
//  Returns the product of two matrices.

//  func simd_mul(simd_float4x4, simd_float2x4) -> simd_float2x4
//  Returns the product of two matrices.

