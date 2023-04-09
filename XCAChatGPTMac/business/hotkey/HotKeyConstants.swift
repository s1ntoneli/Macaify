//
//  HotKeyConstants.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let quickAsk = Self("quickAsk", default: .init(.k, modifiers: [.command, .option]))
}

extension Command {
    var Name: KeyboardShortcuts.Name {
        KeyboardShortcuts.Name(id.uuidString)
    }
}
