//
//  QueryTests.swift
//  Spine
//
//  Created by Ward van Teijlingen on 20-02-15.
//  Copyright (c) 2015 Ward van Teijlingen. All rights reserved.
//

import Foundation
import XCTest

class QueryTests: XCTestCase {
	
	func testInclude() {
		var query = Query(resourceType: Foo.self)
		
		query.include("bar", "qux", "bar.qux")
		XCTAssertEqual(query.includes, ["bar", "qux", "bar.qux"], "Includes not as expected")
		
		query.removeInclude("bar")
		XCTAssertEqual(query.includes, ["qux", "bar.qux"], "Includes not as expected")
	}
	
	func testAddPredicate() {
		var query = Query(resourceType: Foo.self)
		
		let predicate = NSComparisonPredicate(
			leftExpression: NSExpression(forKeyPath: "property"),
			rightExpression: NSExpression(forConstantValue: "value"),
			modifier: .DirectPredicateModifier,
			type: .EqualToPredicateOperatorType,
			options: NSComparisonPredicateOptions.allZeros)
		
		query.addPredicate(predicate)
		
		XCTAssertEqual(query.filters, [predicate], "Filters not as expected")
	}
	
	func testWherePropertyEqualTo() {
		var query = Query(resourceType: Foo.self)
		query.whereProperty("property", equalTo: "value")
		
		let predicate = NSComparisonPredicate(
			leftExpression: NSExpression(forKeyPath: "property"),
			rightExpression: NSExpression(forConstantValue: "value"),
			modifier: .DirectPredicateModifier,
			type: .EqualToPredicateOperatorType,
			options: NSComparisonPredicateOptions.allZeros)
		
		XCTAssertEqual(query.filters, [predicate], "Filters not as expected")
	}
	
	func testWherePropertyNotEqualTo() {
		var query = Query(resourceType: Foo.self)
		query.whereProperty("property", notEqualTo: "value")
		
		let predicate = NSComparisonPredicate(
			leftExpression: NSExpression(forKeyPath: "property"),
			rightExpression: NSExpression(forConstantValue: "value"),
			modifier: .DirectPredicateModifier,
			type: .NotEqualToPredicateOperatorType,
			options: NSComparisonPredicateOptions.allZeros)
		
		XCTAssertEqual(query.filters, [predicate], "Filters not as expected")
	}
	
	func testWherePropertyLessThan() {
		var query = Query(resourceType: Foo.self)
		query.whereProperty("property", lessThan: "10")
		
		let predicate = NSComparisonPredicate(
			leftExpression: NSExpression(forKeyPath: "property"),
			rightExpression: NSExpression(forConstantValue: "10"),
			modifier: .DirectPredicateModifier,
			type: .LessThanPredicateOperatorType,
			options: NSComparisonPredicateOptions.allZeros)
		
		XCTAssertEqual(query.filters, [predicate], "Filters not as expected")
	}
	
	func testWherePropertyLessThanOrEqualTo() {
		var query = Query(resourceType: Foo.self)
		query.whereProperty("property", lessThanOrEqualTo: "10")
		
		let predicate = NSComparisonPredicate(
			leftExpression: NSExpression(forKeyPath: "property"),
			rightExpression: NSExpression(forConstantValue: "10"),
			modifier: .DirectPredicateModifier,
			type: .LessThanOrEqualToPredicateOperatorType,
			options: NSComparisonPredicateOptions.allZeros)
		
		XCTAssertEqual(query.filters, [predicate], "Filters not as expected")
	}
	
	func testWherePropertyGreaterThan() {
		var query = Query(resourceType: Foo.self)
		query.whereProperty("property", greaterThan: "10")
		
		let predicate = NSComparisonPredicate(
			leftExpression: NSExpression(forKeyPath: "property"),
			rightExpression: NSExpression(forConstantValue: "10"),
			modifier: .DirectPredicateModifier,
			type: .GreaterThanPredicateOperatorType,
			options: NSComparisonPredicateOptions.allZeros)
		
		XCTAssertEqual(query.filters, [predicate], "Filters not as expected")
	}
	
	func testWherePropertyGreaterThanOrEqualTo() {
		var query = Query(resourceType: Foo.self)
		query.whereProperty("property", greaterThanOrEqualTo: "10")
		
		let predicate = NSComparisonPredicate(
			leftExpression: NSExpression(forKeyPath: "property"),
			rightExpression: NSExpression(forConstantValue: "10"),
			modifier: .DirectPredicateModifier,
			type: .GreaterThanOrEqualToPredicateOperatorType,
			options: NSComparisonPredicateOptions.allZeros)
		
		XCTAssertEqual(query.filters, [predicate], "Filters not as expected")
	}
	
	func testWhereRelationshipIsOrContains() {
		let bar = Bar()
		bar.id = "3"
		
		var query = Query(resourceType: Foo.self)
		query.whereRelationship("relationshipName", isOrContains: bar)
		
		let predicate = NSComparisonPredicate(
			leftExpression: NSExpression(forKeyPath: "relationshipName"),
			rightExpression: NSExpression(forConstantValue: bar.id!),
			modifier: .DirectPredicateModifier,
			type: .EqualToPredicateOperatorType,
			options: NSComparisonPredicateOptions.allZeros)
		
		XCTAssertEqual(query.filters, [predicate], "Filters not as expected")
	}
	
	func testRestrictPropertiesTo() {
		var query = Query(resourceType: Foo.self)
		query.restrictPropertiesTo("firstProperty", "secondProperty")
		
		XCTAssertEqual(query.fields, [Foo.resourceType: ["firstProperty", "secondProperty"]], "Fields not as expected")
	}
	
	func testRestrictPropertiesOfResourceTypeTo() {
		var query = Query(resourceType: Foo.self)
		query.restrictPropertiesOfResourceType("bars", to: "firstProperty", "secondProperty")
		
		XCTAssertEqual(query.fields, ["bars": ["firstProperty", "secondProperty"]], "Fields not as expected")
	}
	
}
