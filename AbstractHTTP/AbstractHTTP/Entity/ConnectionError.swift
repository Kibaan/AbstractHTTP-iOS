//
//  ErrorResponse.swift
//  AbstractHTTP
//
//  Created by Yamamoto Keita on 2019/09/18.
//  Copyright © 2019 Yamamoto Keita. All rights reserved.
//

import Foundation

/// 通信エラーの情報
public struct ConnectionError {
    public let type: ConnectionErrorType
    public let nativeError: Error?
}
