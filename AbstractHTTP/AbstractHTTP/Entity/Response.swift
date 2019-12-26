//
//  Response.swift
//  AbstractHTTP
//
//  Created by Yamamoto Keita on 2019/09/18.
//  Copyright © 2019 Yamamoto Keita. All rights reserved.
//

import Foundation

/// HTTPレスポンスの情報
/// レスポンスボディの他、ステータスコード、ヘッダーの情報を持つ
public struct Response {
    /// レスポンスデータ
    public let data: Data
    /// HTTPステータスコード
    public let statusCode: Int
    /// レスポンスヘッダー
    public let headers: [String: String]
    /// ネイティブSDKのレスポンスオブジェクト。
    /// iOSの場合、URLResponseが入る。
    public let nativeResponse: Any?
}
