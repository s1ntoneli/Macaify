//
//  KeyEvents.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/15.
//

import Foundation
import AppKit
import SwiftUI

struct OnKeyPressed: ViewModifier {
    var keyAction: KeyAction?
    var callback: (NSEvent) -> Bool
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        var listener = KeyboardListener(target: PathManager.shared.top, keyAction: keyAction, callback: callback)
        content.background(listener)
            .onAppear {
                listener.window = NSApplication.shared.keyWindow
            }
    }

    private struct KeyboardListener: NSViewRepresentable {
        var target: Target?
        var keyAction: KeyAction?
        var callback: (NSEvent) -> Bool
        var window: NSWindow?
        var nsView: NSView?

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        func makeNSView(context: Context) -> NSView {
            let view = NSView()
            view.addTrackingArea(NSTrackingArea(rect: view.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: context.coordinator))
            context.coordinator.nsView = view
            return view
        }

        func updateNSView(_ nsView: NSView, context: Context) {
        }

        class Coordinator: NSObject {
            var parent: KeyboardListener
            var nsView: NSView?

            init(_ parent: KeyboardListener) {
                self.parent = parent
                super.init()
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    print("get event \(event.keyCode)")
                    if parent.target == PathManager.shared.top {
                        print("dealing event \(event.keyCode)")
                        if parent.keyAction == nil || event.action == parent.keyAction {
                            return parent.callback(event) ? nil : event
                        }
                    }
                    return event
                }
            }
        }
    }
}

extension View {
    func onKeyPressed(callback: @escaping (NSEvent) -> Bool) -> some View {
        modifier(OnKeyPressed(callback: callback))

    }
    func onKeyPressed(_ keyAction: KeyAction, callback: @escaping (NSEvent) -> Bool) -> some View {
        modifier(OnKeyPressed(keyAction: keyAction, callback: callback))
    }
}


struct KeyEventsContentView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
        }
        .onKeyPressed { event in
            print("key \(event.characters)")
            return true
        }
    }
}
