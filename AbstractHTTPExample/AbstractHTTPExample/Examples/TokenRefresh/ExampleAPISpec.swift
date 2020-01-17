//
//  ExampleAPISpec.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2020/01/15.
//  Copyright © 2020 altonotes Inc. All rights reserved.
//

import Foundation
import AbstractHTTP

class ExampleAPISpec: ConnectionSpec {
    typealias ResponseModel = String

    var url: String { return "https://apidemo.altonotes.co.jp/authexample" }

    var httpMethod: HTTPMethod { return .get }

    var headers: [String: String] {
        return ["Authorization": tokenContainer.token ?? ""]
    }

    var urlQuery: URLQuery? { return nil }

    let tokenContainer: TokenContainer

    func makeBody() -> Data? { return nil }

    init(tokenContainer: TokenContainer) {
        self.tokenContainer = tokenContainer
    }

    func isValidResponse(response: Response) -> Bool {
        // ステータスコード200系以外はエラーにする
        return 200 <= response.statusCode && response.statusCode < 300
    }

    func parseResponse(response: Response) throws -> ResponseModel {
        if let string = String(bytes: response.data, encoding: .utf8) {
            return string
        }
        throw NSError()
    }
}
