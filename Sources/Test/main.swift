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
//import LinearAlgebra

let M = MatrixXd([
  [0,2,0,4],
  [5,0,0,0],
  [0,3,0,3],
  [0,1,0,7]])
let Mt = M†
let S = M.sparse()
let St = Mt.sparse()


print(M*M)
print((S*S).dense())


func S<T>(_ a: T) where T: SwivlFloatingPoint {
  
}

//func sp_print<T>(_ a: SpMat<T>) {
//  (0..<a.cs.count-1).forEach { i in
//    print(i, a.cs[i], a.ri[a.cs[i]..<a.cs[i+1]])
//  }
//}
