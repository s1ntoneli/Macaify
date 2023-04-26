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

        ConversationViewModel.shared.conversations.forEach { command in
            KeyboardShortcuts.onKeyDown(for: command.Name) { [self] in
                NSLog("key pressed")

                print("top is Main \(PathManager.shared.top == .main)")
                print("top is found \(NSApplication.shared.isActive)")
                let isActive = NSApplication.shared.isActive

                if (command.autoAddSelectedText) {
                    StartupPasteboardManager.shared.startup { text in
                        let text = isActive ? MainViewModel.shared.searchText : text
                        switch PathManager.shared.top {
                        case .chat(_, _,_):
                            print("tapped")
                            PathManager.shared.toChat(command, msg: text)
                            if let text = text, !text.isEmpty {
                                let vm = ConversationViewModel.shared.commandViewModel(command)
                                vm.inputMessage = text
                                Task {
                                    if (!vm.isInteractingWithChatGPT) {
                                        await vm.sendTapped()
                                    }
                                }
                            }
                        default:
                            PathManager.shared.toChat(command, msg: text)
                        }

                        resume()
                    }
                }

                if !command.autoAddSelectedText {
                    resume()
                    PathManager.shared.toChat(command)
                }
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

        // MARK: - QuickOpen
        NSWorkspace.shared.runningApplications.forEach { app in
            if let id = app.bundleIdentifier, !id.isEmpty {
                print("register hotkey \(id)")
                KeyboardShortcuts.onKeyDown(for: .init(id)) {
                    print("onKeyDown \(id)")
                    let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: id)
                    if appURL != nil {
                        do {
                            try NSWorkspace.shared.launchApplication(at: appURL!, configuration: [:])
                        } catch {
                            print("")
                        }
                    }
                }
            }
        }
    }
}

private func resume(bundleId: String = "com.antiless.XCAChatGPTMac") {
    let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).first
    print("app is nil ? \(app)")
    app?.activate(options: [ .activateIgnoringOtherApps, .activateAllWindows])

    guard let window = NSApplication.shared.windows.first else {  return }
    window.deminiaturize(nil)
}
