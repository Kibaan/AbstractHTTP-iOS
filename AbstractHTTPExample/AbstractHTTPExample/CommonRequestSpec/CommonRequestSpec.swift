//
//  CommonRequestSpec.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2019/12/26.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import Foundation
import AbstractHTTP

/// 複数APIで共通のリクエスト・レスポンス仕様
/// 個別のAPI仕様はこのクラスを継承して作る
class CommonRequestSpec<T: Decodable>: ConnectionSpec {
    typealias ResponseModel = T

    var url: String {
        return "https://jsonplaceholder.typicode.com/\(path)"
    }

    var path: String {
        fatalError("Override by sub classes")
    }

    var httpMethod: HTTPMethod {
        fatalError("Override by sub classes")
    }

    var headers: [String: String] {
        return ["User-Agent": "AbstractHttpExample"]
    }

    var urlQuery: URLQuery? { return nil }

    func makePostData() -> Data? { return nil }

    func isValidResponse(response: Response) -> Bool {
        return true
    }

    func parseResponse(response: Response) throws -> ResponseModel {
        return try JSONDecoder().decode(ResponseModel.self, from: response.data)
    }
}

