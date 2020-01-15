//
//  ConnectionHolder.swift
//  AbstractHTTP
//
//  Created by Yamamoto Keita on 2019/09/11.
//  Copyright © 2019 Yamamoto Keita. All rights reserved.
//

import Foundation

/// 実行中の通信オブジェクトを保持するためのコンテナ
/// 通信の一括キャンセルや通信オブジェクトが通信中に解放されないよう保持する役割を持つ
public class ConnectionHolder {
    public static var shared = ConnectionHolder()

    public var connections: [ConnectionTask] = []

    private var listeners: [ConnectionHolderListener] = []

    /// 保持する通信オブジェクトの数
    public var count: Int {
        return connections.count
    }

    /// 通信オブジェクトを追加する。
    /// 既に同じものが保持されている場合は何もしない
    ///
    /// - Parameters:
    ///   - connection: 追加する通信オブジェクト
    public func add(connection: ConnectionTask) {
        if !contains(connection: connection) {
            connections.append(connection)
            listeners.forEach {
                $0.onAdded(connection: connection, count: connections.count)
            }
        }
    }

    /// 通信オブジェクトを削除する。
    ///
    /// - Parameters:
    ///   - connection: 削除する通信オブジェクト
    public func remove(connection: ConnectionTask) {
        connections.removeAll { $0 === connection }
        listeners.forEach {
            $0.onRemoved(connection: connection, count: connections.count)
        }
    }

    /// 指定した通信オブジェクトを保持しているか判定する
    ///
    /// - Parameters:
    ///   - connection: 判定する通信オブジェクト
    /// - Returns: 引数に指定した通信オブエジェクトを保持している場合 `true`
    public func contains(connection: ConnectionTask?) -> Bool {
        return connections.contains { $0 === connection }
    }

    /// 保持する全ての通信をキャンセルする
    public func cancelAll() {
        connections.forEach {
            $0.cancel()
        }
    }

    /// リスナーを追加する
    public func addListener(listener: ConnectionHolderListener) {
        if !listeners.contains(where: { $0 === listener }) {
            listeners.append(listener)
        }
    }

    /// リスナーを削除する
    public func removeListener(listener: ConnectionHolderListener) {
        listeners.removeAll { $0 === listener }
    }
}

public protocol ConnectionHolderListener: class {
    func onAdded(connection: ConnectionTask, count: Int)
    func onRemoved(connection: ConnectionTask, count: Int)
}
