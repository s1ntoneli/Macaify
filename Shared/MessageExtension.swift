//
//  MessageExtension.swift
//  Found
//
//  Created by lixindong on 2023/4/20.
//

import Foundation
import GPTEncoder

private let gptEncoder = GPTEncoder()
extension Message {
    var token: Int {
        get {
            gptEncoder.encode(text: self.content).count
        }
    }
}

extension Array where Element == Message {
    
    var token: Int { reduce(0, { $0 + $1.token })}
}


