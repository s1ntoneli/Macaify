//
//  QuickOpen.swift
//  Found
//
//  Created by lixindong on 2023/4/21.
//

import Foundation

import Cocoa

class QuickOpen {
    
    static let shared = QuickOpen()
    
    func getApps() {
        let apps = NSWorkspace.shared.runningApplications

        for app in apps {
            guard let appName = app.localizedName else { continue }
            print(appName)
        }
    }
}
