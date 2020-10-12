//
//  AllOfResolver.swift
//
//  Created by Andre Weinkoetz on 21.08.20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import OpenAPIKit

/// Resolves all $allOf types in document
struct AllOfResolver {
    
    /// Resolve $allOf types in document
    /// - Parameters:
    ///   - name: name of object
    ///   - schemas: schemas to check
    /// - Returns: Object model
    static func resolve(objectName name: String, schemas: [JSONSchema]) -> ObjectModel {
        var primary : ObjectModel = ObjectModel(name: name, attributes: [], detail: "")
        var inherited = [AttributeModel]()
        for s in schemas {
            switch s {
            case .object(let core, let object):
                primary = ObjectResolver.resolve(name: name, context: core, schema: object)
                break
            case .reference(let refContext):
                inherited.append(contentsOf: try! ReferenceResolver.resolveAttributes(reference: refContext))
            default:
                break
            }
        }
        primary.attributes.append(contentsOf: inherited)
        return primary
    }
    
}
