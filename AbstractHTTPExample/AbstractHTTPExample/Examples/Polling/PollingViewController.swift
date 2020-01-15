//
//  PollingViewController.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2019/12/26.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import UIKit
import AbstractHTTP

class PollingViewController: UIViewController, ExampleItem, UITableViewDataSource {

    var displayTitle: String { return "ポーリング（自動更新）" }

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var rateList: FXRateList?

    lazy var polling = Polling(delaySeconds: 1.0, callback: request)

    override func viewDidLoad() {
        super.viewDidLoad()
        timeLabel.text = nil
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 変化が目視しやすいようviewDidAppearで処理を開始する
        request()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        polling.stop()
    }

    func request() {
        Connection(FXRateListAPI()) { response in
                self.update(rateList: response)
            }
            .addListener(polling)
            .start()
    }

    func update(rateList: FXRateList) {
        self.rateList = rateList
        tableView.reloadData()

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "US")
        dateFormatter.dateFormat = "HH:mm:ss"
        timeLabel.text = dateFormatter.string(from: Date())
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rateList?.quotes.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20)

        let quote = rateList?.quotes[indexPath.row]
        cell.textLabel?.text = quote?.stringValue
        return cell
    }
}
