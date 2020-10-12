//
//  NotOfResolver.swift
//
//  Created by Andre Weinkoetz on 21.08.20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import OpenAPIKit

struct NotOfResolver {
    
    /// Resolves $not types
    /// - Parameters:
    ///   - name: name of object
    ///   - schema: schemas to check
    /// - Throws: throws if type cannot be resolved
    /// - Returns: NotModel
    static func resolve(objectName name: String, schema: JSONSchema) throws -> NotModel {
        let notOfType = try! PrimitiveTypeResolver.resolveTypeFormat(schema: schema)
        notOfReferences.append(name)
        return NotModel(name: name, notOfType: notOfType, detail: schema.coreContext?.description ?? "")
    }
    
}
