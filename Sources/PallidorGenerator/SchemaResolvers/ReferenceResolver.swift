//
//  ReferenceResolver.swift
//
//  Created by Andre Weinkoetz on 21.08.20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import OpenAPIKit

/// Resolves $ref references as stated in open api document
struct ReferenceResolver {
    
    /// List of parsed component schemas from open api document
    static var components : OpenAPI.Components?
    
    /// Resolving a simple $ref
    /// - Parameter schema: schema to check
    /// - Throws: ModelError if the reference is not in the local file
    /// - Returns: Type of referenced object as String
    static func resolveName(schema: JSONSchema) throws -> String {
        if case .reference(let refContext) = schema {
            let actualName = TypeAliases.store[refContext.name!] ?? refContext.name!
            return actualName.isPrimitiveType ? actualName : ( actualName.isArray ? "[_\(actualName)]" : "_\(actualName)" )
        }
        throw ResolvementError.ReferenceTypeNotFound(msg: "Reference type could not be found")
    }
    
    /// Resolves to a list of attributes within the $ref object
    /// - Parameters:
    ///   - schema: schema to check
    /// - Throws: ModelError if the reference is not in the local file
    /// - Returns: An array of AttributeModels to be added to another object model (e.g. in case of allOf)
    static func resolveAttributes(reference: JSONReference<JSONSchema>) throws -> [AttributeModel] {
        let obj = try components!.lookup(reference)
        return ObjectResolver.resolve(name: reference.name!, context: obj.coreContext!, schema: obj.objectContext!).attributes
    }
    
    /// Resolves the type of a JSONReference
    /// - Parameter schema: schema reference to check
    /// - Throws: error if type cannot be resolved
    /// - Returns: type as String
    static func resolveType(schema: JSONReference<JSONSchema>) throws -> String {
        let scheme = try components!.lookup(schema)
        return try PrimitiveTypeResolver.resolveTypeFormat(schema: scheme)
    }
    
    
}
