//
//  MainWindowController.swift
//  Macaify
//
//  Created by lixindong on 2024/10/2.
//

import Foundation
import AppKit
import SwiftUI

class MainWindowController: NSWindowController, NSWindowDelegate {
    static let shared = MainWindowController()
    
    var contentView: ContentViewWrapper!
    var isVisible: Bool {
        window?.isVisible ?? false
    }
    
    // MARK: events
    
    var commandLocalMonitor = KeyMonitor(.command)
    var pathManager = PathManager.shared
    let globalConfig = GlobalConfig()
    
    convenience init() {
        self.init(windowNibName: "MainWindow")
        contentView = ContentViewWrapper()
    }
    
    override func loadWindow() {
        window = MainWindow(contentRect: .init(x: 0, y: 0, width: 720, height: 500), styleMask: [.fullSizeContentView, .resizable, .closable, .miniaturizable], backing: .buffered, defer: true)
        window?.level = .normal
        window?.contentView = NSHostingView(rootView: contentView
            .environmentObject(globalConfig))
        window?.center()
        window?.delegate = self
        window?.backgroundColor = .clear
        window?.titlebarAppearsTransparent = true
        window?.isMovableByWindowBackground = true
    }
    
    func showWindow() {
        NSApp.activate(ignoringOtherApps: true)
        guard let window = window else { return }
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        showWindow(nil)
    }
    
    func closeWindow() {
        close()
        window?.close()
    }
    
    func toggle() {
        if isVisible {
            closeWindow()
        } else {
            showWindow()
        }
    }
    
    func windowDidResignKey(_ notification: Notification) {
        unobserveEvents()
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        observeEvents()
    }
    
    func observeEvents() {
        commandLocalMonitor.handler = {
            print("Command key was held down for 1 second")
            withAnimation {
                self.globalConfig.showShortcutHelp = true
            }
        }
        commandLocalMonitor.onKeyUp = {
            withAnimation {
                self.globalConfig.showShortcutHelp = false
            }
        }
        commandLocalMonitor.start()
    }
    
    func unobserveEvents() {
        commandLocalMonitor.stop()
    }
}

class MainWindow: NSWindow {
    override var canBecomeKey: Bool { true }
}

struct ContentViewWrapper: View {
    @Environment(\.scenePhase) private var scenePhase

    @StateObject var vm = ConversationViewModel.shared
    @StateObject private var emojiViewModel = EmojiPickerViewModel()
    @AppStorage("selectedLanguage") var userDefaultsSelectedLanguage: String?
    
    var body: some View {
        MacContentView()
            .environmentObject(vm)
            .environmentObject(emojiViewModel)
            .environment(\.locale, .init(identifier: userDefaultsSelectedLanguage ?? "en"))
            .cornerRadius(16)
            .background {
                Button {
                    MainWindowController.shared.closeWindow()
                } label: {
                    Image(systemName: "xmark")
                }.keyboardShortcut("w", modifiers: .command)
                    .keyboardShortcut(.escape, modifiers: [])
                    .hidden()
            }
    }
}
