# Swivl - Swift Vector Library
<img src="swivl_logo.png" width="200" />

A set of BLAS-accelerated linerar algebra structures and functions. Includes dense and sparse matrices and vectors, and various solvers.
Features:
- BLAS accelerated operations
- Sparse and Dense support
- Cholesky, LU, Eigen- decompositions and more
- Matlab-style `solve` function chooses an appropriate solver

## Examples

### Basic Operations
```
import Foundation
import Swivl

let v = Vector<Double>([1,2,3,4])
print(Vector.add(v, v))
print(v + v)
print(v + 2)

let v2 = VectorXf([5,6,7,8])
print(v2 + v2)
```
```
>>> Vector<Double> 4x1 [2.0, 4.0, 6.0, 8.0]
>>> Vector<Double> 4x1 [2.0, 4.0, 6.0, 8.0]
>>> Vector<Double> 4x1 [3.0, 4.0, 5.0, 6.0]
>>> Vector<Float> 4x1 [10.0, 12.0, 14.0, 16.0]
```

### Matrix Mutliplication
```
let A = MatrixXd(rows: [
  [1,2,3],
  [4,5,6],
  [7,8,9]
])

let B = MatrixXd(rows: [
  [0,1,0],
  [1,0,0],
  [0,0,1]
])

let x = VectorXd([10,20,30])

print(A*B)
print(A.*B)
print(A*x)
```
```
>>> Matrix<Double> 3x3
	[  2,  1,  3 ]
	[  5,  4,  6 ]
	[  8,  7,  9 ]
>>> Matrix<Double> 3x3
	[  0,  2,  0 ]
	[  4,  0,  0 ]
	[  0,  0,  9 ]
>>> Vector<Double> 3x1 [140.0, 320.0, 500.0]
```

### Dense Matrix Creation
```
let A = MatrixXd(rows: [
  [10, -7, 0],
  [-3,  2, 6],
  [ 5, -1, 5]
])

let B = MatrixXd(flat: [
1.0000,    0.5000,    0.3333,    0.2500,
0.5000,    1.0000,    0.6667,    0.5000,
0.3333,    0.6667,    1.0000,    0.7500,
0.2500,    0.5000,    0.7500,    1.0000
], shape: (4,4))
```

### Matrix Properties
```
let M = MatrixXd(rows: [
  [1,2,3,4],
  [5,6,7,8],
  [9,0,1,2],
  [3,4,5,6]
])

print(M.det)
print(M.trace)
print(M.T)
print(M.diag())
```
```
>>> 1.5987211554602252e-13
>>> 14.0
>>> Matrix<Double> 4x4
	[  1,  5,  9,  3 ]
	[  2,  6,  0,  4 ]
	[  3,  7,  1,  5 ]
	[  4,  8,  2,  6 ]
>>> Vector<Double> 4x1 [1.0, 6.0, 1.0, 6.0]
```

### Slicing
```
let M = MatrixXd(rows: [
  [1,2,3,4,5],
  [6,7,8,9,0]
])

print(M[0, ...])
print(M[..., [0,2,3]])
print(M[..., 3...])
print(M[...0, 2...4])
```
```
>>> Vector<Double> 5x1 [1.0, 2.0, 3.0, 4.0, 5.0]
>>> Matrix<Double> 2x3
	[  1,  3,  4 ]
	[  6,  8,  9 ]
>>> Matrix<Double> 2x2
	[  4,  5 ]
	[  9,  0 ]
>>> Matrix<Double> 1x3
	[  3,  4,  5 ]
```

### Decomposition
```
var PSD = MatrixXd([
  [1, 0, 1],
  [0, 2, 0],
  [1, 0, 3]
])
print(PSD.isDefinite())
print(try? PSD.chol())

var nonPSD = MatrixXd([
  [1, 1,  1,  1,  1],
  [1, 2,  3,  4,  5],
  [1, 3,  6, 10, 15],
  [1, 4, 10, 20, 35],
  [1, 5, 15, 35, 69]])
print(nonPSD.isDefinite())
print(try? nonPSD.chol())
```
```
>>> Optional(Matrix<Double> 3x3
	[  1.000,  0.000,  1.000 ]
	[  0.000,  1.414,  0.000 ]
	[  0.000,  0.000,  1.414 ])
>>> true

>>> nil
>>> false
```

### Sparse Matrix Creation
```
let rows: [Int] = [0, 0, 1, 1, 2, 2, 2]
let cols: [Int] = [1, 3, 1, 4, 0, 1, 3]
let vals: [Double] = [1, 2, 5, 7, 8, 9, 4]
let A = SparseMatrix(rows, cols, vals)

let M = MatrixXd([
  [0, 1, 0, 2, 0],
  [0, 5, 0, 0, 7],
  [8, 9, 0, 4, 0]
])
let B = SparseMatrix(M)

let C = SparseMatrix<Double>(.eye(4))

let D = SparseMatrix<Double>.eye(4)
```
