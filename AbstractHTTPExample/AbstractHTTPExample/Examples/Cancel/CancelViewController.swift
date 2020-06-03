//
//  CancelViewController.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2020/01/15.
//  Copyright © 2020 altonotes Inc. All rights reserved.
//

import UIKit
import AbstractHTTP

class CancelViewController: UIViewController, ExampleItem {

    var displayTitle: String { return "通信キャンセル" }
    var latestConnection: ConnectionTask?
    
    @IBOutlet weak var textView: UITextView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = nil
    }
    
    @IBAction func startConnection(_ sender: Any) {
        let connection = Connection(WaitableAPISpec(waitSeconds: 3))
        connection.addListener(self)
        connection.addResponseListener(self)
        connection.addErrorListener(self)
        connection.start()

        latestConnection = connection
    }

    @IBAction func allCancel(_ sender: Any) {
        // すべての通信をキャンセル
        ConnectionHolder.shared.cancelAll()
    }
    
    @IBAction func singleCancel(_ sender: Any) {
        // 直近の通信をキャンセル
        latestConnection?.cancel()
    }

    @IBAction func clearAction(_ sender: Any) {
        clear()
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

extension CancelViewController: ConnectionErrorListener {
    func onNetworkError(connection: ConnectionTask, error: Error?) {
        pushLine("onNetworkError")
    }

    func onResponseError(connection: ConnectionTask, response: Response) {
        pushLine("onResponseError")
    }

    func onParseError(connection: ConnectionTask, response: Response, error: Error) {
        pushLine("onParseError")
    }

    func onValidationError(connection: ConnectionTask, response: Response, responseModel: Any) {
        pushLine("onValidationError")
    }

    func afterError(connection: ConnectionTask, response: Response?, responseModel: Any?, error: ConnectionError) {
        pushLine("afterError")
    }

    func onCanceled(connection: ConnectionTask) {
        pushLine("onCanceled")
    }
}

extension CancelViewController: ConnectionListener {
    func onStart(connection: ConnectionTask, request: Request) {
        pushLine("onStart")
    }

    func onEnd(connection: ConnectionTask, response: Response?, responseModel: Any?, error: ConnectionError?) {
        pushLine("onEnd")
    }
}

extension CancelViewController: ConnectionResponseListener {
    func onReceived(connection: ConnectionTask, response: Response) -> Bool {
        pushLine("onReceived")
        return true
    }

    func onReceivedModel(connection: ConnectionTask, responseModel: Any) -> Bool {
        pushLine("onReceivedModel")
        return true
    }

    func afterSuccess(connection: ConnectionTask, responseModel: Any) {
        pushLine("afterSuccess")
    }
}
