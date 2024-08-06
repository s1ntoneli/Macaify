//
//  SpotlightWindowController.swift
//  Macaify
//
//  Created by lixindong on 2023/7/30.
//

import Foundation
import AppKit

class SpotlightishWindowController: NSWindowController, NSWindowDelegate {
    convenience init() {
        self.init(windowNibName: "")
        shouldCascadeWindows = true
    }
    override func windowDidLoad() {
        window?.delegate = self
    }
    
    // Hide window when resign key.
    func windowDidResignKey(_ notification: Notification) {
        close()
    }
    
    override func loadWindow() {
        // Create a boderless, non-activating panel that float above other windows.
        window = KeyablePanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: true)
        window?.level = .floating
        window?.center()
    }
}
