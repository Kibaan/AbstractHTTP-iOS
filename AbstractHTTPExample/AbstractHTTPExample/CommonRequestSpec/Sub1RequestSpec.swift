//
//  Sub1RequestSpec.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2019/12/26.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import Foundation
import AbstractHTTP

/// 個別のAPIで異なるプロパティのみ定義し、他のプロパティはCommonRequestSpecのものを使う
class Sub1RequestSpec: CommonRequestSpec<User> {
    
    override var path: String { return "users/\(userId)" }

    override var httpMethod: HTTPMethod { return .get }

    let userId: Int

    init(userId: Int) {
        self.userId = userId
    }
}
