//
//  ModelError.swift
//
//  Created by Andre Weinkoetz on 21.08.20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

/// Errors which can occur during converting open api document
enum ResolvementError : Error {
    case NestedObjectError(msg: String)
    case UnknownType(msg: String)
    case NotSupported(msg: String)
    case ReferenceTypeNotFound(msg: String)
}
