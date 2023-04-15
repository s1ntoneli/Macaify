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
    static let menuBar = Self("menuBar", default: .init(.m, modifiers: [.command, .option]))
}

extension Command {
    var Name: KeyboardShortcuts.Name {
        KeyboardShortcuts.Name(id.uuidString)
    }
    
    func NameWithDefault(shortcut: KeyboardShortcuts.Name.Shortcut) -> KeyboardShortcuts.Name {
        return KeyboardShortcuts.Name(id.uuidString, default: shortcut)
    }
}
