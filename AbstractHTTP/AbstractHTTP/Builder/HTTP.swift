//
//  HTTP.swift
//  AbstractHTTP
//
//  Created by Keita Yamamoto on 2020/01/17.
//  Copyright © 2020 altonotes Inc. All rights reserved.
//

import Foundation

public class HTTP {

    var url: String
    var httpMethod: HTTPMethod = .get
    var headers: [String: String] = [:]
    var urlQuery: URLQuery?
    var body: Data?
    var listeners: [ConnectionListener] = []
    var responseListeners: [ConnectionResponseListener] = []
    var errorListeners: [ConnectionErrorListener] = []

    public init(_ url: String) {
        self.url = url
    }

    public func httpMethod(_ httpMethod: HTTPMethod) -> HTTP {
        self.httpMethod = httpMethod
        return self
    }

    public func headers(_ headers: [String: String]) -> HTTP {
        self.headers = headers
        return self
    }

    public func urlQuery(_ urlQuery: URLQuery) -> HTTP {
        self.urlQuery = urlQuery
        return self
    }

    public func body(_ body: Data) -> HTTP {
        self.body = body
        return self
    }

    public func asResponse(_ callback: @escaping (Response) -> Void) {
        start(parse: { response in response }, callback: callback)
    }

    public func asString(encoding: String.Encoding = .utf8, _ callback: @escaping (String) -> Void) {
        start(parse: { response in
            return String(bytes: response.data, encoding: encoding) ?? ""
        }, callback: callback)
    }

    public func asData(_ callback: @escaping (Data) -> Void) {
        start(parse: { response in
            return response.data
        }, callback: callback)
    }

    public func asDecodable<T: Decodable>(type: T.Type, _ callback: @escaping (T) -> Void) {
        start(parse: { response in
            return try JSONDecoder().decode(type.self, from: response.data)
        }, callback: callback)
    }

    public func asModel<T>(parse: @escaping (Response) throws -> T, _ callback: @escaping (T) -> Void) {
        start(parse: parse, callback: callback)
    }

    public func addListener(_ listener: ConnectionListener) -> HTTP {
        listeners.append(listener)
        return self
    }

    public func addResponseListener(_ listener: ConnectionResponseListener) -> HTTP {
        responseListeners.append(listener)
        return self
    }

    public func addErrorListener(_ listener: ConnectionErrorListener) -> HTTP {
        errorListeners.append(listener)
        return self
    }

    public func addOnError(onError: @escaping (ConnectionError, Response?, Any?) -> Void) -> HTTP {
        return addErrorListener(OnError(onError))
    }

    public func addOnEnd(onEnd: @escaping (Response?, Any?, ConnectionError?) -> Void) -> HTTP {
        return addListener(OnEnd(onEnd))
    }

    private func start<T>(parse: @escaping (Response) throws -> T, callback: @escaping (T) -> Void) {
        let spec = CustomConnectionSpec(url: url,
                                        httpMethod: httpMethod,
                                        headers: headers,
                                        urlQuery: urlQuery,
                                        body: body,
                                        parse: parse)
        
        let connection = Connection(spec, onSuccess: callback)

        listeners.forEach { connection.addListener($0) }
        responseListeners.forEach { connection.addResponseListener($0) }
        errorListeners.forEach { connection.addErrorListener($0) }

        connection.start()
    }

    // TODO httpConnector、URLEncoder、isLogEnabledの書き換え
}

class CustomConnectionSpec<T>: ConnectionSpec {
    typealias ResponseModel = T

    let url: String
    let httpMethod: HTTPMethod
    let headers: [String: String]
    let urlQuery: URLQuery?
    let body: Data?
    let parse: (Response) throws -> T

    init(url: String, httpMethod: HTTPMethod, headers: [String: String], urlQuery: URLQuery?, body: Data?, parse: @escaping (Response) throws -> T) {
        self.url = url
        self.httpMethod = httpMethod
        self.headers = headers
        self.urlQuery = urlQuery
        self.body = body
        self.parse = parse
    }

    func makeBody() -> Data? {
        return body
    }

    func isValidResponse(response: Response) -> Bool {
        return true
    }

    func parseResponse(response: Response) throws -> T {
        return try parse(response)
    }
}
