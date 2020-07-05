//
//  Numeric.swift
//
//
//  Created by John Kanji on 2020-Jul-04.
//


precedencegroup EquivalencePrecedence {
  higherThan: ComparisonPrecedence
  lowerThan: AdditionPrecedence
}

infix operator ==~ : EquivalencePrecedence
infix operator !=~ : EquivalencePrecedence
infix operator <=~ : ComparisonPrecedence
infix operator >=~ : ComparisonPrecedence
infix operator <~ : ComparisonPrecedence
infix operator >~ : ComparisonPrecedence

public protocol VectorFloatingPoint: FloatingPoint {}

extension Double: VectorFloatingPoint {}
extension Float: VectorFloatingPoint {}


extension VectorFloatingPoint where Stride == Self {
  
  init<T: Numeric>(_ n: T) {
    if T.self is Double.Type {
      self.init(n as! Double)
    } else if T.self is Float.Type {
      self.init(n as! Float)
    } else {
      self.init(n as! Int)
    }
  }
  
  static func ==~ (left: Self, right: Self) -> Bool
  {
    return left.distance(to: right).magnitude <= Self.leastNormalMagnitude
  }
  
  static func !=~ (left: Self, right: Self) -> Bool
  {
    return !(left ==~ right)
  }
  
  static func <=~ (left: Self, right: Self) -> Bool
  {
    return left ==~ right || left <~ right
  }
  
  static func >=~ (left: Self, right: Self) -> Bool
  {
    return left ==~ right || left >~ right
  }
  
  static func <~ (left: Self, right: Self) -> Bool
  {
    return left.distance(to: right) > Self.leastNormalMagnitude
  }
  
  static func >~ (left: Self, right: Self) -> Bool
  {
    return left.distance(to: right) < -Self.leastNormalMagnitude
  }
  
}
