//
//  RetryRunner.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2020/01/14.
//  Copyright © 2020 altonotes Inc. All rights reserved.
//

import Foundation
import AbstractHTTP

class RetryRunner: ConnectionErrorListener {

    func onNetworkError(connection: ConnectionTask, error: Error?) -> EventChain {
        DispatchQueue.main.async {
            AlertUtils.show(title: "通信エラー",
                            message: "通信に失敗しました。リトライしますか？",
                            okLabel: "リトライ",
                            handler: { self.retry(connection) },
                            cancelLabel: "キャンセル",
                            cancelHandler: nil)
        }
        return .proceed
    }

    func retry(_ connection: ConnectionTask) {
        connection.restart(implicitly: false)
    }

    func onResponseError(connection: ConnectionTask, response: Response) -> EventChain {
        return .proceed
    }

    func onParseError(connection: ConnectionTask, response: Response, error: Error) -> EventChain {
        return .proceed
    }

    func onValidationError(connection: ConnectionTask, response: Response, responseModel: Any) -> EventChain {
        return .proceed
    }

    func afterError(connection: ConnectionTask, response: Response?, responseModel: Any?, error: ConnectionError) {
    }

    func onCanceled(connection: ConnectionTask) {
    }
}
