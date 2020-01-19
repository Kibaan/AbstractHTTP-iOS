//
//  Connection.swift
//  AbstractHTTP
//
//  Created by Yamamoto Keita on 2019/08/09.
//  Copyright © 2019 Yamamoto Keita. All rights reserved.
//

import Foundation

/// HTTP通信のライフサイクル
/// 通信に必要な各種モジュールを取りまとめ、通信処理の実行と各種コールバックやリスナーの呼び出しを行う
///
/// The lifecycle of a HTTP connection.
///
open class Connection<ResponseModel>: ConnectionTask {

    /// HTTPリクエストの仕様
    public let requestSpec: RequestSpec

    /// レスポンスデータの正当性を検証する
    public let validate: (Response) -> Bool

    /// 通信レスポンスをデータモデルに変換する
    public let parseResponse: (Response) throws -> ResponseModel

    /// 通信開始と終了のリスナー
    public var listeners: [ConnectionListener] = []

    /// 通信レスポンス処理のリスナー
    public var responseListeners: [ConnectionResponseListener] = []

    /// エラーのリスナー
    public var errorListeners: [ConnectionErrorListener] = []

    /// HTTP通信処理
    public var httpConnector: HTTPConnector = ConnectionConfig.shared.httpConnector()

    /// URLエンコード処理
    public var urlEncoder: URLEncoder = ConnectionConfig.shared.urlEncoder()

    /// ログ出力を有効にするか
    public var isLogEnabled = ConnectionConfig.shared.isLogEnabled

    /// コールバックをメインスレッドで呼び出すか
    public var callbackInMainThread = true

    /// 通信成功時のコールバック
    var onSuccess: ((ResponseModel) -> Void)?

    /// 直近のリクエスト
    public private(set) var latestRequest: Request?

    /// 実行中の通信オブジェクトを保持するコンテナ
    public weak var holder = ConnectionHolder.shared

    /// 実行ID
    public private(set) var executionId: ExecutionId?

    /// 中断中の実行ID
    public private(set) var interruptedId: ExecutionId?

    public init<T: ResponseSpec>(requestSpec: RequestSpec,
                                 responseSpec: T,
                                 onSuccess: ((ResponseModel) -> Void)? = nil) where T.ResponseModel == ResponseModel {
        self.requestSpec = requestSpec
        self.parseResponse = responseSpec.parseResponse
        self.validate = responseSpec.validate
        self.onSuccess = onSuccess
    }

    public init<T: ConnectionSpec>(_ connectionSpec: T,
                                   onSuccess: ((ResponseModel) -> Void)? = nil) where T.ResponseModel == ResponseModel {
        self.requestSpec = connectionSpec
        self.parseResponse = connectionSpec.parseResponse
        self.validate = connectionSpec.validate
        self.onSuccess = onSuccess
    }

    /// 通信を開始する
    public func start() {
        connect()
    }

    /// 通信を再実行する
    open func restart() {
        connect()
    }

    /// 直近のリクエストを再送信する
    open func repeatRequest() {
        connect(request: latestRequest)
    }

    /// 通信をキャンセルする
    open func cancel() {
        // 既に実行完了している場合何もしない
        guard let executionId = executionId else {
            return
        }

        onCancel(executionId: executionId)
        httpConnector.cancel()
    }

    /// コールバック処理の実行を中断する
    open func interrupt() {
        interruptedId = executionId
        executionId = nil
        holder?.remove(connection: self)
    }

    /// `interrupt()`による中断を終了する
    /// キャンセル扱いになり、キャンセル時と同じコールバックが呼ばれる
    open func breakInterruption() {
        guard executionId == nil, let interruptedId = interruptedId else {
            return
        }

        self.executionId = interruptedId
        self.interruptedId = nil
        onCancel(executionId: interruptedId)
    }

    /// 通信処理を開始する
    ///
    /// - Parameters:
    ///
    private func connect(request: Request? = nil) {
        let callOnStart = (self.executionId == nil && self.interruptedId == nil)
        
        let executionId = ExecutionId()
        self.executionId = executionId
        self.interruptedId = nil

        guard let url = makeURL(baseURL: requestSpec.url, query: requestSpec.urlQuery, encoder: urlEncoder) else {
            onInvalidURLError(executionId: executionId)
            return
        }

        // リクエスト作成
        let request = request ?? Request(url: url,
                                         method: requestSpec.httpMethod,
                                         body: requestSpec.makeBody(),
                                         headers: requestSpec.headers)

        if callOnStart {
            listeners.forEach {
                $0.onStart(connection: self, request: request)
            }
        }

        // このインスタンスが通信完了まで開放されないよう保持する必要がある
        holder?.add(connection: self)

        if isLogEnabled {
            print("[\(requestSpec.httpMethod.stringValue)] \(url)")
        }

        // 通信する
        httpConnector.execute(request: request, complete: { [weak self] (response, error) in
            self?.complete(response: response, error: error, executionId: executionId)
        })

        latestRequest = request
    }

    /// 通信完了時の処理
    private func complete(response: Response?, error: Error?, executionId: ExecutionId) {
        if executionId !== self.executionId { return }

        guard let response = response, error == nil else {
            onNetworkError(error: error, executionId: executionId)
            return
        }

        var listenerResult = true
        for i in responseListeners.indices {
            listenerResult = listenerResult && responseListeners[i].onReceived(connection: self, response: response)
            if executionId !== self.executionId { return }
        }

        guard listenerResult && validate(response) else {
            onResponseError(response: response, executionId: executionId)
            return
        }

        handleResponse(response: response, executionId: executionId)
    }

    open func handleResponse(response: Response, executionId: ExecutionId) {

        let responseModel: ResponseModel

        do {
            responseModel = try parseResponse(response)
        } catch {
            onParseError(response: response, error: error, executionId: executionId)
            return
        }

        var listenerResult = true
        for i in responseListeners.indices {
            listenerResult = listenerResult && responseListeners[i].onReceivedModel(connection: self, responseModel: responseModel)
            if executionId !== self.executionId { return }
        }

        if !listenerResult {
            onValidationError(response: response, responseModel: responseModel, executionId: executionId)
            return
        }

        callback {
            self.onSuccess?(responseModel)
            self.responseListeners.forEach {
                $0.afterSuccess(connection: self, responseModel: responseModel)
            }
            self.end(response: response, responseModel: responseModel, error: nil)
        }
    }

    func onInvalidURLError(executionId: ExecutionId) {
        handleError(.invalidURL, executionId: executionId) {
            return $0.onNetworkError(connection: self, error: nil)
        }
    }

    func onNetworkError(error: Error?, executionId: ExecutionId) {
        handleError(.network, error: error, executionId: executionId) {
            return $0.onNetworkError(connection: self, error: error)
        }
    }

    func onResponseError(response: Response, executionId: ExecutionId) {
        handleError(.invalidResponse, response: response, executionId: executionId) {
            return $0.onResponseError(connection: self, response: response)
        }
    }

    func onParseError(response: Response, error: Error, executionId: ExecutionId) {
        handleError(.parse, error: error, response: response, executionId: executionId) {
            return $0.onParseError(connection: self, response: response, error: error)
        }
    }

    func onValidationError(response: Response, responseModel: ResponseModel, executionId: ExecutionId) {
        handleError(.validation, response: response, responseModel: responseModel, executionId: executionId) {
            return $0.onValidationError(connection: self, response: response, responseModel: responseModel)
        }
    }

    func onCancel(executionId: ExecutionId) {
        handleError(.canceled, executionId: executionId) {
            return $0.onCanceled(connection: self)
        }
    }

    /// エラーを処理する
    private func handleError(_ type: ConnectionErrorType,
                             error: Error? = nil,
                             response: Response? = nil,
                             responseModel: ResponseModel? = nil,
                             executionId: ExecutionId,
                             callListener: @escaping (ConnectionErrorListener) -> Void) {
        // エラーログ出力
        if isLogEnabled {
            let message = error?.localizedDescription ?? ""
            print("[ConnectionError] Type= \(type.description), NativeMessage=\(message)")
        }

        callback {
            self.errorProcess(type, error, response, responseModel, executionId, callListener)
        }
    }

    /// エラー処理の実行
    private func errorProcess(_ type: ConnectionErrorType,
                              _ error: Error? = nil,
                              _ response: Response? = nil,
                              _ responseModel: ResponseModel? = nil,
                              _ executionId: ExecutionId,
                              _ callListener: (ConnectionErrorListener) -> Void) {

        for i in errorListeners.indices {
            callListener(errorListeners[i])
            if executionId !== self.executionId { return }
        }

        let connectionError = ConnectionError(type: type, nativeError: error)
        errorListeners.forEach {
            $0.afterError(connection: self,
                          response: response,
                          responseModel: responseModel,
                          error: connectionError)
        }

        end(response: response, responseModel: responseModel, error: connectionError)
    }

    private func end(response: Response?, responseModel: Any?, error: ConnectionError?) {
        holder?.remove(connection: self)
        executionId = nil
        interruptedId = nil
        listeners.forEach { $0.onEnd(connection: self, response: response, responseModel: responseModel, error: error) }
    }

    @discardableResult
    public func addListener(_ listener: ConnectionListener) -> Self {
        listeners.append(listener)
        return self
    }

    @discardableResult
    public func addResponseListener(_ listener: ConnectionResponseListener) -> Self {
        responseListeners.append(listener)
        return self
    }

    @discardableResult
    public func addErrorListener(_ listener: ConnectionErrorListener) -> Self {
        errorListeners.append(listener)
        return self
    }

    /// エラー処理を追加する。
    /// エラー処理は `ConnectionErrorListener` として登録され、このプロトコルを経由して引数の`onError`が実行される
    ///
    /// - Parameters:
    ///   - onError: エラー処理
    @discardableResult
    public func addOnError(onError: @escaping (ConnectionError, Response?, ResponseModel?) -> Void) -> Self {
        addErrorListener(OnError(onError))
        return self
    }

    /// 終了処理を追加する。
    /// 終了処理は `ConnectionListener` として登録され、このプロトコルを経由して引数の`onEnd`が実行される
    ///
    /// - Parameters:
    ///   - onEnd: 終了処理
    @discardableResult
    public func addOnEnd(onEnd: @escaping (Response?, Any?, ConnectionError?) -> Void) -> Self {
        addListener(OnEnd(onEnd))
        return self
    }

    public func removeListener(_ listener: ConnectionListener) { listeners.removeAll { $0 === listener } }
    public func removeResponseListener(_ listener: ConnectionResponseListener) { responseListeners.removeAll { $0 === listener } }
    public func removeErrorListener(_ listener: ConnectionErrorListener) { errorListeners.removeAll { $0 === listener } }

    open func callback(_ function: @escaping () -> Void) {
        if callbackInMainThread {
            DispatchQueue.main.async {
                function()
            }
        } else {
            function()
        }
    }

    open func makeURL(baseURL: String, query: URLQuery?, encoder: URLEncoder) -> URL? {
        var urlStr = baseURL

        if let query = query {
            let separator = urlStr.contains("?") ? "&" : "?"
            urlStr += separator + query.stringValue(encoder: urlEncoder)
        }

        return URL(string: urlStr)
    }
}

public class ExecutionId {}
