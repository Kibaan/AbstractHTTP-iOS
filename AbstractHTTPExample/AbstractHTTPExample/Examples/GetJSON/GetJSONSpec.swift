//
//  GetJSONSpec.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2019/12/26.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import Foundation
import AbstractHTTP

/// JSONを取得してモデルインスタンスにして返す実装
class GetJSONSpec: ConnectionSpec {
    typealias ResponseModel = [User]

    var url: String { return "https://jsonplaceholder.typicode.com/users" }
    var httpMethod: HTTPMethod { return .get }
    var headers: [String: String] { return [:] }
    var urlQuery: URLQuery? { return nil }

    func makeBody() -> Data? { return nil }
    func validate(response: Response) -> Bool { return true }

    // 通信レスポンスをデータモデルに変換する
    func parseResponse(response: Response) throws -> ResponseModel {
        return try JSONDecoder().decode([User].self, from: response.data)
    }
}
