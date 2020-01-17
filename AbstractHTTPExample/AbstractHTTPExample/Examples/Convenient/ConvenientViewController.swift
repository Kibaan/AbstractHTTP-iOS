//
//  ConvenientViewController.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2020/01/17.
//  Copyright © 2020 altonotes Inc. All rights reserved.
//

import UIKit
import AbstractHTTP

class ConvenientViewController: UIViewController, ExampleItem {

    var displayTitle: String { return "簡易インターフェース" }

    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var logTextView: UITextView!

    lazy var logger = ConnectionLogger(print: pushLine)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clear()
    }

    @IBAction func minimumGetAction(_ sender: Any) {
        clear()

        HTTP("https://reqres.in/api/users/2").asString {
            self.printResponse($0)
        }
    }

    @IBAction func listenerAction(_ sender: Any) {
        clear()

        HTTP("https://reqres.in/api/users/2")
            .addListener(logger)
            .addResponseListener(logger)
            .addErrorListener(logger)
            .asString {
                self.pushLine("(SUCCESS callback)")
                self.printResponse($0)
            }
    }

    @IBAction func jsonAction(_ sender: Any) {
        clear()

        HTTP("https://jsonplaceholder.typicode.com/users/1")
            .asDecodable(type: User.self) { user in
                self.printResponse(user.stringValue)
            }
    }

    @IBAction func postAction(_ sender: Any) {
        clear()

        let body = """
            {
                "name": "yamamoto",
                "job": "ceo"
            }
        """.data(using: .utf8)!

        HTTP("https://reqres.in/api/users")
            .httpMethod(.post)
            .headers(["Content-Type": "application/json"])
            .body(body)
            .asString {
                self.printResponse($0)
            }
    }

    @IBAction func timeoutAction(_ sender: Any) {
        clear()

        HTTP("https://apidemo.altonotes.co.jp/timeout-test")
            .urlQuery(["waitSeconds": "2"])
            .setupDefaultHTTPConnector {
                $0.timeoutInterval = 0.5
            }
            .addListener(logger)
            .addResponseListener(logger)
            .addOnError {_, _, _ in
                self.pushLine("OnError before error listener")
            }
            .addErrorListener(logger)
            .addOnError {_, _, _ in
                self.pushLine("OnError after error listener")
            }
            .asString {
                self.printResponse($0)
            }
    }

    private func clear() {
        responseTextView.text = nil
        logTextView.text = nil
    }

    private func printResponse(_ text: String) {
        responseTextView.text += text
    }

    private func pushLine(_ text: String) {
        DispatchQueue.main.async {
            self.logTextView.text += text + "\n"
        }
    }
}
