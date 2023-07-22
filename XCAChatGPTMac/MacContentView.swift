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
    @State private var showNewFeatureIntroduction = false
    @State private var showPreferenceInitializer = false
    @AppStorage("selectedLanguage") var userDefaultsSelectedLanguage: String?

//#if DEBUG
//    let _ = Self._printChanges()
//#endif

    var body: some View {
        content
            .environmentObject(pathManager)
    }
    
    var content: some View {
        ZStack {
            mainView
            switch pathManager.top {
            case .main: mainView
            case .addCommand: addCommandView
            case .editCommand(let command): makeEditCommandView(command)
            case .setting: settingView
            case .chat(let command, let msg, let mode): makeChatView(command, msg: msg, mode: mode)
            case .playground: playground
            default: EmptyView()
            }
            StartUpView()
        }
    }
    
    struct InputSheetView: View {
        @State private var text = ""

        var body: some View {
            VStack {
                TextField("Enter text", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                // Add any other views you want to display in the sheet
            }
        }
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
        ConversationPreferenceView(conversation: GPTConversation(""), mode: .add)
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

    func makeChatView(_ command: GPTConversation, msg: String?, mode: ChatMode = .normal) -> some View {
        print("makeChatView \(command.name) \(msg) \(mode)")
        return ChatView(command: command, msg: msg, mode: mode).id(command.id)
    }

    func makeEditCommandView(_ command: GPTConversation)-> some View {
        ConversationPreferenceView(conversation: command, mode: .edit)
    }
}

enum Target: Hashable {
    case main
    case setting
    case addCommand
    case playground
    case editCommand(command: GPTConversation)
    case chat(command: GPTConversation, msg: String? = nil, mode: ChatMode = .normal)
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
