//
//  MockViewController.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2019/12/26.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import UIKit
import AbstractHTTP

class MockViewController: UIViewController, ExampleItem {

    var displayTitle: String { return "通信処理のカスタマイズ・モック化" }

    @IBOutlet weak var textView: UITextView!

    let mockHTTPConnector = MockHTTPConnector()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clear()
    }

    @IBAction func executeButtonAction(_ sender: Any) {
        clear()

        let spec = SimpleGetSpec(url: "https://www.google.com/")
        let connection = Connection(spec) { response in
            self.textView.text = response
        }
        connection.httpConnector = mockHTTPConnector
        connection.start()
    }

    private func clear() {
        textView.text = nil
    }

    private func pushLine(_ text: String) {
        textView.text += text + "\n"
    }
}
