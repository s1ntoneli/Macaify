//
//  MacContentView.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import SwiftUI

struct MacContentView: View {
    @StateObject var pathManager = PathManager.shared
    @State var lastTarget: Target?

    var body: some View {
        NavigationStack(path: $pathManager.path) {
            mainView
                .navigationDestination(for: Target.self) { target in
                    ZStack {
//                        log(target)
                        switch target {
                        case .main: mainView
                        case .addCommand: addCommandView
                        case .editCommand(let command): makeEditCommandView(command)
                        case .setting: settingView
                        case .chat(let command, let msg, let mode): makeChatView(command, msg: msg, mode: mode)
                        case .playground: playground
                        }
                    }
                }
        }
        .environmentObject(pathManager)
    }
    
    func log(_ target: Target) -> some View {
        Task {
            print("log \(target)")
            lastTarget = target
        }
//        lastTarget = target
        return ZStack {
        }
    }
    
    var mainView: some View {
        MainView()
    }
    
    var addCommandView: some View {
        AddCommandView()
    }
    
    var settingView: some View {
        SettingView {
            pathManager.back()
        }
    }
    
    var playground: some View {
        PromptPlayground()
//        AppQuickOpen()
    }

    func makeChatView(_ command: Command, msg: String?, mode: ChatMode = .normal) -> some View {
        print("makeChatView \(command.name) \(msg) \(mode)")
        return ChatView(command: command, msg: msg, mode: mode).id(command.id)
    }

    func makeEditCommandView(_ command: Command)-> some View {
        AddCommandView(id: command.id, commandName: command.name, prompt: command.protmp, shortcut: command.shortcut, autoAddSelectedText: command.autoAddSelectedText)
    }
}

enum Target: Hashable {
    case main
    case setting
    case addCommand
    case playground
    case editCommand(command: Command)
    case chat(command: Command, msg: String? = nil, mode: ChatMode = .normal)
}

//struct MacContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        MacContentView()
//    }
//}

struct TView: View {
    
    init() {
        print("TView test")
    }
    var body: some View {
        Text("test 0")
    }
}
