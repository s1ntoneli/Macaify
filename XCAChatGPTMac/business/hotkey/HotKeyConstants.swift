//
//  HotKeyConstants.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let quickAsk = Self("quickAsk", default: .init(.space, modifiers: .option))
    static let menuBar = Self("menuBar", default: .init(.m, modifiers: [.command, .option]))
    static let search = Self("search", default: .init(.k, modifiers: .command))
    static let quickTranslateCh = Self("quickTranslateCh", default: .init(.t, modifiers: [ .option ]))
    static let quickTranslateEng = Self("quickTranslateEng", default: .init(.e, modifiers: [ .option ]))
    static let debug = Self("debug", default: .init(.d, modifiers: [ .option ]))
}

extension GPTConversation {
    var Name: KeyboardShortcuts.Name {
        KeyboardShortcuts.Name(uuid.uuidString)
    }
    
    func NameWithDefault(shortcut: KeyboardShortcuts.Name.Shortcut) -> KeyboardShortcuts.Name {
        return KeyboardShortcuts.Name(uuid.uuidString, default: shortcut)
    }
}
