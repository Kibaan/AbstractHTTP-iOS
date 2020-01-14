//
//  ListenerViewController.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2019/12/27.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import UIKit
import AbstractHTTP

class ListenerViewController: UIViewController, ExampleItem {

    var displayTitle: String { return "各種リスナーのサンプル" }
    @IBOutlet weak var textView: UITextView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clear()
    }

    // 通信成功
    @IBAction func successAction(_ sender: Any) {
        let listener = ConnectionLogger(print: pushLine)

        clear()
        Connection(WaitableAPISpec()) { response in
            self.pushLine("(SUCCESS callback)")
        }
        .addListener(listener)
        .addResponseListener(listener)
        .addErrorListener(listener)
        .start()
    }

    // 通信タイムアウト
    @IBAction func timeoutAction(_ sender: Any) {

        clear()
        let connection = Connection(WaitableAPISpec(waitSeconds: 3)) { response in
            self.pushLine("(SUCCESS callback)")
        }

        (connection.connector as? DefaultHTTPConnector)?.timeoutInterval = 1

        let listener = ConnectionLogger(print: pushLine)
        connection
            .addListener(listener)
            .addResponseListener(listener)
            .addErrorListener(listener)
            .start()
    }

    // 通信キャンセル
    @IBAction func cancelAction(_ sender: Any) {

        clear()
        let connection = Connection(WaitableAPISpec(waitSeconds: 3)) { response in
            self.pushLine("(SUCCESS callback)")
        }
        
        let listener = ConnectionLogger(print: pushLine)
        connection
            .addListener(listener)
            .addResponseListener(listener)
            .addErrorListener(listener)
            .start()

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) {_ in
            connection.cancel()
        }
    }

    private func clear() {
        textView.text = nil
    }

    private func pushLine(_ text: String) {
        textView.text += text + "\n"
    }
}
