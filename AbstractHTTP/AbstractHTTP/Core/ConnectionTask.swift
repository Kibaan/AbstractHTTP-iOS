//
//  ConnectionTask.swift
//  AbstractHTTP
//
//  Created by Keita Yamamoto on 2019/11/01.
//  Copyright © 2019 山本敬太. All rights reserved.
//

import Foundation

/// 一連の通信処理の制御
public protocol ConnectionTask: class {
    /// HTTPリクエストの仕様
    var requestSpec: RequestSpec { get }

    /// 通信開始、終了のリスナー
    var listeners: [ConnectionListener] { get set }
    /// 通信レスポンスのリスナー
    var responseListeners: [ConnectionResponseListener] { get set }
    /// 通信エラー、キャンセルのリスナー
    var errorListeners: [ConnectionErrorListener] { get set }

    /// HTTP通信の実行処理
    var httpConnector: HTTPConnector { get }

    /// クエリパラメーターのURLエンコード処理
    var urlEncoder: URLEncoder { get }

    /// 実行ID
    var executionId: ExecutionId? { get }

    /// コールバックをメインスレッドで呼び出すか
    var callbackInMainThread: Bool { get set }

    /// 直近のリクエスト内容
    var latestRequest: Request? { get }

    /// ログ出力が有効か
    var isLogEnabled: Bool { get set }

    /// 通信を開始する
    func start()

    /// 通信をキャンセルする
    func cancel()

    /// コールバックイベントを中断する
    func interrupt()

    /// `interrupt()`による中断を終了する。キャンセル扱いになる
    func breakInterruption()

    /// 直近のリクエストを再送信する。
    /// `restart` に近いふるまいになるが、リクエスト内容を再構築するか直近と全く同じリクエスト内容を使うかが異なる。
    /// 例えばリクエストパラメーターに現在時刻を動的に含める場合、`repeatRequest` では前回リクエストと同時刻になるが `restart` では新しい時刻が設定される。
    ///
    func repeatRequest()

}
