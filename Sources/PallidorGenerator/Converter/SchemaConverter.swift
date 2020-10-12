//
//  SchemaConverter.swift
//
//  Created by Andre Weinkoetz on 21.08.20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import OpenAPIKit
import PathKit

/// Converter: Takes the parsed OpenAPI document (from OpenAPIKit) and creates Model objects. These objects contain the template to be exported as a Swift file.
public struct SchemaConverter : Converting {
    var resolvedDocument: ResolvedDocument
    
    /// Content of this converter
    var schemas: [Schema?] = [Schema?]()
    
    private var objects = [ObjectModel?]()
    private var inheritedObjects = [OfModel?]()
    private var notOfModels = [NotModel?]()
    private var enums = [EnumModel?]()
    
    init(_ resolvedDocument: ResolvedDocument){
        self.resolvedDocument = resolvedDocument
        ReferenceResolver.components = resolvedDocument.components
    }
        
    mutating func writeToFile(path outputPath: Path) throws -> [URL] {
        
        var filePaths = [URL]()

        for s in schemas {
            if let s = s {
                let fileName = outputPath + Path("_\(s.name).swift")
                try s.description.write(to: fileName.url, atomically: true, encoding: .utf8)
                filePaths.append(fileName.url)
            }
        }
        
        return filePaths
    }
    
    
    /// Returns the schema by its identification
    /// - Parameter name: name of schema
    /// - Returns: schema object
    func getSchema(name: String) -> Schema? {
        schemas.first(where: {$0 != nil && $0!.name == name})!
    }
    
    mutating func parse() {
        parseEnumModels()
        parseObjectModels()
        
        NotOfResolver.resolveReferenced(objects: objects)
        
        schemas.append(contentsOf: objects)
        schemas.append(contentsOf: enums)
        schemas.append(contentsOf: notOfModels)
        
        var combinations = Set<String>()
        
        for m in schemas {
            if let o = m as? OfModel, o.typeOf == .anyOf {
                combinations = combinations.union(o.inheritedObjects.map({$0}))
            }
        }
        
        let combinedObjects = combinations.sorted(by: {$0 < $1}).map { (objectName) -> ObjectModel? in
            return schemas.first(where: {$0 != nil && $0!.name == objectName.replacingOccurrences(of: "_", with: "")})! as? ObjectModel
            }.powerSet.filter({$0.count > 1})

        let toAdd = combinedObjects.map { (models) -> ObjectModel in
            let sorted = models.sorted(by: {$0!.name < $1!.name})
            let name = sorted.map({$0!.name}).joined()
            let attributes = Array(Set<AttributeModel>(sorted.reduce([AttributeModel]()) { (attr, model) -> [AttributeModel] in
                return model!.attributes
            }))
            return ObjectModel(name: name, attributes: attributes, detail: "Auto generated for AnyOf Codable")
        }

        schemas.append(contentsOf: toAdd)
    }
    
    private mutating func parseObjectModels() {
        objects = try! resolvedDocument.components.schemas.map({ (name, schema) throws -> ObjectModel? in
            if case .object(let general, let objectContext) = schema {
                return ObjectResolver.resolve(name: name.rawValue, context: general, schema: objectContext)
            }
            
            if case .all(of: let schemas, core: _) = schema {
                return AllOfResolver.resolve(objectName: name.rawValue, schemas: schemas)
            }
            
            if case .one(of: let schemas, core: _) = schema {
                return OneOfResolver.resolve(objectName: name.rawValue, schemas: schemas)
            }
            
            if case .not(let schema, core: _) = schema {
                try! notOfModels.append(NotOfResolver.resolve(objectName: name.rawValue, schema: schema))
            }
            
            if case .any(of: let schemas, core: _) = schema {
                return AnyOfResolver.resolve(objectName: name.rawValue, schemas: schemas)
            }
            
            return nil
        })
    }
    
    private mutating func parseEnumModels() {
        enums = resolvedDocument.components.schemas.map { (name, schema) -> EnumModel? in
            switch schema {
            case .integer(let generalContext, _):
                guard generalContext.allowedValues == nil else {
                    return EnumModel(name: name.rawValue, enumValues: generalContext.allowedValues!.map({ (value) -> String in
                        value.value as! String
                    }), enumType: generalContext.format.rawValue.isEmpty ? "Int" : generalContext.format.rawValue.capitalized, detail: generalContext.description)
                }
                break
            case .number(let generalContext, _):
                guard generalContext.allowedValues == nil else {
                    return EnumModel(name: name.rawValue, enumValues: generalContext.allowedValues!.map({ (value) -> String in
                        value.value as! String
                    }), enumType: generalContext.format.rawValue.isEmpty ? "Double" : generalContext.format.rawValue.capitalized, detail: generalContext.description)
                }
                break
            case .string(let generalContext, _):
                guard generalContext.allowedValues == nil else {
                    return EnumModel(name: name.rawValue, enumValues: generalContext.allowedValues!.map({ (value) -> String in
                        value.value as! String
                    }), enumType: "String", detail: generalContext.description)
                }
                break
                
            default:
                break
            }
            return nil
        }
    }
    
}
