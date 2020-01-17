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

    lazy var badTokenRefresher = TokenRefresher(tokenContainer: tokenContainer, fail: true, print: pushLine)

    lazy var logger = ConnectionLogger(print: pushLine)

    @IBOutlet weak var textView: UITextView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clear()
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

    @IBAction func failRefreshAction(_ sender: Any) {
        clear()
        Connection(ExampleAPISpec(tokenContainer: tokenContainer))
            .addErrorListener(badTokenRefresher)
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
    // 無限ループ防止のためのカウンター
    var errorCount = 0

    let tokenContainer: TokenContainer
    let printFunc: (String) -> Void
    let fail: Bool

    init(tokenContainer: TokenContainer, fail: Bool = false, print: @escaping (String) -> Void) {
        self.tokenContainer = tokenContainer
        self.fail = fail
        self.printFunc = print
    }
    
    func onResponseError(connection: ConnectionTask, response: Response) {
        guard response.statusCode == 401, errorCount < 3 else {
            return
        }

        errorCount += 1

        printFunc("401エラー発生、トークン再取得。")
        
        connection.interrupt()

        Connection(GetTokenSpec(fail: fail)) { token in
            self.printFunc("トークン取得完了、再通信。")
            self.tokenContainer.token = token
            connection.restart(implicitly: true)
        }.addOnError {_, _, _ in
            self.printFunc("トークン取得失敗")
            connection.breakInterruption()
        }.start()
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
