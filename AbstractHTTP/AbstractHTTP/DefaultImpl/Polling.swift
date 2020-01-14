//
//  Polling.swift
//  AbstractHTTP
//
//  Created by Keita Yamamoto on 2019/10/30.
//  Copyright © 2019 山本敬太. All rights reserved.
//

import Foundation

public class Polling: ConnectionListener {

    let delaySeconds: Double
    let callback: () -> Void
    var timer: Timer?

    var connection: ConnectionTask?

    public init(delaySeconds: Double, callback: @escaping () -> Void) {
        self.delaySeconds = delaySeconds
        self.callback = callback
    }

    public func onStart(connection: ConnectionTask, request: Request) {
        self.connection?.cancel()
        self.connection = connection
    }

    public func onEnd(connection: ConnectionTask, response: Response?, responseModel: Any?, error: ConnectionError?) {
        if error == nil || error?.type == ConnectionErrorType.network {
            timer = Timer.scheduledTimer(withTimeInterval: delaySeconds, repeats: false) { timer in
                timer.invalidate()
                self.callback()
            }
        } else if error?.type == ConnectionErrorType.canceled {
            timer?.invalidate()
        }
        self.connection = nil
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
        connection?.cancel()
        connection = nil
    }
}
