//
//  CustomConnectionSpec.swift
//  AbstractHTTP
//
//  Created by Keita Yamamoto on 2020/01/17.
//  Copyright © 2020 altonotes Inc. All rights reserved.
//

import Foundation

class CustomConnectionSpec<T>: ConnectionSpec {
    typealias ResponseModel = T

    let url: String
    let httpMethod: HTTPMethod
    let headers: [String: String]
    let urlQuery: URLQuery?
    let body: Data?
    let validate: ((Response) -> Bool)?
    let parse: (Response) throws -> T

    init(url: String,
         httpMethod: HTTPMethod,
         headers: [String: String],
         urlQuery: URLQuery?,
         body: Data?,
         validate: ((Response) -> Bool)?,
         parse: @escaping (Response) throws -> T) {

        self.url = url
        self.httpMethod = httpMethod
        self.headers = headers
        self.urlQuery = urlQuery
        self.body = body
        self.validate = validate
        self.parse = parse
    }

    func validate(response: Response) -> Bool {
        return validate?(response) ?? true
    }

    func parseResponse(response: Response) throws -> T {
        return try parse(response)
    }
}
