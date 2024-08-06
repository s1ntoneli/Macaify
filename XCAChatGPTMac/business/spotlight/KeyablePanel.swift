//
//  KeyablePanel.swift
//  Macaify
//
//  Created by lixindong on 2023/7/30.
//

import Foundation
import AppKit

class KeyablePanel: NSPanel {
    // Allow panel to become key, that is, accepts keyboard event.
    override var canBecomeKey: Bool { true }
}
