//
//  SimpleGetSpec.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2019/12/27.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import Foundation
import AbstractHTTP

/// シンプルなGETの実装。GET取得したデータを文字列として返す
class SimpleGetSpec: ConnectionSpec {
    typealias ResponseModel = String

    var url: String
    var httpMethod: HTTPMethod { return .get }
    var headers: [String: String] { return [:] }
    var urlQuery: URLQuery? { return nil }

    init(url: String) {
        self.url = url
    }

    func makePostData() -> Data? { return nil }

    func isValidResponse(response: Response) -> Bool {
        return true
    }

    func parseResponse(response: Response) throws -> ResponseModel {
        if let string = String(bytes: response.data, encoding: .utf8) {
            return string
        }
        throw ConnectionErrorType.parse
    }
}
