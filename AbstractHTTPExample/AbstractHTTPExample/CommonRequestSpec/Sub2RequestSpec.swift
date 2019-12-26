//
//  Sub2RequestSpec.swift
//  AbstractHTTPExample
//
//  Created by Keita Yamamoto on 2019/12/26.
//  Copyright © 2019 altonotes Inc. All rights reserved.
//

import Foundation
import AbstractHTTP

/// 個別のAPIで異なるプロパティのみ定義し、他のプロパティはCommonRequestSpecのものを使う
class Sub2RequestSpec: CommonRequestSpec<Post> {

    override var path: String { return "posts/\(postId)" }

    override var httpMethod: HTTPMethod { return .get }

    let postId: Int

    init(postId: Int) {
        self.postId = postId
    }
}
