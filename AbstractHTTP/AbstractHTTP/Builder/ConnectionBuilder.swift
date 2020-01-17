//
//  ConnectionBuilder.swift
//  AbstractHTTP
//
//  Created by Keita Yamamoto on 2020/01/17.
//  Copyright © 2020 altonotes Inc. All rights reserved.
//

import Foundation

public class ConnectionBuilder {

    var url: String
    var httpMethod: HTTPMethod = .get
    var headers: [String: String] = [:]
    var urlQuery: URLQuery?
    var body: Data?
    var listeners: [ConnectionListener] = []
    var responseListeners: [ConnectionResponseListener] = []
    var errorListeners: [ConnectionErrorListener] = []

    public init(url: String) {
        self.url = url
    }

    public func httpMethod(_ httpMethod: HTTPMethod) -> ConnectionBuilder {
        self.httpMethod = httpMethod
        return self
    }

    public func headers(_ headers: [String: String]) -> ConnectionBuilder {
        self.headers = headers
        return self
    }

    public func urlQuery(_ urlQuery: URLQuery) -> ConnectionBuilder {
        self.urlQuery = urlQuery
        return self
    }

    public func body(_ body: Data) -> ConnectionBuilder {
        self.body = body
        return self
    }

    public func asString(callback: (String) -> Void) {
    }

    public func asData(callback: (Data) -> Void) {
    }

    public func asResponse(callback: (Response) -> Void) {
    }

    public func asDecodable<T: Decodable>(type: T.Type, callback: (T) -> Void) {
    }

    public func asModel<T>(parse: (Response) -> T, callback: (T) -> Void) {
    }

    public func addListener(_ listener: ConnectionListener) -> ConnectionBuilder {
        listeners.append(listener)
        return self
    }

    public func addResponseListener(_ listener: ConnectionResponseListener) -> ConnectionBuilder {
        responseListeners.append(listener)
        return self
    }

    public func addErrorListener(_ listener: ConnectionErrorListener) -> ConnectionBuilder {
        errorListeners.append(listener)
        return self
    }

    public func addOnError(onError: @escaping (ConnectionError, Response?, Any?) -> Void) -> ConnectionBuilder {
        return addErrorListener(OnError(onError))
    }

    public func addOnEnd(onEnd: @escaping (Response?, Any?, ConnectionError?) -> Void) -> ConnectionBuilder {
        return addListener(OnEnd(onEnd))
    }

    private func start() {
        let spec = CustomConnectionSpec(url: url, httpMethod: httpMethod, headers: headers, urlQuery: urlQuery, body: body)
        Connection(spec) { response in

        }.start()
    }

    // TODO httpConnector、URLEncoder、isLogEnabledの書き換え
}

class CustomConnectionSpec: ConnectionSpec {
    typealias ResponseModel = Response

    let url: String
    let httpMethod: HTTPMethod
    let headers: [String: String]
    let urlQuery: URLQuery?
    let body: Data?

    init(url: String, httpMethod: HTTPMethod, headers: [String: String], urlQuery: URLQuery?, body: Data?) {
        self.url = url
        self.httpMethod = httpMethod
        self.headers = headers
        self.urlQuery = urlQuery
        self.body = body
    }

    func makePostData() -> Data? {
        return body
    }

    func isValidResponse(response: Response) -> Bool {
        return true
    }

    func parseResponse(response: Response) throws -> Response {
        return response
    }
}
