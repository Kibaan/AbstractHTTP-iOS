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

    @IBAction func startConnection(_ sender: Any) {
        let connection = Connection(WaitableAPISpec(waitSeconds: 3))
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
}
