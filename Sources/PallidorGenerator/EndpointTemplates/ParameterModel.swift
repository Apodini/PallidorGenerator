//
//  ParameterModel.swift
//
//  Created by Andre Weinkoetz on 21.08.20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import OpenAPIKit

/// model for parameters
struct ParameterModel : CustomStringConvertible {
    var description: String {
        get {
            "\(name): \(type)\(required ? "" : "?")"
        }
    }
    
    /// name of this parameter
    var name: String
    /// type of this parameter
    var type: String
    /// comment for this parameter
    var detail: String?
    /// location of parameter (header, query, cookie, path)
    var location : Location
    /// true if param is required in specification
    var required : Bool = false
    
    /// description inside method body
    var opDescription : String {
        get {
            switch location {
            case .cookie(_):
                return ""
            case .path(let name):
                return "path = path.replacingOccurrences(of: \"{\(name)}\", with: String(\(name)))"
            case .query(let name):
                return  required ?
                    "&\(name)=\\(\(queryInitializer)\(type.contains("[") ? "\(!required ? "?" : "" ).joined(separator: \"&\")" : "")\(!required ? " ?? \"\"" : ""))"
                    : "\\(\(name) != nil ? \"&\(name)=\\(\(queryInitializer)\(type.contains("[") ? "\(!required ? "?" : "" ).joined(separator: \"&\")" : "")\(!required ? " ?? \"\"" : ""))\" : \"\")"
            case .header(let headerField):
                return "customHeaders[\"\(headerField)\"] = \(required ? "\(name).description" : "\(name)?.description ?? \"\"")"
            }
        }
    }
    
    private var queryInitializer : String {
        name == "String" || type.contains("[") ? name : "\(name)\(required ? "" : "?").description"
    }
    
    /// Possible location of parameters
    enum Location : Equatable {
        case path(String)
        case query(String)
        case header(String)  /** not "Accept", "Content-Type" or "Authorization" */
        case cookie(String)
    }
}

extension ParameterModel {
    
    /// Resolves parameter from OpenAPI document operation
    /// - Parameter param: Parameter from OpenAPI document
    /// - Returns: ParameterModel object
    static func resolve(param: DereferencedParameter) -> ParameterModel {
        
        var location = ParameterModel.Location.path(param.name)
        
        switch param.location {
        case .cookie:
            location = .cookie(param.name)
            break
        case .header:
            location = .header(param.name)
            break
        case .query:
            location = .query(param.name)
            break
        default:
            break
        }
                
        return ParameterModel(name: param.name, type: try! PrimitiveTypeResolver.resolveTypeFormat(schema: param.schemaOrContent.a!.schema), detail: param.description, location: location, required: param.required)
    }
}
