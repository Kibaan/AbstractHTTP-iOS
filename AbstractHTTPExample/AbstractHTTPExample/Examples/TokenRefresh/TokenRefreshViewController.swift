//
//  TokenRefreshViewController.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2020/01/15.
//  Copyright © 2020 altonotes Inc. All rights reserved.
//

import UIKit
import AbstractHTTP

class TokenRefreshViewController: UIViewController, ExampleItem {

    var displayTitle: String { return "トークンリフレッシュ" }

    var tokenContainer = TokenContainer()

    lazy var tokenRefresher = TokenRefresher(tokenContainer: tokenContainer, print: pushLine)

    lazy var logger = ConnectionLogger(print: pushLine)

    @IBOutlet weak var textView: UITextView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clear()

        ConnectionConfig.shared.httpConnector = {
            let connector = DefaultHTTPConnector()
            connector.timeoutInterval = 60
            return connector
        }
    }

    @IBAction func getTokenAction(_ sender: Any) {
        Connection(GetTokenSpec()) { token in
            self.tokenContainer.token = token
        }.start()
    }

    @IBAction func callAPIAction(_ sender: Any) {
        clear()
        Connection(ExampleAPISpec(tokenContainer: tokenContainer))
            .addErrorListener(tokenRefresher)
            .addListener(logger)
            .addResponseListener(logger)
            .addErrorListener(logger)
            .start()
    }

    private func clear() {
        textView.text = nil
    }

    private func pushLine(_ text: String) {
        DispatchQueue.main.async {
            self.textView.text += text + "\n"
        }
    }
}

/// 401エラーが発生したらトークンを取得して自動リトライする
class TokenRefresher: ConnectionErrorListener {

    let tokenContainer: TokenContainer
    let printFunc: (String) -> Void

    init(tokenContainer: TokenContainer, print: @escaping (String) -> Void) {
        self.tokenContainer = tokenContainer
        self.printFunc = print
    }
    
    func onResponseError(connection: ConnectionTask, response: Response) {
        guard response.statusCode == 401 else {
            return
        }

        printFunc("401エラー発生。トークン再取得。")

        Connection(GetTokenSpec()) { token in
            self.printFunc("トークン取得完了。再通信。")
            self.tokenContainer.token = token
            connection.restart(implicitly: true)
        }.start()

        connection.interrupt()
    }

    func onNetworkError(connection: ConnectionTask, error: Error?) {}

    func onParseError(connection: ConnectionTask, response: Response, error: Error) {}

    func onValidationError(connection: ConnectionTask, response: Response, responseModel: Any) {}

    func afterError(connection: ConnectionTask, response: Response?, responseModel: Any?, error: ConnectionError) {}

    func onCanceled(connection: ConnectionTask) {}
}

class TokenContainer {
    var token: String?
}
