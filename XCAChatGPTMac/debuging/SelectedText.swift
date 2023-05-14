//
//  SelectedText.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/16.
//

import Foundation

import Cocoa
//
//func getSelectedText() -> String? {
//    let systemWideElement = AXUIElementCreateSystemWide()
//    guard let focusedElement = try? systemWideElement.focusedUIElement(),
//          let selectedText = try? focusedElement.selectedText() else {
//        return nil
//    }
//    return selectedText
//}
//
//extension AXUIElement {
//    func focusedUIElement() throws -> AXUIElement? {
//        var result: AnyObject?
//        let status = AXUIElementCopyAttributeValue(self, kAXFocusedUIElementAttribute as CFString, &result)
//        guard status == .success else { throw NSError(domain: NSCocoaErrorDomain, code: Int(status), userInfo: nil) }
//        return result as? AXUIElement
//    }
//
//    func selectedText() throws -> String? {
//        var result: AnyObject?
//        let status = AXUIElementCopyAttributeValue(self, kAXSelectedTextAttribute as CFString, &result)
//        guard status == .success else { throw NSError(domain: NSCocoaErrorDomain, code: Int(status), userInfo: nil) }
//        return result as? String
//    }
//}


import Cocoa
//
//func getSelectedText() -> String? {
//    guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
//        return nil
//    }
//
//
//
//    guard let focusedWindow = frontmostApp.windows.first(where: { \$0.isMainWindow && \$0.isVisible }) else {
//        return nil
//    }
//    guard let selectedText = focusedWindow.selectedText else {
//        return nil
//    }
//    return selectedText
//}
//
//extension NSWindow {
//    var selectedText: String? {
//        let element = accessibilityFocusedUIElement()
//        var selectedText: AnyObject?
//        let status = AXUIElementCopyAttributeValue(element as! AXUIElement, kAXSelectedTextAttribute as CFString, &selectedText)
//        return status == .success ? selectedText as? String : nil
//    }
//}

func performGlobalCopyShortcut() {

   func keyEvents(forPressAndReleaseVirtualKey virtualKey: Int) -> [CGEvent] {
       let eventSource = CGEventSource(stateID: .hidSystemState)
       return [
           CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: true)!,
           CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: false)!,
       ]
   }

   let tapLocation = CGEventTapLocation.cghidEventTap
    let events = keyEvents(forPressAndReleaseVirtualKey: 8)

   events.forEach {
       $0.flags = .maskCommand
       $0.post(tap: tapLocation)
   }
}
func performGlobalPasteShortcut() {

   func keyEvents(forPressAndReleaseVirtualKey virtualKey: Int) -> [CGEvent] {
       let eventSource = CGEventSource(stateID: .hidSystemState)
       return [
           CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: true)!,
           CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: false)!,
       ]
   }

   let tapLocation = CGEventTapLocation.cghidEventTap
    let events = keyEvents(forPressAndReleaseVirtualKey: 9)

   events.forEach {
       $0.flags = .maskCommand
       $0.post(tap: tapLocation)
   }
}

func getLatestTextFromPasteboard() -> (text: String?, time: Date?) {
    guard let pasteboard = NSPasteboard.general.pasteboardItems else {
        return (nil, nil)
    }
    guard let latestItem = pasteboard.first else {
        return (nil, nil)
    }
    let text = latestItem.string(forType: .string)
//    let time = latestItem.propertyList(forType: .init(rawValue: "com.apple.metadata:kMDItemCopyTimestamp")) as? Date
    let timeData = latestItem.propertyList(forType: .color)
//    let time = timeData?["com.apple.metadata:kMDItemCopyTimestamp"] as? Date
    print("timeData \(timeData)")

    return (text, Date())
}

func copy(text: String) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(text, forType: .string)
}
