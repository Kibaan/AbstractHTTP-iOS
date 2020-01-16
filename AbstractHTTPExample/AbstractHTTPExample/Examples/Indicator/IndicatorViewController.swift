//
//  IndicatorViewController.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2019/12/25.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import UIKit
import AbstractHTTP

class IndicatorViewController: UIViewController, ExampleItem {

    var displayTitle: String { return "通信インジケーターの表示" }

    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var textView: UITextView!

    var indicator: ConnectionIndicator!

    override func viewDidLoad() {
        super.viewDidLoad()
        indicator = ConnectionIndicator(view: indicatorView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = nil
    }

    @IBAction func singleButtonAction(_ sender: Any) {
        let spec = WaitableAPISpec()
        clear()
        pushLine("[START] \(spec.url)")
        
        Connection(spec)
            .addOnEnd { response, model, error in
                self.pushLine("[END  ] \(spec.url)")
            }
            .addListener(indicator)
            .start()
    }

    @IBAction func errorButtonAction(_ sender: Any) {
        // APIで5秒待機するが1秒でタイムアウトさせる
        let spec = WaitableAPISpec(waitSeconds: 5)
        clear()
        pushLine("[START] \(spec.url)")

        let connection = Connection(spec)
        (connection.httpConnector as? DefaultHTTPConnector)?.timeoutInterval = 1

        connection.addOnEnd { response, model, error in
            self.pushLine("[END  ] \(spec.url)")
        }
        .addListener(indicator)
        .start()
    }
    
    @IBAction func sequencialButtonAction(_ sender: Any) {
        // 直列で複数の通信を実行。全ての通信が完了したらインジケーターが消える
        clear()
        sequencialRequest(max: 3)
    }

    private func sequencialRequest(max: Int, count: Int = 1) {
        pushLine("[START] Request \(count)")
        Connection(WaitableAPISpec(waitSeconds: 1))
            .addOnEnd { response, model, error in
                self.pushLine("[END  ] Request \(count)")
                if count < max {
                    self.sequencialRequest(max: max, count: count + 1)
                }
            }
            .addListener(indicator)
            .start()
    }


    @IBAction func parallelButtonAction(_ sender: Any) {
        // 並列で複数の通信を実行。全ての通信が完了したらインジケーターが消える
        clear()

        pushLine("[START] Request 1")
        Connection(WaitableAPISpec(waitSeconds: 1))
            .addOnEnd { response, model, error in
                self.pushLine("[END  ] Request 1")
            }
            .addListener(indicator)
            .start()

        pushLine("[START] Request 2")
        Connection(WaitableAPISpec(waitSeconds: 2))
            .addOnEnd { response, model, error in
                self.pushLine("[END  ] Request 2")
            }
            .addListener(indicator)
            .start()

        pushLine("[START] Request 3")
        Connection(WaitableAPISpec(waitSeconds: 3))
            .addOnEnd { response, model, error in
                self.pushLine("[END  ] Request 3")
            }
            .addListener(indicator)
            .start()
    }

    private func clear() {
        textView.text = nil
    }

    private func pushLine(_ text: String) {
        textView.text += text + "\n"
    }
}
