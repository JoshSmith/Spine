//
//  Routing.swift
//  Spine
//
//  Created by Ward van Teijlingen on 24-09-14.
//  Copyright (c) 2014 Ward van Teijlingen. All rights reserved.
//

import Foundation

public protocol RouterProtocol {
	var baseURL: NSURL! { get set }
	
	func URLForResourceType(type: String) -> NSURL
	func URLForRelationship(relationship: String, ofResource resource: ResourceProtocol) -> NSURL
	func URLForRelationship(relationship: String, ofResource resource: ResourceProtocol, ids: [String]) -> NSURL
	func URLForQuery<T: ResourceProtocol>(query: Query<T>) -> NSURL
}

public class Router: RouterProtocol {
	public var baseURL: NSURL! = nil

	public func URLForResourceType(type: String) -> NSURL {
		return baseURL.URLByAppendingPathComponent(type)
	}
	
	public func URLForRelationship(relationship: String, ofResource resource: ResourceProtocol) -> NSURL {
		assert(resource.id != nil, "Cannot build URL for relationship for resource without id: \(resource)")
		return URLForResourceType(resource.type).URLByAppendingPathComponent("/\(resource.id!)/links/\(relationship)")
	}

	public func URLForRelationship(relationship: String, ofResource resource: ResourceProtocol, ids: [String]) -> NSURL {
		var URL = URLForRelationship(relationship, ofResource: resource)
		return URL.URLByAppendingPathComponent(",".join(ids))
	}

	public func URLForQuery<T: ResourceProtocol>(query: Query<T>) -> NSURL {
		var URL: NSURL!
		
		// Base URL
		if let URLString = query.URL?.absoluteString {
			URL = NSURL(string: URLString, relativeToURL: baseURL)
		} else if let type = query.resourceType {
			URL = baseURL.URLByAppendingPathComponent(type, isDirectory: true)
		} else {
			assertionFailure("Cannot build URL for query. Query does not have a URL, nor a resource type.")
		}
		
		var URLComponents = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true)!
		var queryItems: [NSURLQueryItem] = (URLComponents.queryItems as? [NSURLQueryItem]) ?? []
		
		// Resource IDs
		if let IDs = query.resourceIDs {
			if IDs.count == 1 {
				URLComponents.path = URLComponents.path?.stringByAppendingPathComponent(IDs.first!)
			} else {
				var item = NSURLQueryItem(name: "filter[id]", value: join(",", IDs))
				setQueryItem(item, forQueryItems: &queryItems)
			}
		}
		
		// Includes
		if !query.includes.isEmpty {
			var item = NSURLQueryItem(name: "include", value: ",".join(query.includes))
			setQueryItem(item, forQueryItems: &queryItems)
		}
		
		// Filters
		for filter in query.filters {
			let item = queryItemForFilter(filter)
			setQueryItem(item, forQueryItems: &queryItems)
		}
		
		// Fields
		for (resourceType, fields) in query.fields {
			var item = NSURLQueryItem(name: "fields[\(resourceType)]", value: ",".join(fields))
			setQueryItem(item, forQueryItems: &queryItems)
		}
		
		// Sorting
		if !query.sortDescriptors.isEmpty {
			let descriptorStrings = query.sortDescriptors.map { descriptor -> String in
				if descriptor.ascending {
					return "+\(descriptor.key!)"
				} else {
					return "-\(descriptor.key!)"
				}
			}
			
			var item = NSURLQueryItem(name: "sort", value: ",".join(descriptorStrings))
			setQueryItem(item, forQueryItems: &queryItems)
		}
		
		// Pagination
		if let page = query.page {
			var item = NSURLQueryItem(name: "page", value: String(page))
			setQueryItem(item, forQueryItems: &queryItems)
		}
		
		if let pageSize = query.pageSize {
			var item = NSURLQueryItem(name: "page_size", value: String(pageSize))
			setQueryItem(item, forQueryItems: &queryItems)
		}
		
		// Compose URL
		if !queryItems.isEmpty {
			URLComponents.queryItems = queryItems
		}
		
		return URLComponents.URL!
	}
	
	public func queryItemForFilter(filter: NSComparisonPredicate) -> NSURLQueryItem {
		assert(filter.predicateOperatorType == .EqualToPredicateOperatorType, "The built in router only supports Query filter expressions of type 'equalTo'")
		return NSURLQueryItem(name: "filter[\(filter.leftExpression.keyPath)]", value: "\(filter.rightExpression.constantValue)")
	}
	
	private func setQueryItem(queryItem: NSURLQueryItem, inout forQueryItems queryItems: [NSURLQueryItem]) {
		queryItems.filter { return $0.name != queryItem.name }
		queryItems.append(queryItem)
	}
}