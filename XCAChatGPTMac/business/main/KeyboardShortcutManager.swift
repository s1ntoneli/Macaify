//
//  KeyboardShortcutManager.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import Foundation
import Cocoa

class KeyboardShortcutManager {
    static let shared = KeyboardShortcutManager()

    private let shortcutKey = "shortcut"

    private init() {}

    func getShortcut() -> (key: String, modifiers: NSEvent.ModifierFlags)? {
        if let data = UserDefaults.standard.data(forKey: shortcutKey),
           let shortcut = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? (String, NSEvent.ModifierFlags) {
            return shortcut
        }
        return nil
    }

    func setShortcut(_ shortcut: (key: String, modifiers: NSEvent.ModifierFlags)) {
        let data = try? NSKeyedArchiver.archivedData(withRootObject: shortcut, requiringSecureCoding: false)
        UserDefaults.standard.set(data, forKey: shortcutKey)
    }
}
