//
//  NotOfResolver+ReferenceHelper.swift
//  
//  Created by Andre Weinkoetz on 21.08.20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

extension NotOfResolver {
    
    /// types which are references in NotModels
    static var notOfReferences = [String]()
    /// types which are referenced by NotModel references
    static var notOfReferred = [String]()
    
    /// Returns true if the given type is generic (only possible when somehow referenced to $not model)
    /// - Parameter type: type to check
    /// - Returns: true if generic
    static func isGeneric(type: String) -> Bool {
        return notOfReferred.contains(type) || notOfReferences.contains(type)
    }
    
    
    /// Resolves all objects which reference a $not model either directly or indirectly
    /// - Parameter objects: list of object models to check
    static func resolveReferenced(objects: [ObjectModel?]) {
        
        for o in objects {
            
            guard let o = o else {
                continue
            }
            
            for a in o.attributes {
                
                let isRef = notOfReferences.contains(a.type) || notOfReferred.contains(a.type)
                let isKnown = o.isGeneric
                
                if isKnown {
                    continue
                }
                
                if isRef {
                    notOfReferred.append(o.name)
                    o.isGeneric = true
                    resolveReferenced(objects: objects)
                }
            }
        }
    }
    
}
