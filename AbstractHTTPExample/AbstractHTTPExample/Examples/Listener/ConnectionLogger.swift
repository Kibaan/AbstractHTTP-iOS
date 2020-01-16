//
//  ConnectionLogger.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2020/01/14.
//  Copyright © 2020 altonotes Inc. All rights reserved.
//

import Foundation
import AbstractHTTP

/// 通信リスナーの各種イベントでログ出力する
class ConnectionLogger: ConnectionListener, ConnectionResponseListener, ConnectionErrorListener {

    let printFunc: (String) -> Void

    init(print: @escaping (String) -> Void) {
        self.printFunc = print
    }

    private func print(_ text: String) {
        self.printFunc(text)
    }

    func onStart(connection: ConnectionTask, request: Request) {
        print("onStart")
    }

    func onEnd(connection: ConnectionTask, response: Response?, responseModel: Any?, error: ConnectionError?) {
        print("onEnd")
    }

    func onReceived(connection: ConnectionTask, response: Response) -> Bool {
        print("onReceived")
        return true
    }

    func onReceivedModel(connection: ConnectionTask, responseModel: Any) -> Bool {
        print("onReceivedModel")
        return true
    }

    func afterSuccess(connection: ConnectionTask, responseModel: Any) {
        print("afterSuccess")
    }

    func onNetworkError(connection: ConnectionTask, error: Error?) {
        print("onNetworkError")
    }

    func onResponseError(connection: ConnectionTask, response: Response) {
        print("onResponseError \(response.statusCode)")
    }

    func onParseError(connection: ConnectionTask, response: Response, error: Error) {
        print("onParseError")
    }

    func onValidationError(connection: ConnectionTask, response: Response, responseModel: Any) {
        print("onValidationError")
    }

    func afterError(connection: ConnectionTask, response: Response?, responseModel: Any?, error: ConnectionError) {
        print("afterError")
    }

    func onCanceled(connection: ConnectionTask) {
        print("onCanceled")
    }
}
