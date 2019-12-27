//
//  ConnectionIndicator.swift
//  AbstractHTTP
//
//  Created by 山本敬太 on 2019/10/22.
//  Copyright © 2019 山本敬太. All rights reserved.
//

import UIKit

/// 通信インジケーター。
/// インジケーターは複数の通信で使われることを想定して、
/// 単純な表示/非表示の切り替えではなく、参照カウントを増減してカウントが0になったら非表示にする方式にする。
public class ConnectionIndicator: ConnectionListener {

    public private(set) var referenceCount = 0

    public let view: UIView
    public private(set) lazy var activityIndicatorView: UIActivityIndicatorView? = findActivityIndicatorView(view: view)

    public init(view: UIView) {
        self.view = view
    }

    /// 引数のviewおよびそのsubviewから再帰的にUIActivityIndicatorViewを探す
    private func findActivityIndicatorView(view: UIView) -> UIActivityIndicatorView? {
        if let activityIndicatorView = view as? UIActivityIndicatorView {
            return activityIndicatorView
        }

        for i in view.subviews.indices {
            if let activityIndicatorView = findActivityIndicatorView(view: view.subviews[i]) {
                return activityIndicatorView
            }
        }

        return nil
    }

    public func onStart(connection: ConnectionTask, request: Request) {
        referenceCount += 1
        updateViewInMainThread()
    }

    public func onEnd(connection: ConnectionTask, response: Response?, responseModel: Any?, error: ConnectionError?) {
        referenceCount -= 1
        updateViewInMainThread()
    }

    func updateViewInMainThread() {
        DispatchQueue.main.async {
            self.updateView()
        }
    }

    func updateView() {
        view.isHidden = (referenceCount <= 0)
        if view.isHidden {
            activityIndicatorView?.stopAnimating()
        } else if activityIndicatorView?.isAnimating == false {
            activityIndicatorView?.startAnimating()
        }
    }
}
