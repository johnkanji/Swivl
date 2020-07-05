//
//  VectorProtocol+Comparison.swift
//  
//
//  Created by John Kanji on 2020-Jul-04.
//

import Foundation

// MARK: Self array comparison
//extension VectorProtocol where Element: VectorFloatingPoint, Element.Stride == Element {
//  
//  static func ==~ (left: Self, right: Self) -> Bool
//  {
//    return left.count == right.count &&
//      zip(left, right).allSatisfy { (l, r) in l ==~ r }
//  }
//  
//  static func !=~ (left: Self, right: Self) -> Bool
//  {
//    return left.count != right.count ||
//      !(zip(left, right).allSatisfy { (l, r) in l ==~ r })
//  }
//  
//  static func >~ (left: Self, right: Self) -> Bool
//  {
//    return left.count != right.count ||
//      zip(left, right).filter { (l, r) in l >~ r }.count != 0
//  }
//  
//  static func <~ (left: Self, right: Self) -> Bool
//  {
//    return left.count != right.count ||
//      zip(left, right).filter { (l, r) in l <~ r }.count != 0
//  }
//  
//  static func >=~ (left: Self, right: Self) -> Bool
//  {
//    return left.count != right.count ||
//      zip(left, right).filter { (l, r) in l >=~ r }.count != 0
//  }
//  
//  static func <=~ (left: Self, right: Self) -> Bool
//  {
//    return left.count != right.count ||
//      zip(left, right).filter { (l, r) in l <=~ r }.count != 0
//  }
//  
//  // MARK: - Vector comparison
//  
//  /// Check if two vectors are equal using approximate comparison
//  public static func == (lhs: Self, rhs: Self) -> Bool {
//    return lhs ==~ rhs
//  }
//  
//  /// Check if two vectors are not equal using approximate comparison
//  public static func != (lhs: Self, rhs: Self) -> Bool {
//    return lhs !=~ rhs
//  }
//  
//  /// Check if one vector is greater than another using approximate comparison
//  public static func > (lhs: Self, rhs: Self) -> Bool {
//    return lhs >~ rhs
//  }
//  
//  /// Check if one vector is less than another using approximate comparison
//  public static func < (lhs: Self, rhs: Self) -> Bool {
//    return lhs <~ rhs
//  }
//  
//  /// Check if one vector is greater than or equal to another using approximate comparison
//  public static func >= (lhs: Self, rhs: Self) -> Bool {
//    return lhs >=~ rhs
//  }
//  
//  /// Check if one vector is less than or equal to another using approximate comparison
//  public static func <= (lhs: Self, rhs: Self) -> Bool {
//    return lhs <=~ rhs
//  }
//  
//}
