//
//  Mapping.swift
//  Spine
//
//  Created by Ward van Teijlingen on 23-08-14.
//  Copyright (c) 2014 Ward van Teijlingen. All rights reserved.
//

import Foundation
import SwiftyJSON

struct JSONAPIDocument {
	/// Primary resources extracted from the response.
	var data: [ResourceProtocol]?
	
	/// Errors extracted from the response.
	var errors: [NSError]?
	
	/// Metadata extracted from the reponse
	var meta: [String: AnyObject]?
	
	/// Links extracted from the response
	var links: [String: NSURL]?
}

/**
Serialization options that can be passed to the serializer.
*/
struct SerializationOptions {
	/// Whether to include the resource ID in the serialized representation.
	var includeID = true
	
	/// Whether to only serialize fields that are dirty.
	var dirtyFieldsOnly = true
	
	/// Whether to include to-many linked resources in the serialized representation.
	var includeToMany = false
	
	/// Whether to include to-one linked resources in the serialized representation.
	var includeToOne = false
	
	init(includeID: Bool = true, dirtyFieldsOnly: Bool = false, includeToMany: Bool = false, includeToOne: Bool = false) {
		self.includeID = includeID
		self.dirtyFieldsOnly = dirtyFieldsOnly
		self.includeToMany = includeToMany
		self.includeToOne = includeToOne
	}
}

/**
The SerializerProtocol declares methods and properties that a serializer must implement.

The serializer is responsible for serializing and deserialing resources.
It stores information about the Resource classes using a ResourceClassMap
and uses SerializationOperations and DeserialisationOperations for (de)s
*/
protocol SerializerProtocol {
	/// The resource factory used for dispensing resources.
	var resourceFactory: ResourceFactory { get }
	
	/// The transformers used for transforming to and from the serialized representation.
	var transformers: TransformerDirectory { get }
	
	/**
	Deserializes the given data into a SerializationResult. This is a thin wrapper around
	a DeserializeOperation that does the actual deserialization.
	
	Use this method if you want to deserialize onto existing Resource instances. Otherwise, use
	the regular `deserializeData` method.
	
	:param: data  The data to deserialize.
	:param: store A Store that contains Resource instances onto which data will be deserialize.
	
	:returns: A DeserializationResult that contains either a Store or an error.
	*/
	func deserializeData(data: NSData, mappingTargets: [ResourceProtocol]?) -> Failable<JSONAPIDocument>
	
	/**
	Serializes the given Resources into a multidimensional dictionary/array structure
	that can be passed to NSJSONSerialization.
	
	:param: resources The resources to serialize.
	:param: mode      The serialization mode to use.
	
	:returns: A multidimensional dictionary/array structure.
	*/

	func serializeResources(resources: [ResourceProtocol], options: SerializationOptions) -> NSData
}

/**
The built in serializer that (de)serializes according to the JSON:API specification.
*/
class JSONSerializer: SerializerProtocol {
	var resourceFactory = ResourceFactory()
	var transformers = TransformerDirectory.defaultTransformerDirectory()
	
	
	func deserializeData(data: NSData, mappingTargets: [ResourceProtocol]?) -> Failable<JSONAPIDocument> {		
		let deserializeOperation = DeserializeOperation(data: data, resourceFactory: resourceFactory)
		deserializeOperation.transformers = transformers
		
		if let mappingTargets = mappingTargets {
			deserializeOperation.addMappingTargets(mappingTargets)
		}
		
		deserializeOperation.start()
		return deserializeOperation.result!
	}
	
	func serializeResources(resources: [ResourceProtocol], options: SerializationOptions = SerializationOptions()) -> NSData {
		let serializeOperation = SerializeOperation(resources: resources)
		serializeOperation.options = options
		serializeOperation.transformers = transformers
		
		serializeOperation.start()
		return serializeOperation.result!
	}
}

/**
A ResourceFactory creates resources from given factory funtions.
*/
struct ResourceFactory {
	
	private var factoryFunctions: [ResourceType: () -> ResourceProtocol] = [:]

	/**
	Registers a given factory function that creates resource with a given type.
	Registering a function for an already registered resource type will override that factory function.
	
	:param: type    The resource type for which to register a factory function.
	:param: factory The factory function that returns a resource.
	*/
	mutating func registerResource(type: ResourceType, factory: () -> ResourceProtocol) {
		factoryFunctions[type] = factory
	}

	/**
	Instantiates a resource with the given type, by using a registered factory function.
	
	:param: type The resource type to instantiate.
	
	:returns: An instantiated resource.
	*/
	func instantiate(type: ResourceType) -> ResourceProtocol {
		assert(factoryFunctions[type] != nil, "Cannot instantiate resource of type \(type). You must register this type with Spine first.")
		return factoryFunctions[type]!()
	}
	
	/**
	Dispenses a resource with the given type and id, optionally by finding it in a pool of existing resource instances.
	
	This methods tries to find a resource with the given type and id in the pool. If no matching resource is found,
	it tries to find the nth resource, indicated by `index`, of the given type from the pool. If still no resource is found,
	it instantiates a new resource with the given id.
	
	:param: type  The resource type to dispense.
	:param: id    The id of the resource to dispense.
	:param: pool  An array of resources in which to find exisiting matching resources.
	:param: index Optional index of the resource in the pool.
	
	:returns: A resource with the given type and id.
	*/
	func dispense(type: ResourceType, id: String, inout pool: [ResourceProtocol], index: Int? = nil) -> ResourceProtocol {
		var resource: ResourceProtocol! = findResource(pool, type, id)
		
		if resource == nil && index != nil && !isEmpty(pool) {
			let applicableResources = findResourcesWithType(pool, type)
			if index! < applicableResources.count {
				resource = applicableResources[index!]
			}
		}
		
		if resource == nil {
			resource = instantiate(type)
			resource.id = id
			pool.append(resource)
		}

		return resource
	}
}