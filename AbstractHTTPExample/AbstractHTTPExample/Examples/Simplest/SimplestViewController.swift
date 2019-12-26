//
//  SimplestViewController.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2019/12/25.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import UIKit
import AbstractHTTP

class SimplestViewController: UIViewController, ExampleItem {
    var displayTitle: String { return "最小構成" }

    @IBOutlet weak var textView: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = nil
    }

    @IBAction func buttonAction(_ sender: Any) {
        Connection(SimplestSpec()) { response in
            self.textView.text = response
        }.start()
    }
}
