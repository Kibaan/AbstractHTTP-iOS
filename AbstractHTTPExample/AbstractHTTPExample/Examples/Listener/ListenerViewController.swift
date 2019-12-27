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
        let listener = ExampleListener(print: pushLine)

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
        let listener = ExampleListener(print: pushLine)

        clear()
        let connection = Connection(WaitableAPISpec(waitSeconds: 3)) { response in
            self.pushLine("(SUCCESS callback)")
        }

        (connection.connector as? DefaultHTTPConnector)?.timeoutInterval = 1

        connection
            .addListener(listener)
            .addResponseListener(listener)
            .addErrorListener(listener)
            .start()
    }

    // 通信キャンセル
    @IBAction func cancelAction(_ sender: Any) {
        let listener = ExampleListener(print: pushLine)

        clear()
        let connection = Connection(WaitableAPISpec(waitSeconds: 3)) { response in
            self.pushLine("(SUCCESS callback)")
        }
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

class ExampleListener: ConnectionListener, ConnectionResponseListener, ConnectionErrorListener {

    let printFunc: (String) -> Void

    init(print: @escaping (String) -> Void) {
        self.printFunc = print
    }

    private func print(_ text: String) {
        DispatchQueue.main.async {
            self.printFunc(text)
        }
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

    func onNetworkError(connection: ConnectionTask, error: Error?) -> EventChain {
        print("onNetworkError")
        return .proceed
    }

    func onResponseError(connection: ConnectionTask, response: Response) -> EventChain {
        print("onResponseError")
        return .proceed
    }
    
    func onParseError(connection: ConnectionTask, response: Response, error: Error) -> EventChain {
        print("onParseError")
        return .proceed
    }

    func onValidationError(connection: ConnectionTask, response: Response, responseModel: Any) -> EventChain {
        print("onValidationError")
        return .proceed
    }

    func afterError(connection: ConnectionTask, response: Response?, responseModel: Any?, error: ConnectionError) {
        print("afterError")
    }

    func onCanceled(connection: ConnectionTask) {
        print("onCanceled")
    }
}
