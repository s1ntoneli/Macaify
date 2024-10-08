//
//  WindowManager.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import Foundation
import SwiftUI
import Combine

class PathManager: ObservableObject {
    static let shared = PathManager()
    @Published var path = []
    @Published var pathStack = []

    var cancellables = Set<AnyCancellable>()

    var top: Target? {
        get {
            pathStack.last as? Target ?? .main()
        }
    }
    
    init() {
        $path
            .sink { [weak self] value in
                guard let self = self else { return }
                print("top changed")
                DispatchQueue.main.async {
                    if case .main(_) = self.top {
                        print("new to Main")
                        NotificationCenter.default.post(name: .init("toMain"), object: self)
                    }
                }
            }
            .store(in: &cancellables)
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
    
    func toMain(command: GPTConversation? = nil) {
        pathStack.removeAll()
        
        path.append(Target.main(command: command))
        pathStack.append(Target.main(command: command))
    }

    func toChat(_ command: GPTConversation, msg: String? = nil, mode: ChatMode = .normal) {
        toMain(command: command)
    }
}
