//
//  MacContentView.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import SwiftUI

struct MacContentView: View {
    @StateObject var pathManager = PathManager.shared
    @StateObject var vm: ViewModel

    var body: some View {
        NavigationStack(path: $pathManager.path) {
            mainView
                .navigationDestination(for: Target.self) { target in
                    switch target {
                    case .main: mainView
                    case .addCommand: addCommandView
                    case .editCommand(let command): makeEditCommandView(command)
                    case .setting: settingView
                    case .chat(let command): makeChatView(command)
                    }
                }
        }
        .environmentObject(pathManager)
    }
    
    var mainView: some View {
        MainView(vm: vm)
    }
    
    var addCommandView: some View {
        AddCommandView()
    }
    
    var settingView: some View {
        SettingView {
            pathManager.back()
        }
    }

    func makeChatView(_ command: Command)-> some View {
        ChatView(id: command.id)
    }

    func makeEditCommandView(_ command: Command)-> some View {
        AddCommandView(id: command.id, commandName: command.name, prompt: command.protmp, shortcut: command.shortcut, autoAddSelectedText: command.autoAddSelectedText)
    }
}

enum Target: Hashable {
    case main
    case setting
    case addCommand
    case editCommand(command: Command)
    case chat(command: Command)
}

//struct MacContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        MacContentView()
//    }
//}
