//
//  GetTokenSpec.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2020/01/15.
//  Copyright © 2020 altonotes Inc. All rights reserved.
//

import Foundation
import AbstractHTTP

/// このAPIで取得したトークンは有効期限が15秒で、期限が切れると401エラーが発生する
class GetTokenSpec: ConnectionSpec {
    typealias ResponseModel = String

    var url: String {
        if fail {
            // fail = trueの場合は存在しないURLにして通信失敗させる
            return "https://sonzaishinaidomain.com"
        }
        return "https://apidemo.altonotes.co.jp/token"
    }

    var httpMethod: HTTPMethod { return .get }

    var headers: [String: String] { return [:] }

    var urlQuery: URLQuery? { return nil }

    let fail: Bool

    init(fail: Bool = false) {
        self.fail = fail
    }

    func makeBody() -> Data? { return nil }

    func validate(response: Response) -> Bool { return true }

    func parseResponse(response: Response) throws -> ResponseModel {
        if let string = String(bytes: response.data, encoding: .utf8) {
            return string
        }
        throw NSError()
    }
}
