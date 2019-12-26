//
//  User.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2019/12/26.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import Foundation

struct User: Decodable {
    let id: Int
    let name: String?
    let username: String?
    let email: String?
    let phone: String?
    let website: String?
    let address: Address?
    let company: Company?

    var stringValue: String {
        return  """
            ID: \(id)
            Name: \(name ?? "")
            UserName: \(username ?? "")
            Email: \(email ?? "")
            Phone: \(phone ?? "")
        """
    }
}

struct Address: Decodable {
    let street: String?
    let suite: String?
    let city: String?
    let zipcode: String?
    let geo: Geo?
}

struct Geo: Decodable {
    let lat: String
    let lng: String
}

struct Company: Decodable {
    let name: String
    let catchPhrase: String?
    let bs: String?
}

