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

        ConversationViewModel.shared.conversations.forEach { conversation in
            KeyboardShortcuts.onKeyDown(for: conversation.Name) { [self] in
                NSLog("key pressed \(conversation.autoAddSelectedText) conversation \(conversation.id) autoAdd \(conversation.autoAddSelectedText)")

                print("top is found \(NSApplication.shared.isActive)")
                print("top is Main \(PathManager.shared.top == .main)")

                let isActive = NSApplication.shared.isActive

                if isActive {
                    PathManager.shared.toChat(conversation, msg: MainViewModel.shared.searchText)
                } else if conversation.typingInPlace {
                    TypingInPlace.shared.typeInPlace(conv: conversation)
                } else if (conversation.autoAddSelectedText) {
                    StartupPasteboardManager.shared.startup { text in
                        switch PathManager.shared.top {
                        case .chat(let command, _,_):
                            print("tapped text \(text)")
                            PathManager.shared.toChat(conversation, msg: text)
                            if command.id == conversation.id {
                                if let text = text, !text.isEmpty {
                                    let vm = ConversationViewModel.shared.commandViewModel(conversation)
                                    print("copy text \(text) to viewmodel \(vm)")
                                    vm.inputMessage = text
                                    Task { @MainActor in
                                        if (!vm.isInteractingWithChatGPT && !vm.inputMessage.isEmpty) {
                                            await vm.sendTapped()
                                        }
                                    }
                                }
                            }
                        default:
                            PathManager.shared.toChat(conversation, msg: text)
                        }

                        resume()
                    }
                } else {
                    resume()
                    PathManager.shared.toChat(conversation)
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
    }
}

func resume(bundleId: String = "com.antiless.XCAChatGPTMac") {
    let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).first
    print("app is nil ? \(app)")
    app?.activate(options: [ .activateIgnoringOtherApps, .activateAllWindows])

    guard let window = NSApplication.shared.windows.first else {  return }
    window.deminiaturize(nil)
}
