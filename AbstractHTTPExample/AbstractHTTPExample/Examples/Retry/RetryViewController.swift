//
//  RetryViewController.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2019/12/26.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import UIKit
import AbstractHTTP

class RetryViewController: UIViewController, ExampleItem {

    var displayTitle: String { return "通信のリトライ" }
    @IBOutlet weak var textView: UITextView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clear()
    }
    
    @IBAction func executeButtonAction(_ sender: Any) {
        clear()

        // タイムアウトさせる
        let spec = WaitableAPISpec(waitSeconds: 3)
        let connection = Connection(spec)
        (connection.httpConnector as? DefaultHTTPConnector)?.timeoutInterval = 1

        let listener = ConnectionLogger(print: pushLine)
        connection
            .addListener(listener)
            .addResponseListener(listener)
            .addErrorListener(listener)
            .addErrorListener(RetryRunner())
            .start()
    }

    private func clear() {
        textView.text = nil
    }

    private func pushLine(_ text: String) {
        textView.text += text + "\n"
    }
}
