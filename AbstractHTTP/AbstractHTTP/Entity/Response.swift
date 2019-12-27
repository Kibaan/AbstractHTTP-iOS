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
public class Response {
    /// レスポンスデータ
    public let data: Data
    /// HTTPステータスコード
    public let statusCode: Int
    /// レスポンスヘッダー
    public let headers: [String: String]
    /// ネイティブSDKのレスポンスオブジェクト。
    /// HTTPConnectorで任意のレスポンスオブジェクトをセットすることが出来る
    /// 標準実装の場合、URLResponseが入る。
    public let nativeResponse: Any?
    
    public init(data: Data, statusCode: Int, headers: [String: String], nativeResponse: Any?) {
        self.data = data
        self.statusCode = statusCode
        self.headers = headers
        self.nativeResponse = nativeResponse
    }
}
