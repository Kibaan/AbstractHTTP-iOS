//
//  ConnectionConfig.swift
//  AbstractHTTP
//
//  Created by Keita Yamamoto on 2020/01/15.
//  Copyright © 2020 altonotes Inc. All rights reserved.
//

import Foundation

/// 通信のコンフィグ
/// `Connection` オブジェクトの各種初期値を決める
class ConnectionConfig {

    /// 共有オブジェクト
    public static var shared = ConnectionConfig()

    /// ログ出力を行うか
    public var isLogEnabled = true

    /// 標準のHTTPConnector
    public func httpConnector() -> HTTPConnector {
        return DefaultHTTPConnector()
    }

    /// 標準のURLEncoder
    public func urlEncoder() -> URLEncoder {
        return DefaultURLEncoder()
    }
}
