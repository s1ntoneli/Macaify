//
//  CommandKeyMonitor.swift
//  Found
//
//  Created by lixindong on 2023/4/28.
//

import Foundation
import Cocoa

class EventMonitor {
    let scope: Scope
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void
    
    init(mask: NSEvent.EventTypeMask, scope: Scope = .local, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
        self.scope = scope
    }
    
    deinit {
        stop()
    }
    
    func start() {
        if [Scope.both, Scope.global].contains(scope) {
            NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { event in
                self.handler(event)
            }
        }
        if [Scope.both, Scope.local].contains(scope) {
            monitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] (event) -> NSEvent? in
                self?.handler(event)
                return event
            }
        }
    }
    
    func stop() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}

class KeyMonitor {
    private var eventMonitor: EventMonitor?
    private var timer: Timer?
    private var isCommandKeyDown = false
    private var keyDownTime: TimeInterval = 0
    
    let modifier: NSEvent.ModifierFlags
    let scope: Scope
    
    var onKeyUp: (() -> Void)?
    var onKeyDown: (() -> Void)?
    var onDoubleTap: (() -> Void)?

    init(_ modifier: NSEvent.ModifierFlags, scope: Scope = .local) {
        self.modifier = modifier
        self.scope = scope
    }
    
    func start() {
        eventMonitor = EventMonitor(mask: [.flagsChanged], scope: scope) { [weak self] event in
            guard let self = self else { return }
            guard let event = event else { return }

            if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == self.modifier {
                self.isCommandKeyDown = true
                if event.timestamp - self.keyDownTime < 0.25 {
                    self.onDoubleTap?()
                } else {
                    self.onKeyDown?()
                }
                self.keyDownTime = event.timestamp

                self.timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { [weak self] _ in
                    guard let self = self else { return }
                    if self.isCommandKeyDown {
                        self.handler?()
                    }
                })
            } else {
                self.isCommandKeyDown = false
                self.timer?.invalidate()
                self.timer = nil
                self.onKeyUp?()
            }
        }
        eventMonitor?.start()
    }
    
    func stop() {
        eventMonitor?.stop()
        eventMonitor = nil
        timer?.invalidate()
        timer = nil
    }
    
    var handler: (() -> Void)?
}

enum Scope {
    case local
    case global
    case both
}
