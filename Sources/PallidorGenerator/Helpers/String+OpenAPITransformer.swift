//
//  String+OpenAPITransformer.swift
//  
//  Created by Andre Weinkoetz on 21.08.20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

extension String {
    
    /// Removes characters which are not allowed for this package
    /// - Returns: cleaned String
    func removeOAIIllegalCharacters() -> String {
        var result = self.replacingOccurrences(of: "-", with: "_")
        result = result.replacingOccurrences(of: "*/", with: "")
        result = result.replacingOccurrences(of: "/*", with: "")
        return result
    }
    
    /// Removes brackets from the string and returns `Array{String}`
    var replaceBrackets : String {
        get {
            
            guard self.contains("[") else {
                return self
            }
            
            let errorType = self.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
            return "Array\(errorType)"
        }
    }
    
    /// Replaces reserved keywords
    var normalized : String {
        self == "Error" ? "APIError" : self
    }
    
    /// returns string with the first letter uppercased
    func upperFirst() -> String {
        self.first!.uppercased() + self.dropFirst()
    }
    
    /// returns string with the first letter lowercased
    func lowerFirst() -> String {
        self.first!.lowercased() + self.dropFirst()
    }
    
    /// returns string with the first letter lowercased
    /// only used for $anyOf cases
    func caseLowerFirst() -> String {
        self.dropFirst().first!.lowercased() + self.dropFirst(2)
    }
}
