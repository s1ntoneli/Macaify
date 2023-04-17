//
//  WindowManager.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import Foundation
import SwiftUI

class PathManager: ObservableObject {
    static let shared = PathManager()
    @Published var path = NavigationPath()
    @Published var pathStack = []
    
    var top: Target? {
        get {
            pathStack.last as? Target ?? .main
        }
    }

    func back() {
        print("back")
        if !path.isEmpty {
            path.removeLast()
            pathStack.removeLast()
        }
    }
    
    func to(target: Target) {
        path.append(target)
        pathStack.append(target)
    }
    
    func toMain() {
        while (path.count > 0) {
            path.removeLast()
            pathStack.removeLast()
        }
    }

    func toChat(_ command: Command, msg: String? = nil) {
        print("toChat")
        while (path.count > 0) {
            path.removeLast()
            pathStack.removeLast()
        }
        self.to(target: .chat(command: command, msg: msg))
    }
}
