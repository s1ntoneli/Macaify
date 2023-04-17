//
//  StarupPasteboardManager.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/16.
//

import Foundation

class StartupPasteboardManager {
    static let shared = StartupPasteboardManager()
    
    var currentPasted: String?
    var lastPasted: String?

    func startup(task: @escaping (_ text: String?) -> Void) {
        performGlobalCopyShortcut()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { // wait 0.05s for copy.
            let cp = getLatestTextFromPasteboard()
            print(cp.text, cp.time)
            if (cp.text != self.lastPasted) {
                self.currentPasted = cp.text
            }
            task(self.currentPasted)
        }
    }

    func consumed() {
        if let current = currentPasted, !current.isEmpty {
            lastPasted = current
        }
        currentPasted = ""
    }
}
