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
    
    func back() {
        print("back")
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func to(target: Target) {
        path.append(target)
    }
    
    func toMain() {
        if (path.count > 0) {
            path.removeLast(path.count)
        }
    }

    func toChat(_ command: Command) {
        if (path.count > 0) {
            path.removeLast(path.count)
        }
        to(target: .chat(command: command))
    }
}
