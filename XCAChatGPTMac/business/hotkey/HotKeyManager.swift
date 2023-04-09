//
//  HotkeyHandler.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import Foundation
import KeyboardShortcuts
import AppKit

class HotKeyManager {
    
    static func initHotKeys() {
        KeyboardShortcuts.onKeyUp(for: .quickAsk) { [self] in
            NSLog("key pressed")
            let app = NSRunningApplication.runningApplications(withBundleIdentifier: "com.antiless.XCAChatGPTMac").first
            print("app is nil ? \(app)")
            PathManager.shared.toMain()
            app?.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
        }
        
        CommandStore.shared.commands.forEach { command in
            KeyboardShortcuts.onKeyUp(for: command.Name) { [self] in
                NSLog("key pressed")
                let app = NSRunningApplication.runningApplications(withBundleIdentifier: "com.antiless.XCAChatGPTMac").first
                print("app is nil ? \(app)")
                PathManager.shared.toChat(command)
                app?.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
            }
        }
    }
}
