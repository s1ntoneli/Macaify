//
//  Globals.swift
//  Found
//
//  Created by lixindong on 2023/4/27.
//

import Foundation

@discardableResult
@inlinable
func with<V>(_ value: V, _ mutate: ((_ v: inout V) -> Void)) -> V {
    var mutableValue = value
    mutate(&mutableValue)
    return mutableValue
}
