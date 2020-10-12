//
//  ObjectResolver.swift
//
//  Created by Andre Weinkoetz on 21.08.20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import OpenAPIKit

/// Resolves object models stated in open api document
struct ObjectResolver {
    
    /// Resolves all top level objects from open api document (schema components)
    /// - Parameters:
    ///   - name: name of object
    ///   - context: general schema context
    ///   - schema: object context
    /// - Returns: resolved object model
    static func resolve(name: String, context: JSONSchemaContext, schema: JSONSchema.ObjectContext) -> ObjectModel {
        let objModel = ObjectModel(name: name, attributes: [], detail: context.description)
        objModel.attributes = schema.properties.map({ (attributeName, attributeSchema) -> AttributeModel in
            try! PropertyResolver.resolve(name: attributeName, schema: attributeSchema)
        })
        return objModel
    }
}
