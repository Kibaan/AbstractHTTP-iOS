//
//  SlowResponseSpec.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2019/12/26.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import Foundation
import AbstractHTTP

/// サーバー側で指定した秒数待機するAPI
class WaitableAPISpec: ConnectionSpec {
    typealias ResponseModel = String

    var url: String { return "https://apidemo.altonotes.co.jp/timeout-test" }

    var httpMethod: HTTPMethod { return .get }

    var headers: [String: String] { return [:] }

    var urlQuery: URLQuery? {
        return ["waitSeconds": "\(waitSeconds)"]
    }

    let waitSeconds: Int

    init(waitSeconds: Int = 1) {
        self.waitSeconds = waitSeconds
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
