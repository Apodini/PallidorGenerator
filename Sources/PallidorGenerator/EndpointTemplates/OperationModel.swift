//
//  OperationModel.swift
//
//  Created by Andre Weinkoetz on 21.08.20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import OpenAPIKit

/// Model for operations of endpoint
struct OperationModel {
    /// identifier from OpenAPI document
    var operationId : String
    /// comment
    var detail : String?
    /// method as stated in document
    var httpMethod : OpenAPI.HttpMethod
    /// path where method is located
    var path : OpenAPI.Path
    /// list of parameters for this method
    var parameters : [ParameterModel]?
    /// true if method requires authentication
    var requiresAuth: Bool = false
    
    /// filtered params for query params
    private var queryParams : [ParameterModel]? {
        get { parameters?.filter({ (param) -> Bool in
            if case .query = param.location {
                return true
            }
            return false
        }).sorted(by: {$0.name < $1.name})
    }}
    
    /// filtered params for path params
    private var pathParams : [ParameterModel]? {
        get { parameters?.filter({ (param) -> Bool in
            if case .path = param.location {
                return true
            }
            return false
        }).sorted(by: {$0.name < $1.name}) }
    }
    
    /// filtered params for header params
    private var headerParams : [ParameterModel]? {
        get { parameters?.filter({ (param) -> Bool in
            if case .header = param.location {
                return true
            }
            return false
        }).sorted(by: {$0.name < $1.name}) }
    }
    
    /// request body for this method if available
    var requestBody : RequestBodyModel?
    
    /// responses (errors and success) for this method
    var responses : [ResponseModel]
    
    /// success type for this method
    var successType : String {
        get { responses.first(where: {$0.code.isSuccess})?.description ?? "String" }
    }
    
    /// list of possible failures for this method
    var failures : [ResponseModel] {
        get { responses.filter({!$0.code.isSuccess}) }
    }
    
    /// explicit failure type
    var failureType : String {
        get { responses.first(where: {!$0.code.isSuccess})?.description ?? "String" }
    }
        
}

extension OperationModel {
    
    /// Resolves operations from open api document
    /// - Parameter endpoint: endpoint in which this method is located
    /// - Returns: operation model
    static func resolve(endpoint: ResolvedEndpoint) -> OperationModel {
         let requestBody = RequestBodyModel.resolve(request: endpoint.requestBody?.underlyingRequest)
        let responses = endpoint.responses.map({ResponseModel.resolve(code: $0, response: $1.underlyingResponse)})
         let parameters = endpoint.parameters.map { ParameterModel.resolve(param: $0) }
         
         return OperationModel(operationId: endpoint.operationId!, detail: endpoint.endpointDescription, httpMethod: endpoint.method, path: endpoint.path, parameters: parameters, requiresAuth: !endpoint.security.isEmpty, requestBody: requestBody, responses: responses)

     }
}

extension OperationModel : CustomStringConvertible {
    
    var comment : String {
        get {
            """
            /**
            \(detail?.removeOAIIllegalCharacters() ?? "")
            \(requestBody != nil ? "RequestBody:\n   - element \(requestBody!.detail ?? "")" : "")
            Responses:
            \(responses.sorted(by: {$0.code.rawValue < $1.code.rawValue}).map({$0.detail != nil ? "   - \($0.code.rawValue): \($0.detail!)" : "   - \($0.code.rawValue)"}).joined(separator: "\n"))
            */
            """
        }
    }
    
    /// mapping for failures of method
    var failureTryMap : String {
        get {
            """
            .tryMap { data, response in
                    guard let r = response as? HTTPURLResponse, 200..<299 ~= r.statusCode else {
                    let httpResponse = response as! HTTPURLResponse
            
                    \(failures.sorted(by: {$0.code.rawValue < $1.code.rawValue}).map({ (failure) -> String in
                    failure.code.rawValue != "default" ?
                        """
                        if httpResponse.statusCode == \(failure.code.rawValue) {
                            \(failure.errorDecoderString)
                        }
                        """
                        :
                        ""
                    }).joined(separator: "\n"))
            
                        throw _OpenAPIError.urlError(URLError(URLError.Code(rawValue: httpResponse.statusCode)))
                    }
                    \(successDecoding)
            }
            """
        }
    }
    
    /// success decoding for method
    var successDecoding : String {
        get {
            successType.isPrimitiveType && (!successType.isPrimitiveDictionary && !successType.isPrimitiveArray)
                ? successType == "String" ? "return String(data: data, encoding: .utf8)!" : "return \(successType)(String(data: data, encoding: .utf8)!)!"
            : "return data"
        }
    }
    
    /// changes content type if request body is in binary format
    var specialContentType : String? {
        get {
            if let requestBody = requestBody {
                return requestBody.formats.contains(where: {$0.rawValue == "application/octet-stream"}) ?
                    " = \"application/octet-stream\""
                    : nil
            }
            return nil
        }
    }
    
    /// description for this methods `NetworkManager` call
    var operationDescription : String {
        let headers = headerParams != nil && !headerParams!.isEmpty ? ", headers: customHeaders" : ""
        switch httpMethod {
        case .get:
            return "return NetworkManager.getElement(on: URL(string: path)!, authorization: authorization, contentType: contentType\(headers))"
        case .post:
            return requestBody != nil ? "return NetworkManager.postElement(element, authorization: authorization, on: URL(string: path)!, contentType: contentType\(headers))" : "return NetworkManager.postElement(authorization: authorization, on: URL(string: path)!, contentType: contentType\(headers))"
        case .patch:
            return requestBody != nil ? "return NetworkManager.patchElement(element, authorization: authorization, on: URL(string: path)!, contentType: contentType\(headers))" : "return NetworkManager.patchElement(authorization: authorization, on: URL(string: path)!, contentType: contentType\(headers))"
        case .put:
            return requestBody != nil ? "return NetworkManager.putElement(element, authorization: authorization, on: URL(string: path)!, contentType: contentType\(headers))" : "return NetworkManager.putElement(authorization: authorization, on: URL(string: path)!, contentType: contentType\(headers))"
        case .delete:
            return "return NetworkManager.delete(at: URL(string: path)!, authorization: authorization, contentType: contentType\(headers))"
        case .head:
            return "return NetworkManager.head(at: URL(string: path)!, authorization: authorization, contentType: contentType\(headers))"
        case .options:
            return "return NetworkManager.options(at: URL(string: path)!, authorization: authorization, contentType: contentType\(headers))"
        case .trace:
            return "return NetworkManager.trace(at: URL(string: path)!, authorization: authorization, contentType: contentType\(headers))"
        }
    }
    
    var description: String {
        get {
            let parametersString : [String?] = [parameters != nil ? parameters!.sorted(by: {$0.name <= $1.name}).map({$0.description}).joined(separator: ", ") : nil, requestBody != nil ? requestBody!.description : nil, "authorization: HTTPAuthorization\(requiresAuth ? "" : "?") = NetworkManager.authorization\(requiresAuth ? "!" : ""), contentType: String?\(specialContentType != nil ? specialContentType! : " = NetworkManager.defaultContentType")"]
            let isGeneric = NotOfResolver.isGeneric(type: successType)
            return """
            \(comment)
            static func \(operationId)\(isGeneric ? "<T : Codable>" : "")(\(parametersString.skipEmptyJoined(separator: ", "))) -> AnyPublisher<\(isGeneric ? "\(successType)<T>" : successType), Error> {
            \(parameters != nil && !parameters!.isEmpty ? "var" : "let") path = NetworkManager.basePath! + "\(path.rawValue)"
                \(pathParams != nil ? pathParams!.map({$0.opDescription}).joined(separator: "\n") : "")
            \(queryParams != nil && !queryParams!.isEmpty ? "path += \"?\(queryParams!.first!.required ? "\(queryParams!.map({$0.opDescription}).joined().dropFirst())\"" : "\(queryParams!.map({$0.opDescription}).joined())\"")" : "")
            \(headerParams != nil && !headerParams!.isEmpty ? "var customHeaders = [String : String]()\n\(headerParams!.map({$0.opDescription}).joined(separator: "\n"))" : "")
                \(operationDescription)
            \(failureTryMap)\( successType.isPrimitiveType && !(successType.isPrimitiveArray || successType.isPrimitiveDictionary) ? "" : "\n.decode(type: \(successType).self, decoder: decoder)")
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
            }

            """
        }
    }
}
