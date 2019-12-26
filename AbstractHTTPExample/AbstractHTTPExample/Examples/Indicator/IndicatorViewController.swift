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

    @IBOutlet weak var indicatorBackgroundView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textView: UITextView!

    var indicator: ConnectionIndicator?

    override func viewDidLoad() {
        super.viewDidLoad()
        indicator = ConnectionIndicator(view: indicatorBackgroundView, activityIndicatorView: activityIndicator)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = nil
    }

    @IBAction func singleButtonAction(_ sender: Any) {
        guard let indicator = indicator else { return }

        let spec = SlowResponseSpec()
        clear()
        pushLine("[START] \(spec.url)")
        
        Connection(spec)
            .setOnEnd { response, model, error in
                self.pushLine("[END  ] \(spec.url)")
            }
            .addListener(indicator)
            .start()
    }

    @IBAction func errorButtonAction(_ sender: Any) {
        guard let indicator = indicator else { return }

        // APIで5秒待機するが1秒でタイムアウトさせる
        let spec = SlowResponseSpec(waitSeconds: 5)
        clear()
        pushLine("[START] \(spec.url)")

        let connection = Connection(spec)
        (connection.connector as? DefaultHTTPConnector)?.timeoutInterval = 1

        connection.setOnEnd { response, model, error in
            self.pushLine("[END  ] \(spec.url)")
        }
        .addListener(indicator)
        .start()
    }
    
    @IBAction func sequencialButtonAction(_ sender: Any) {

    }

    @IBAction func parallelButtonAction(_ sender: Any) {

    }

    // エラー

    private func clear() {
        textView.text = nil
    }

    private func pushLine(_ text: String) {
        textView.text += text + "\n"
    }
}