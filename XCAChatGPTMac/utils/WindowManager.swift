//
//  WindowManager.swift
//  Macaify
//
//  Created by lixindong on 2023/7/29.
//

import Foundation
import AppKit
import SwiftUI

// 位置参数，用于窗口位置
// 左上、左下、右上、右下
// 上中、下中、左中、右中
// 中心
enum WindowPosition {
    case topLeft
    case topCenter
    case topRight
    case centerLeft
    case center
    case centerRight
    case bottomLeft
    case bottomCenter
    case bottomRight
}

// 窗口管理器
// 用于管理窗口的位置、大小、显示、隐藏等
// 用法：
// 1. 设置窗口大小 代码：MWindowManager.shared.size = CGSize(width: 800, height: 600)
// 2. 设置窗口位置 代码：MWindowManager.shared.setPosition(.center)
// 3. 显示窗口 代码：MWindowManager.shared.show()
// 4. 构造函数添加 ContentView 代码：window.contentView = NSHostingView(rootView: ContentView())
class MWindowManager<Content: View> {
    // 窗口
    var window: NSWindow?
    
    // 窗口位置
    var position: WindowPosition = .center
    
    // 窗口大小
    var size: CGSize = CGSize(width: 600, height: 200)
    
    var windowController = SpotlightishWindowController()
    
    let contentView: Content
    
    init(contentView: Content) {
        self.contentView = contentView
    }

    // 窗口显示
    func show() {
        if window == nil {
            window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: size.width, height: size.height), styleMask: [.fullSizeContentView], backing: .buffered, defer: false)
            window?.titlebarAppearsTransparent = true
            window?.titleVisibility = .hidden
            window?.isMovableByWindowBackground = true
            window?.parent = nil
            window?.center()
            window?.level = .floating
            window?.backgroundColor = .orange.withAlphaComponent(0.0)
            window?.contentView = NSHostingView(rootView: contentView)
            
            window?.windowController = windowController
            windowController.window = window
        }
        window?.makeKeyAndOrderFront(nil)
        window?.deminiaturize(nil)
    }

    // 窗口隐藏
    func hide() {
        window?.orderOut(nil)
    }
    
    // 窗口位置
    func setPosition(_ position: WindowPosition) {
        self.position = position
        if window != nil {
            let screenFrame = NSScreen.main?.frame
            let windowFrame = window?.frame
            switch position {
            case .topLeft:
                window?.setFrameOrigin(NSPoint(x: 0, y: screenFrame!.height - windowFrame!.height))
            case .topCenter:
                window?.setFrameOrigin(NSPoint(x: (screenFrame!.width - windowFrame!.width) / 2, y: screenFrame!.height - windowFrame!.height))
            case .topRight:
                window?.setFrameOrigin(NSPoint(x: screenFrame!.width - windowFrame!.width, y: screenFrame!.height - windowFrame!.height))
            case .centerLeft:
                window?.setFrameOrigin(NSPoint(x: 0, y: (screenFrame!.height - windowFrame!.height) / 2))
            case .center:
                window?.center()
            case .centerRight:
                window?.setFrameOrigin(NSPoint(x: screenFrame!.width - windowFrame!.width, y: (screenFrame!.height - windowFrame!.height) / 2))
            case .bottomLeft:
                window?.setFrameOrigin(NSPoint(x: 0, y: 0))
            case .bottomCenter:
                window?.setFrameOrigin(NSPoint(x: (screenFrame!.width - windowFrame!.width) / 2, y: 0))
            case .bottomRight:
                window?.setFrameOrigin(NSPoint(x: screenFrame!.width - windowFrame!.width, y: 0))
            }
        }
    }
    
    func showPanel() {
//        let panel = KeyablePanel()
        
//        panel.windowController = windowController
//        windowController.window = panel
        windowController.window?.makeKeyAndOrderFront(nil)
        windowController.contentViewController = SpotlightishViewController()
        
        if !windowController.window!.isKeyWindow {
            // Make our application active to force our window become main, do this only when `makeKeyAndOrderFront(_:)` failed.
//            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }
    
    func closePanel() {
        windowController.close()
        windowController.window?.close()
    }
}

class SpotlightishViewController: NSViewController {
    override var acceptsFirstResponder: Bool { true }

       override func viewWillAppear() {
           // Make search field the first responder.
//           view.window?.makeFirstResponder(searchField)
       }
    override func loadView() {
        // Use visual effect view to give window a blur effect.
        let visualEffectView = NSVisualEffectView(frame: NSMakeRect(0, 0, 360, 48))
        visualEffectView.state = .active
        visualEffectView.material = .menu
        visualEffectView.blendingMode = .behindWindow
        // Use mask image to rounds window corner.
        visualEffectView.maskImage = NSImage(size: NSMakeSize(16, 16), flipped: false, drawingHandler: {
            NSColor.black.setFill()
            let path = NSBezierPath(roundedRect: $0, xRadius: 8, yRadius: 8)
            path.fill()
            return true
        })
        visualEffectView.maskImage?.capInsets = NSEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        view = visualEffectView
    }
}
