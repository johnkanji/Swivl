//
//  main.swift
//
//
//  Created by John Kanji on 2020-Jul-04.
//

import Foundation
import Accelerate

import SwiftMat

let v = Vector<Double>([1,2,3,4])
print(Vector.plus(v, v))
print(v + v)
print(v + 2)

let v2 = VectorXf([1,2,3,4])
print(v2 + v2)
//print(v2 + 3)
