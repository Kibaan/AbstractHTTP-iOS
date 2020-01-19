//
//  SimplestSpec.swift
//  AbstractHTTP
//
//  Created by Yamamoto Keita on 2019/09/06.
//  Copyright © 2019 Yamamoto Keita. All rights reserved.
//

import Foundation
import AbstractHTTP

/// 最小構成のConnectionSpec実装
/// GET取得したデータを文字列として返す
class SimplestSpec: ConnectionSpec {
    // レスポンスの型を定義する。`func parseResponse` で生のレスポンスデータをこの型に変換する
    typealias ResponseModel = String

    // リクエスト先のURL
    var url: String { return "https://reqres.in/api/users/2" }

    // リクエストのHTTPメソッド
    var httpMethod: HTTPMethod { return .get }

    // 送信するリクエストヘッダー
    var headers: [String: String] { return [:] }

    // URLに付けるクエリパラメーター（URL末尾の`?`以降につけるパラメーター）。不要な場合はnil。
    var urlQuery: URLQuery? { return nil }

    // ポストするデータ（リクエストボディ）。不要な場合はnil。
    func makeBody() -> Data? { return nil }

    // ステータスコードの正常判定
    func validate(response: Response) -> Bool {
        return true
    }

    // 通信レスポンスをデータモデルに変換する
    func parseResponse(response: Response) throws -> ResponseModel {
        if let string = String(bytes: response.data, encoding: .utf8) {
            return string
        }
        throw NSError()
    }
}
