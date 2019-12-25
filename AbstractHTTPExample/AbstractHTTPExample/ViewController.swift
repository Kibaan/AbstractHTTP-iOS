//
//  ViewController.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2019/12/25.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    let exampleList: [ExampleItem & UIViewController] = [
        SimplestViewController(),
        GetJSONViewController()
    ]

    var selectedRow: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "実装サンプル"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedRow = selectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
            self.selectedRow = nil
        }
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

        let vc = SimplestViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

