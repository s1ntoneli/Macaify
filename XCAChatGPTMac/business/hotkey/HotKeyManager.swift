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
    
    static let shared = HotKeyManager()
    
    static func initHotKeys() {
        KeyboardShortcuts.removeAllHandlers()
        KeyboardShortcuts.onKeyDown(for: .quickAsk) { [self] in
            NSLog("key pressed")
            let app = NSRunningApplication.runningApplications(withBundleIdentifier: "com.antiless.XCAChatGPTMac").first
            print("app is nil ? \(app)")
            PathManager.shared.toMain()
            app?.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])

            guard let window = NSApplication.shared.windows.first else {  return }
            window.deminiaturize(nil)
        }

        CommandStore.shared.commands.forEach { command in
            KeyboardShortcuts.onKeyDown(for: command.Name) { [self] in
                NSLog("key pressed")

                print("top is Main \(PathManager.shared.top == .main)")
                print("top is found \(NSApplication.shared.isActive)")
                let isActive = NSApplication.shared.isActive

                StartupPasteboardManager.shared.startup { text in
                    if (command.autoAddSelectedText) {
                        let text = isActive ? MainViewModel.shared.searchText : text
                        switch PathManager.shared.top {
                        case .chat(_, _):
                            print("tapped")
                            PathManager.shared.toChat(command, msg: text)
                            if let text = text, !text.isEmpty {
                                let vm = CommandStore.shared.commandViewModel(command)
                                vm.inputMessage = text
                                Task {
                                    await vm.sendTapped()
                                }
                            }
                        default:
                            PathManager.shared.toChat(command, msg: text)
                        }
                    } else {
                        PathManager.shared.toChat(command)
                    }
                    StartupPasteboardManager.shared.consumed()
                }

                let app = NSRunningApplication.runningApplications(withBundleIdentifier: "com.antiless.XCAChatGPTMac").first
                print("app is nil ? \(app)")
                app?.activate(options: [ .activateIgnoringOtherApps])

                guard let window = NSApplication.shared.windows.first else {  return }
                window.deminiaturize(nil)
            }
        }

        KeyboardShortcuts.onKeyDown(for: .menuBar) { [self] in
            NSLog("key pressed")
            let app = NSRunningApplication.runningApplications(withBundleIdentifier: "com.antiless.XCAChatGPTMac").first
            print("app is nil ? \(app)")
            NSApplication.shared.activate(ignoringOtherApps: true)
//            self.window.makeKeyAndOrderFront(nil)
            app?.activate(options: [.activateAllWindows])
        }
    }
}
