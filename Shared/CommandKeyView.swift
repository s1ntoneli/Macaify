//
//  CommandKeyView.swift
//  Found
//
//  Created by lixindong on 2023/4/28.
//

import Foundation
import SwiftUI

struct CommandKeyView: NSViewRepresentable {
    typealias NSViewType = CustomView
    
    var onCommandKeyDown: (() -> Void)?
    var onCommandKeyUp: (() -> Void)?
    
    func makeNSView(context: Context) -> CustomView {
        let view = CustomView(frame: .zero)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
        view.alphaValue = 0.01
        
        NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged]) { (event) in
            if event.modifierFlags.contains(.command) {
                if event.type == .keyDown {
                    self.onCommandKeyDown?()
                } else if event.type == .keyUp {
                    self.onCommandKeyUp?()
                }
            }
        }
        
        return view
    }
    
    func updateNSView(_ nsView: CustomView, context: Context) {}
}

import Cocoa

class CustomView: NSView {

    override func flagsChanged(with event: NSEvent) {
        print("flat changed")
        super.flagsChanged(with: event)
    }
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // 绘制一个紫色椭圆形
        let path = NSBezierPath(ovalIn: dirtyRect)
        NSColor.purple.setFill()
        path.fill()
    }
}

class ViewController: NSViewController {
    var commandKeyDown = false
    var commandKeyDownTimestamp: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { (event) -> NSEvent? in
            if event.modifierFlags.contains(.command) {
                if !self.commandKeyDown {
                    self.commandKeyDown = true
                    self.commandKeyDownTimestamp = event.timestamp
                } else if event.timestamp - self.commandKeyDownTimestamp > 0.5 {
                    print("Command key long pressed")
                }
            } else {
                self.commandKeyDown = false
            }
            return event
        }
    }
}
