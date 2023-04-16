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
        if (path.count > 0) {
            path.removeLast(path.count)
            pathStack.removeLast(path.count)
        }
    }

    func toChat(_ command: Command, msg: String? = nil) {
        if (path.count > 0) {
            path.removeLast(path.count)
            pathStack.removeLast(path.count)
        }
        to(target: .chat(command: command, msg: msg))
    }
}
