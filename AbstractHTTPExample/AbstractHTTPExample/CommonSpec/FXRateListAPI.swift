//
//  FXRateListAPI.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2020/01/14.
//  Copyright © 2020 altonotes Inc. All rights reserved.
//

import Foundation
import AbstractHTTP

class FXRateListAPI: ConnectionSpec {

    typealias ResponseModel = FXRateList

    var url: String { return "https://www.gaitameonline.com/rateaj/getrate" }

    var httpMethod: HTTPMethod { return .get }

    var headers: [String : String] { return [:] }

    var urlQuery: URLQuery? { return nil }

    func makeBody() -> Data? {
        return nil
    }

    func validate(response: Response) -> Bool {
        return response.statusCode == 200
    }

    func parseResponse(response: Response) throws -> FXRateList {
        return try JSONDecoder().decode(FXRateList.self, from: response.data)
    }
}

struct FXRateList: Decodable {
    let quotes: [FXRate]
}

struct FXRate: Decodable {
    let currencyPairCode: String
    
    let open: String?
    let high: String?
    let low: String?

    let bid: String?
    let ask: String?

    var stringValue: String {
        let bidText = bid ?? "--"
        let askText = ask ?? "--"
        return "[\(currencyPairCode)]  \(bidText) - \(askText)"
    }
}
