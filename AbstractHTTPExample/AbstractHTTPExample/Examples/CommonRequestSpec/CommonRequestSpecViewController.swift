//
//  CommonRequestSpecViewController.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2019/12/25.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import UIKit
import AbstractHTTP

class CommonRequestSpecViewController: UIViewController, ExampleItem {

    var displayTitle: String { return "リクエスト仕様の共通化" }

    @IBOutlet weak var textView: UITextView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = nil
    }

    @IBAction func button1Action(_ sender: Any) {
        let spec = Sub1RequestSpec(userId: 1)
        Connection(spec) { response in
            self.textView.text = response.stringValue
        }.start()
    }

    @IBAction func button2Action(_ sender: Any) {
        let spec = Sub2RequestSpec(postId: 1)
        Connection(spec) { response in
            self.textView.text = response.stringValue
        }.start()
    }
}
