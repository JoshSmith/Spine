//
//  Utilities.swift
//  Spine
//
//  Created by Ward van Teijlingen on 19-02-15.
//  Copyright (c) 2015 Ward van Teijlingen. All rights reserved.
//

import Foundation
import XCTest
import SwiftyJSON
import BrightFutures

extension XCTestCase {
	
	func JSONFixtureWithName(name: String) -> (data: NSData, json: JSON) {
		let path = NSBundle(forClass: self.dynamicType).URLForResource(name, withExtension: "json")!
		let data = NSData(contentsOfURL: path)!
		let json = JSON(data: data)
		return (data: data, json: json)
	}
}

// MARK: - Custom assertions

func assertFutureFailure<T>(future: Future<T>, withError expectedError: NSError, expectation: XCTestExpectation) {
	future.onSuccess { resources in
		expectation.fulfill()
		XCTFail("Expected success callback to not be called.")
		}.onFailure { error in
			expectation.fulfill()
			XCTAssertEqual(error.domain, expectedError.domain, "Expected error domain to be \(expectedError.domain).")
			XCTAssertEqual(error.code, expectedError.code, "Expected error code to be \(expectedError.code).")
	}
}

func assertFutureFailure<T>(future: Future<T>, withErrorDomain domain: String, errorCode code: Int, expectation: XCTestExpectation) {
	let expectedError = NSError(domain: domain, code: code, userInfo: nil)
	assertFutureFailure(future, withError: expectedError, expectation)
}

func assertFooResource(foo: Foo, isEqualToJSON json: JSON) {
	XCTAssertEqual(foo.stringAttribute!, json["attributes"]["stringAttribute"].stringValue, "Deserialized string attribute is not equal.")
	XCTAssertEqual(foo.integerAttribute!, json["attributes"]["integerAttribute"].intValue, "Deserialized integer attribute is not equal.")
	XCTAssertEqual(foo.floatAttribute!, json["attributes"]["floatAttribute"].floatValue, "Deserialized float attribute is not equal.")
	XCTAssertEqual(foo.booleanAttribute!, json["attributes"]["integerAttribute"].boolValue, "Deserialized boolean attribute is not equal.")
	XCTAssertNil(foo.nilAttribute, "Deserialized nil attribute is not equal.")
	XCTAssertEqual(foo.dateAttribute!, NSDate(timeIntervalSince1970: 0), "Deserialized date attribute is not equal.")
}