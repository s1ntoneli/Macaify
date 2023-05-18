//
//  AppShortcutManager.swift
//  Found
//
//  Created by lixindong on 2023/5/19.
//

import Foundation
import AppKit

class KeyMonitorManager {
    static let shared = KeyMonitorManager()
    
    var keyMonitor = KeyMonitor(.option, scope: .global)
    private var enabled = false
    
    func updateModifier(_ modifier: NSEvent.ModifierFlags?) {
        if let modifier = modifier {
            keyMonitor.modifier = modifier
            enabled = true
        } else {
            enabled = false
        }
    }
    
    func start() {
        keyMonitor.onDoubleTap = {
            print("Command key double tapped enabled \(self.enabled)")
            if self.enabled {
                resume()
            }
        }
        keyMonitor.start()
    }
    
    func enable(_ enable: Bool) {
        enabled = enable
    }
    
    func stop() {
        keyMonitor.stop()
    }
}
