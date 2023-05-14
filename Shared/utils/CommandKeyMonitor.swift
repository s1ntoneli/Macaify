//
//  CommandKeyMonitor.swift
//  Found
//
//  Created by lixindong on 2023/4/28.
//

import Foundation
import Cocoa

class EventMonitor {
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void
    
    init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    func start() {
        NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { event in
            self.handler(event)
        }
        monitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] (event) -> NSEvent? in
            self?.handler(event)
            return event
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
    private var commandKeyDownTime: TimeInterval = 0
    
    var commandKeyUpHandler: (() -> Void)?
    var commandKeyDownHandler: (() -> Void)?
    var commandKeyDoubleTapHandler: (() -> Void)?
    
    func start() {
        eventMonitor = EventMonitor(mask: [.flagsChanged]) { [weak self] event in
            guard let self = self else { return }
            guard let event = event else { return }

            if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                self.isCommandKeyDown = true
                if event.timestamp - self.commandKeyDownTime < 0.25 {
                    self.commandKeyDoubleTapHandler?()
                } else {
                    self.commandKeyDownHandler?()
                }
                self.commandKeyDownTime = event.timestamp

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
                self.commandKeyUpHandler?()
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
