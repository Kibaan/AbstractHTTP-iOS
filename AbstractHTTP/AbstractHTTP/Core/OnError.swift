//
//  OnError.swift
//  AbstractHTTP
//
//  Created by Keita Yamamoto on 2020/01/16.
//  Copyright © 2020 altonotes Inc. All rights reserved.
//

import Foundation

/// Connection.addOnError により追加されるエラー処理
public class OnError<ResponseModel>: ConnectionErrorListener {

    let onError: (ConnectionError, Response?, ResponseModel?) -> Void

    public init(_ onError: @escaping (ConnectionError, Response?, ResponseModel?) -> Void) {
        self.onError = onError
    }

    public func onNetworkError(connection: ConnectionTask, error: Error?) -> EventChain {
        callError(type: .network, nativeError: error)
        return .proceed
    }

    public func onResponseError(connection: ConnectionTask, response: Response) -> EventChain {
        callError(type: .invalidResponse, response: response)
        return .proceed
    }

    public func onParseError(connection: ConnectionTask, response: Response, error: Error) -> EventChain {
        callError(type: .parse, nativeError: error, response: response)
        return .proceed
    }

    public func onValidationError(connection: ConnectionTask, response: Response, responseModel: Any) -> EventChain {
        callError(type: .validation, response: response, responseModel: responseModel)
        return .proceed
    }

    public func onCanceled(connection: ConnectionTask) {
        callError(type: .canceled)
    }

    public func afterError(connection: ConnectionTask, response: Response?, responseModel: Any?, error: ConnectionError) { }

    private func callError(type: ConnectionErrorType,
                           nativeError: Error? = nil,
                           response: Response? = nil,
                           responseModel: Any? = nil) {

        let error = ConnectionError(type: type, nativeError: nativeError)
        onError(error, response, responseModel as? ResponseModel)
    }
}
