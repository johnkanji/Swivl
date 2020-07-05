import XCTest
@testable import SwiftMat

final class LASwiftTests: XCTestCase {
  func testScalarAdd() {
    let v = Vector<Int>([1,2,3,4])
    let a: Int = 3
    
    let out1 = v + a
    let out2 = a + v
    let correct = Vector<Int>([4,5,6,7])
    XCTAssertEqual(out1, correct)
    XCTAssertEqual(out2, correct)
  }
  
  func testVectorAdd() {
    let v = Vector<Int>([1,2,3,4])
    let a = Vector<Int>([3,3,3,3])
    
    let out1 = v + a
    let out2 = a + v
    let correct = Vector<Int>([4,5,6,7])
    XCTAssertEqual(out1, correct)
    XCTAssertEqual(out2, correct)
  }
  
  func testScalarAddFloat() {
    let v = Vector<Float>([1,2,3,4])
    let a: Float = 3
    
    let out1 = v + a
    let out2 = a + v
    let correct = Vector<Float>([4,5,6,7])
    XCTAssertEqual(out1, correct)
    XCTAssertEqual(out2, correct)
  }
  
  func testVectorAddFloat() {
    let v = Vector<Float>([1,2,3,4])
    let a = Vector<Float>([3,3,3,3])
    
    let out1 = v + a
    let out2 = a + v
    let correct = Vector<Float>([4,5,6,7])
    XCTAssertEqual(out1, correct)
    XCTAssertEqual(out2, correct)
  }
  
  func testScalarAddDouble() {
    let v = Vector<Double>([1,2,3,4])
    let a: Double = 3
    
    let out1 = v + a
    let out2 = a + v
    let correct = Vector<Double>([4,5,6,7])
    XCTAssertEqual(out1, correct)
    XCTAssertEqual(out2, correct)
  }
  
  func testVectorAddDouble() {
    let v = Vector<Double>([1,2,3,4])
    let a = Vector<Double>([3,3,3,3])
    
    let out1 = v + a
    let out2 = a + v
    let correct = Vector<Double>([4,5,6,7])
    XCTAssertEqual(out1, correct)
    XCTAssertEqual(out2, correct)
  }
  
  static var allTests = [
    ("testScalarAdd", testScalarAdd),
    ("testVectorAdd", testVectorAdd),
  ]
}
