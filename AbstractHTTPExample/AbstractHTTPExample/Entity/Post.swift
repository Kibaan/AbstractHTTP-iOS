//
//  Post.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2019/12/26.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import Foundation

struct Post: Decodable {
    let userId: Int
    let id: Int
    let title: String?
    let body: String?

    var stringValue: String {
        return  """
            ID: \(id)
            UserID: \(userId)
            Title: \(title ?? "")
            Body: \(body ?? "")
        """
    }
}
