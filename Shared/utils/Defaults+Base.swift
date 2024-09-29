//
//  Defaults+Base.swift
//  XCAChatGPT
//
//  Created by lixindong on 2024/9/28.
//
import Defaults

extension Defaults.Keys {
    static let selectedModelId = Key<String>("selectedModelId", default: "")
    static let maxToken = Key<Int>("maxToken", default: 4096)
    static let selectedProvider = Key<String>("selectedProvider", default: "")
    static let apiKey = Key<String>("apiKey", default: "")
    static let proxyAddress = Key<String>("proxyAddress", default: "")
}
