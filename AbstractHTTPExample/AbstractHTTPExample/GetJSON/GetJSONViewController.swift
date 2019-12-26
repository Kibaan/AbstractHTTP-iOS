//
//  GetJSONViewController.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2019/12/25.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import UIKit
import AbstractHTTP

class GetJSONViewController: UIViewController, ExampleItem, UITableViewDataSource, UITableViewDelegate {
    var displayTitle: String { return "JSON取得" }

    @IBOutlet weak var tableView: UITableView!

    var response: [User] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        response = []
    }

    @IBAction func buttonAction(_ sender: Any) {
        Connection(GetJSONSpec()) { response in
            self.response = response
        }.start()
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return response.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = response[indexPath.row]

        let cell = UITableViewCell()
        cell.textLabel?.text = "[\(user.id)] \(user.username ?? "")"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let user = response[indexPath.row]
        AlertUtils.show(title: user.name ?? "", message: """
            ID: \(user.id)
            Name: \(user.name ?? "")
            UserName: \(user.username ?? "")
            Email: \(user.email ?? "")
            Phone: \(user.phone ?? "")
""")
    }
}
