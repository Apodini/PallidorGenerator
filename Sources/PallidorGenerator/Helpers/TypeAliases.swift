//
//  TypeAliases.swift
//
//  Created by Andre Weinkoetz on 21.08.20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import OpenAPIKit

struct TypeAliases {
    
    /** Parses all type aliases in open api document
     *  A type alias in the open api specification is defined for this library
     *  as a top level schema component which does not contain any properties
     *  but simply refers to another type (either primitive or complex).
     * - Parameter resolvedDoc: parsed document from OpenAPIKit
    */
    static func parse(resolvedDoc: ResolvedDocument) {
        for (name, schema) in resolvedDoc.components.schemas {
            switch schema {
            case .integer(let generalContext, _):
                if generalContext.allowedValues == nil {
                    let attributeType = generalContext.format.rawValue.isEmpty ? "Int" : generalContext.format.rawValue.capitalized
                    TypeAliases.store[name.rawValue] = attributeType
                }
                break
            case .number(let generalContext, _):
                if generalContext.allowedValues == nil {
                    let attributeType = generalContext.format.rawValue.isEmpty ? "Double" : generalContext.format.rawValue.capitalized
                    TypeAliases.store[name.rawValue] = attributeType
                }
                break
            case .string(let generalContext, _):
                if generalContext.allowedValues == nil {
                    TypeAliases.store[name.rawValue] = "String"
                }
                break
            case .array(_, let context):
                let type = ArrayResolver.resolveArrayItemType(schema: context.items!)
                TypeAliases.store[name.rawValue] = "[\(type)]"
            default:
                break
            }
        }
    }
    
    /// temp. storage where all type aliases are mapped to their actual types
    static var store: [String:String] = [String:String]()
}
