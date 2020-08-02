//  SparseEig.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import ARPACK
import Accelerate

extension LinAlg {

  public static func eig<T>(_ a: SpMat<T>, vectors: SingularVectorOutput = .none)
  throws -> (values: [T], leftVectors: SpMat<T>?, rightVectors: SpMat<T>?) where T: SwivlFloatingPoint {
    return ([],nil,nil)
  }

  static func symEig<T>(_ a: SpMat<T>) throws where T: SwivlFloatingPoint {

    let maxn: Int32 = 256
    let maxnev: Int32 = 10
    let maxncv: Int32 = 25
    let ldv: Int32 = maxn

    var v = Mat<T>([T](repeating: 0, count: Int(ldv*maxncv)), RowCol(Int(ldv), Int(maxncv)))
    var workl = [T](repeating: 0, count: Int(maxncv*(maxncv+8)))
    var workd = [T](repeating: 0, count: Int(3*maxn))
    var d = Mat<T>([T](repeating: 0, count: Int(maxncv*2)), RowCol(Int(maxncv), 2))
    var resid = [T](repeating: 0, count: Int(maxn))
    var ax = [T](repeating: 0, count: Int(maxncv))
    let select = [Int32](repeating: 0, count: Int(maxncv))
    var iparam = [Int32](repeating: 0, count: 11)
    var ipntr = [Int32](repeating: 0, count: 11)

    let nx: Int32 = 10
    let n: Int32 = nx*nx
    let nev: Int32 =  4
    let ncv: Int32 =  10
    assert(n <= maxn, "ERROR with _SDRV1: N is greater than MAXN")
    assert(nev <= maxnev, "ERROR with _SDRV1: NEV is greater than MAXNEV")
    assert(ncv <= maxncv, "ERROR with _SDRV1: NCV is greater than MAXNCV")
    var bmat = Int8(Character("I").asciiValue!)
    var which: [Int8] = "SM".map { c in Int8(c.asciiValue!) }

    let lworkl: Int32 = ncv*(ncv+8)
    let tol: T = 0
    var info: Int32 = 0
    var ido: Int32 = 0

    let ishfts: Int32 = 1
    let maxitr: Int32 = 300
    let mode: Int32   = 1
    iparam[1] = ishfts
    iparam[3] = maxitr
    iparam[7] = mode


//    MARK: Main Loop

    while true {
      resid.withUnsafeMutableBufferPointer(as: Double.self) { pR in
      v.flat.withUnsafeMutableBufferPointer(as: Double.self) { pV in
      workd.withUnsafeMutableBufferPointer(as: Double.self) { pWd in
      workl.withUnsafeMutableBufferPointer(as: Double.self) { pWl in
        dsaupd_c(&ido, &bmat, n, &which, nev, tol as! Double, pR.baseAddress!, ncv, pV.baseAddress!, ldv, &iparam, &ipntr, pWd.baseAddress!, pWl.baseAddress!, lworkl, &info)
      }}}}

      if (ido == -1 || ido == 1) {
        workd.withUnsafeMutableBufferPointer { pWd in
          av(Int(nx), pWd.baseAddress! + Int(ipntr[1]), pWd.baseAddress! + Int(ipntr[2]))   // matrix vector product
        }
      } else {
        break
      }

    }

    if info < 0 {
      print("Error with _saupd, info = \(info)")
      print("Check documentation in _saupd")
      throw LinAlgError.eigendecompositionFailure
    }

    let rvec = true
    var howmny: [Int8] = "All".map { Int8($0.asciiValue!) }
    let sigma: T = 0

    var ierr: Int32 = 0
    d.flat.withUnsafeMutableBufferPointer(as: Double.self) { pD in
    v.flat.withUnsafeMutableBufferPointer(as: Double.self) { pV in
    resid.withUnsafeMutableBufferPointer(as: Double.self) { pR in
    workd.withUnsafeMutableBufferPointer(as: Double.self) { pWd in
    workl.withUnsafeMutableBufferPointer(as: Double.self) { pWl in
      dseupd_c(rvec, &howmny, select, pD.baseAddress, pV.baseAddress!, ldv, sigma as! Double, &bmat, n, which, nev, tol as! Double, pR.baseAddress!, ncv, pV.baseAddress!, ldv, &iparam, &ipntr, pWd.baseAddress!, pWl.baseAddress!, lworkl, &ierr)
    }}}}}

//        %----------------------------------------------%
//        | Eigenvalues are returned in the first column |
//        | of the two dimensional array D and the       |
//        | corresponding eigenvectors are returned in   |
//        | the first NEV columns of the two dimensional |
//        | array V if requested.  Otherwise, an         |
//        | orthogonal basis for the invariant subspace  |
//        | corresponding to the eigenvalues in D is     |
//        | returned in V.                               |
//        %----------------------------------------------%

    if ierr != 0 {
      print("Error with _seupd, info = \(ierr)")
      print("Check the documentation of _seupd.")
      throw LinAlgError.eigendecompositionFailure
    }

    let nconv =  iparam[5]

    for j in 0..<Int(nconv-1) {
      v.flat.withUnsafeBufferPointer(as: Double.self) { pV in
      ax.withUnsafeMutableBufferPointer(as: Double.self) { pAx in
        av(Int(nx), pV.baseAddress! + j, pAx.baseAddress!)
        let alpha = -d.flat[d.shape.c*j] as! Double
        cblas_daxpy(n, alpha, pV.baseAddress! + j, 1, pAx.baseAddress!, 1)
        cblas_dnrm2(n, pAx.baseAddress!, 1)
      }}
      d.flat[Int(j)*d.shape.c + 1] = d.flat[Int(j)*d.shape.c + 1] / Swift.abs(d.flat[Int(j)*d.shape.c + 1])
    }


//    call dmout(6, nconv, 2, d, maxncv, -6, 'Ritz values and relative residuals')
//        %------------------------------------------%
//        | Print additional convergence information |
//        %------------------------------------------%
//
//    if ( info .eq. 1) then
//    print *, ' '
//    print *, ' Maximum number of iterations reached.'
//    print *, ' '
//    else if ( info .eq. 3) then
//    print *, ' '
//    print *, ' No shifts could be applied during implicit',
//    &               ' Arnoldi update, try increasing NCV.'
//    print *, ' '
//    end if
//      c
//    print *, ' '
//    print *, ' _SDRV1 '
//    print *, ' ====== '
//    print *, ' '
//    print *, ' Size of the matrix is ', n
//    print *, ' The number of Ritz values requested is ', nev
//    print *, ' The number of Arnoldi vectors generated',
//    &            ' (NCV) is ', ncv
//    print *, ' What portion of the spectrum: ', which
//    print *, ' The number of converged Ritz values is ',
//    &              nconv
//    print *, ' The number of Implicit Arnoldi update',
//    &            ' iterations taken is ', iparam(3)
//    print *, ' The number of OP*x is ', iparam(9)
//    print *, ' The convergence criterion is ', tol
//    print *, ' '
    //
  }


  static func av<T>(_ nx: Int, _ v: UnsafePointer<T>!, _ w: UnsafeMutablePointer<T>!) where T: SwivlFloatingPoint {
//  matrix vector subroutine
//    The matrix used is the 2 dimensional discrete Laplacian on unit
//    square with zero Dirichlet boundary condition.
//
//    Computes w <--- OP*v, where OP is the nx*nx by nx*nx block
//    tridiagonal matrix
//
//                 | T -I          |
//                 |-I  T -I       |
//            OP = |   -I  T       |
//                 |        ...  -I|
//                 |           -I T|
//
//    The subroutine TV is called to computed y<---T*x.

    if T.self is Double.Type {
      v.withMemoryRebound(to: Double.self, capacity: nx) { pV in
      w.withMemoryRebound(to: Double.self, capacity: nx) { pW in
        tv(nx,pV,pW)
        cblas_daxpy(Int32(nx), -1, pV + nx, 1, pW, 1)

        for j in 1..<nx-1 {
          let lo = (j-1)*nx
          tv(nx, pV + (lo+1), pW + (lo+1))
          cblas_daxpy(Int32(nx), -1, pV + (lo-nx+1), 1, pW + (lo+1), 1)
          cblas_daxpy(Int32(nx), -1, pV + (lo+nx+1), 1, pW + (lo+1), 1)
        }

        let lo = (nx-1)*nx
        tv(nx, pV + lo, pW + lo)
        cblas_daxpy(Int32(nx), -1, pV + (lo-nx), 1, pW + (lo), 1)
        let h2 = 1.0 / Double((nx+1)*(nx+1))
        (0..<(nx*nx)).forEach { i in
          (pW + i).pointee = (pW + i).pointee / h2
        }
      }}
    } else {
      v.withMemoryRebound(to: Float.self, capacity: nx) { pV in
      w.withMemoryRebound(to: Float.self, capacity: nx) { pW in
        tv(nx,pV,pW)
        cblas_saxpy(Int32(nx), -1, pV + nx, 1, pW, 1)

        for j in 1..<nx-1 {
          let lo = (j-1)*nx
          tv(nx, pV + (lo+1), pW + (lo+1))
          cblas_saxpy(Int32(nx), -1, pV + (lo-nx+1), 1, pW + (lo+1), 1)
          cblas_saxpy(Int32(nx), -1, pV + (lo+nx+1), 1, pW + (lo+1), 1)
        }

        let lo = (nx-1)*nx
        tv(nx, pV + lo, pW + lo)
        cblas_saxpy(Int32(nx), -1, pV + (lo-nx), 1, pW + (lo), 1)
        let h2 = 1.0 / Float((nx+1)*(nx+1))
        (0..<(nx*nx)).forEach { i in
          (pW + i).pointee = (pW + i).pointee / h2
        }
      }}
    }
  }

  static func tv<T>(_ nx: Int, _ x: UnsafePointer<T>!, _ y: UnsafeMutablePointer<T>!) where T: SwivlFloatingPoint {
//     Compute the matrix vector multiplication y<---T*x
//     where T is a nx by nx tridiagonal matrix with DD on the
//     diagonal, DL on the subdiagonal, and DU on the superdiagonal.

    let dd: T = 4
    let dl: T = -1
    let du: T = -1

    y[0] =  dd*x[0] + du*x[1]
    for j in 1..<nx-1 {
      y[j] = dl*x[j-1] + dd*x[j] + du*x[j+1]
    }
    y[nx-1] =  dl*x[nx-2] + dd*x[nx-1]
    return
  }


}
