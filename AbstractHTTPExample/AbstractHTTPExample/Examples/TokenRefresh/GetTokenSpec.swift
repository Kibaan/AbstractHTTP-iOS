//
//  GetTokenSpec.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2020/01/15.
//  Copyright © 2020 altonotes Inc. All rights reserved.
//

import Foundation
import AbstractHTTP

/// このAPIで取得したトークンは一回使うとサーバー側で無効化され、次回のアクセスでは401エラーが発生する
class GetTokenSpec: ConnectionSpec {
    typealias ResponseModel = String

    var url: String { return "https://apidemo.altonotes.co.jp/token" }

    var httpMethod: HTTPMethod { return .get }

    var headers: [String: String] { return [:] }

    var urlQuery: URLQuery? { return nil }

    func makePostData() -> Data? { return nil }

    func isValidResponse(response: Response) -> Bool { return true }

    func parseResponse(response: Response) throws -> ResponseModel {
        if let string = String(bytes: response.data, encoding: .utf8) {
            return string
        }
        throw NSError()
    }
}
