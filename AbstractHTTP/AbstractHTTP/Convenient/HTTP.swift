//
//  HTTP.swift
//  AbstractHTTP
//
//  Created by Keita Yamamoto on 2020/01/17.
//  Copyright © 2020 altonotes Inc. All rights reserved.
//

import Foundation

/// HTTP通信の簡易インターフェース
/// RequestSpec、ResponseSpecなどのプロトコルを実装せず簡易に通信を行いたい場合に使える
/// 内部的には `Connection` クラスを使って通信しているため、`Connection` クラスが持つ機能は全て使える
public class HTTP {

    var url: String
    var httpMethod: HTTPMethod = .get
    var headers: [String: String] = [:]
    var urlQuery: URLQuery?
    var body: Data?
    var isValidResponse: ((Response) -> Bool)?

    var listeners: [ConnectionListener] = []
    var responseListeners: [ConnectionResponseListener] = []
    var errorListeners: [ConnectionErrorListener] = []

    var httpConnector: HTTPConnector?
    var urlEncoder: URLEncoder?
    var callbackInMainThread: Bool?
    var isLogEnabled: Bool?
    var setupDefaultHTTPConnector: ((DefaultHTTPConnector) -> Void)?

    public weak var holder: ConnectionHolder?

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

    public func isValidResponse(_ isValidResponse: @escaping (Response) -> Bool) -> HTTP {
        self.isValidResponse = isValidResponse
        return self
    }

    public func httpConnector(_ httpConnector: HTTPConnector) {
        self.httpConnector = httpConnector
    }

    public func urlEncoder(_ urlEncoder: URLEncoder) {
        self.urlEncoder = urlEncoder
    }

    public func callbackInMainThread(_ callbackInMainThread: Bool) {
        self.callbackInMainThread = callbackInMainThread
    }

    public func isLogEnabled(_ isLogEnabled: Bool) {
        self.isLogEnabled = isLogEnabled
    }

    public func holder(_ holder: ConnectionHolder) {
        self.holder = holder
    }

    @discardableResult
    public func asResponse(_ callback: @escaping (Response) -> Void) -> Connection<Response> {
        return start(parse: { $0 }, callback: callback)
    }

    @discardableResult
    public func asString(encoding: String.Encoding = .utf8, _ callback: @escaping (String) -> Void) -> Connection<String> {
        return start(parse: { String(bytes: $0.data, encoding: encoding) ?? "" }, callback: callback)
    }

    @discardableResult
    public func asData(_ callback: @escaping (Data) -> Void) -> Connection<Data> {
        return start(parse: { $0.data }, callback: callback)
    }

    @discardableResult
    public func asDecodable<T: Decodable>(type: T.Type, _ callback: @escaping (T) -> Void) -> Connection<T> {
        return start(parse: { response in
            return try JSONDecoder().decode(type, from: response.data)
        }, callback: callback)
    }

    @discardableResult
    public func asModel<T>(parse: @escaping (Response) throws -> T, _ callback: @escaping (T) -> Void) -> Connection<T> {
        return start(parse: parse, callback: callback)
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

    public func setupDefaultHTTPConnector(_ setup: @escaping (DefaultHTTPConnector) -> Void) -> HTTP {
        self.setupDefaultHTTPConnector = setup
        return self
    }

    private func start<T>(parse: @escaping (Response) throws -> T, callback: @escaping (T) -> Void) -> Connection<T> {
        let spec = CustomConnectionSpec(url: url,
                                        httpMethod: httpMethod,
                                        headers: headers,
                                        urlQuery: urlQuery,
                                        body: body,
                                        isValidResponse: isValidResponse,
                                        parse: parse)
        
        let connection = Connection(spec, onSuccess: callback)

        listeners.forEach { connection.addListener($0) }
        responseListeners.forEach { connection.addResponseListener($0) }
        errorListeners.forEach { connection.addErrorListener($0) }

        if let httpConnector = httpConnector {
            connection.httpConnector = httpConnector
        }
        if let urlEncoder = urlEncoder {
            connection.urlEncoder = urlEncoder
        }
        if let callbackInMainThread = callbackInMainThread {
            connection.callbackInMainThread = callbackInMainThread
        }
        if let isLogEnabled = isLogEnabled {
            connection.isLogEnabled = isLogEnabled
        }
        if let holder = holder {
            connection.holder = holder
        }

        if let setupDefaultHTTPConnector = setupDefaultHTTPConnector,
            let connector = connection.httpConnector as? DefaultHTTPConnector {
            setupDefaultHTTPConnector(connector)
        }

        connection.start()

        return connection
    }
}
