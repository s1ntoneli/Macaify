//
//  MenuBarManager.swift
//  XCAChatGPT
//
//  Created by lixindong on 2023/7/21.
//

import Foundation
import AppKit
import Combine
import SwiftUI

class MenuBarManager {
    private var statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()

    static let shared = MenuBarManager()
    
    private var cancellables = Set<AnyCancellable>()
    private var dots = ""
    private var menuAnimateTimer: Timer? = nil

    init() {
        TypingInPlace.shared.$typing
            .sink { [weak self] value in
                guard let self = self else { return }
                
                if (value) {
                    self.showTypingStyle()
                    self.showTypingItems()
                } else {
                    self.showNormalStyle()
                    self.showNormalItems()
                }
                
            }.store(in: &cancellables)
    }
    
    func setupMenus() {
        showNormalStyle()

        menu.removeAllItems()
        addMenuItems()

        statusItem.menu = menu
    }
    
    private func addMenuItems() {
        let website = NSMenuItem(title: "Website", action: #selector(goWebsite), keyEquivalent: "")
        website.target = self
        menu.addItem(website)
        
        let twitter = NSMenuItem(title: "Twitter", action: #selector(goTwitter) , keyEquivalent: "")
        twitter.target = self
        menu.addItem(twitter)
        
        let telegram = NSMenuItem(title: "Telegram", action: #selector(goTelegram) , keyEquivalent: "")
        telegram.target = self
        menu.addItem(telegram)
        
        let feedback = NSMenuItem(title: "Feedback", action: #selector(self.goFeedback) , keyEquivalent: "")
        feedback.target = self
        menu.addItem(feedback)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
    
    private func stopTypingItem() -> NSMenuItem {
        let stop = NSMenuItem(title: "Stop ", action: #selector(stopTyping) , keyEquivalent: "")
        stop.image = NSImage(systemSymbolName: "stop.circle", accessibilityDescription: "stop typing")
        stop.target = self
        
        return stop
    }

    private func changeStatusBarButton(number: Int) {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "\(number).circle", accessibilityDescription: number.description)
            button.title = "\(number)"
        }
    }

    private func showNormalStyle() {
        cancelAnimateTimer()
        if let button = statusItem.button {
            button.image = NSImage(named: "menubar")
            button.title = ""
        }
    }
    
    private func showNormalItems() {
        menu.removeAllItems()
        addMenuItems()
    }
    
    private func showTypingStyle() {
        startAnimateTimer()
    }
    
    private func showTypingItems() {
        menu.removeAllItems()
        menu.addItem(stopTypingItem())
        addMenuItems()
    }

    private func startAnimateTimer() {
        self.menuAnimateTimer = Timer.scheduledTimer(withTimeInterval: 1.0/3.0, repeats: true) { timer in
            withAnimation {
                // Update the dots every time the timer fires
                switch self.dots.count {
                case 0:
                    self.dots = "."
                case 1:
                    self.dots = ".."
                case 2:
                    self.dots = "..."
                case 3:
                    self.dots = ""
                default:
                    break
                }
                if let button = self.statusItem.button {
                    button.image = nil
                    button.title = "Typing\(self.dots)🖌️"
                }
            }
        }
    }
    
    private func cancelAnimateTimer() {
        self.menuAnimateTimer?.invalidate()
        self.menuAnimateTimer = nil
    }
    
    @objc func goTwitter() {
        if let url = URL(string: .twitter) {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc func goWebsite() {
        if let url = URL(string: .website) {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc func goTelegram() {
        if let url = URL(string: .telegram) {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc func goFeedback() {
        if let url = URL(string: "mailto:\(String.mail)") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc func stopTyping() {
        TypingInPlace.shared.interupt()
    }
}
