//
//  ViewController.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2019/12/25.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import UIKit
import AbstractHTTP

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    let exampleList: [ExampleItem & UIViewController] = [
        SimplestViewController(),
        GetJSONViewController(),
        CommonRequestSpecViewController(),
        IndicatorViewController(),
        ListenerViewController(),
        RetryViewController(),
        MockViewController(),
        PollingViewController(),
        CancelViewController(),
        TokenRefreshViewController(),
        ConvenientViewController()
    ]

    var selectedRow: IndexPath?

    lazy var countIcon: UILabel = makeCountIcon()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "実装サンプル"

        ConnectionHolder.shared.addListener(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedRow = selectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
            self.selectedRow = nil
        }

        if countIcon.superview == nil,
            let window = UIApplication.shared.windows.first {

            window.addSubview(countIcon)
            countIcon.topAnchor.constraint(equalTo: window.topAnchor, constant: window.safeAreaInsets.top + 6).isActive = true
            countIcon.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -8).isActive = true
        }
    }

    func makeCountIcon() -> UILabel {
        let label = UILabel(frame: .zero)
        label.text = "0"
        label.backgroundColor = .orange
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 30).isActive = true
        label.heightAnchor.constraint(equalTo: label.widthAnchor).isActive = true
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exampleList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = exampleList[indexPath.row].displayTitle
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath

        let vc = exampleList[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: ConnectionHolderListener {
    func onAdded(connection: ConnectionTask, count: Int) {
        DispatchQueue.main.async {
            self.countIcon.text = String(count)
        }
    }

    func onRemoved(connection: ConnectionTask, count: Int) {
        DispatchQueue.main.async {
            self.countIcon.text = String(count)
        }
    }
}
