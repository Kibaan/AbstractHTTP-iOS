//
//  OnEnd.swift
//  AbstractHTTP
//
//  Created by Keita Yamamoto on 2020/01/16.
//  Copyright © 2020 altonotes Inc. All rights reserved.
//

import Foundation

/// Connection.addOnEnd により追加される終了処理
public class OnEnd: ConnectionListener {

    let onEndFunc: (Response?, Any?, ConnectionError?) -> Void

    public init(_ onEnd: @escaping (Response?, Any?, ConnectionError?) -> Void) {
        self.onEndFunc = onEnd
    }

    public func onStart(connection: ConnectionTask, request: Request) {}

    public func onEnd(connection: ConnectionTask, response: Response?, responseModel: Any?, error: ConnectionError?) {
        onEndFunc(response, responseModel, error)
    }
}
