//
//  MockHTTPConnector.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2020/01/14.
//  Copyright © 2020 altonotes Inc. All rights reserved.
//

import Foundation
import AbstractHTTP

class MockHTTPConnector: HTTPConnector {

    var latestBody: Data?

    func execute(request: Request, complete: @escaping (Response?, Error?) -> Void) {
        guard let mockData = "Mock response".data(using: .utf8) else {
            assertionFailure("failed to get string data")
            return
        }

        latestBody = request.body

        let response = Response(data: mockData, statusCode: 200, headers: [:], nativeResponse: nil)
        complete(response, nil)
    }

    func cancel() {
    }
}
