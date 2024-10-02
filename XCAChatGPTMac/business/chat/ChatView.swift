//
//  ChatView.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/9.
//

import SwiftUI
//import AlertToast

struct ChatView: View {
    let conversation: GPTConversation
    let mode: ChatMode
    let onBack: () -> Void
    var id: UUID {
        get {
            conversation.id
        }
    }
    
    var pathManager: PathManager = PathManager.shared
    var commandStore: ConversationViewModel = ConversationViewModel.shared
    @State var vm: ViewModel
    @AppStorage("proxyAddress") private var proxyAddress = ""
    @AppStorage("useProxy") private var useProxy = false

    @State private var showToast = false

    init(command: GPTConversation, msg: String? = nil, mode: ChatMode = .normal, onBack: @escaping () -> Void) {
        self.conversation = command
        self.mode = mode
        self.onBack = onBack
        let useVoice = UserDefaults.standard.object(forKey: "useVoice") as? Bool ?? false
        let api = command.API
//        self.vm = ViewModel(conversation: command, api: api, enableSpeech: useVoice)
        self.vm = commandStore.commandViewModel(command)
        print("ChatView init")
//        print("proxy \(useProxy) \(proxyAddress) \(msg)")
        self.vm.inputMessage = msg ?? ""
    }

    var body: some View {
//        let _ = Self._printChanges() // ✅ Dump the information that triggered the View update.

        ContentView(vm: self.vm)
            .safeAreaInset(edge: .top, content: {
                VStack(spacing: 0) {
                    titleBar
                        .background(.white.opacity(0.95))
                        .background(.regularMaterial)
                        .shadow(color: .gray.opacity(0.05), radius: 20)
                    Divider()
        //                .toast(isPresenting: $showToast){
                            // `.alert` is the default displayMode
        //                    AlertToast(displayMode: .hud, type: .regular, title: "Added to favorites", style: .style(backgroundColor: .white))
                            
                            //Choose .hud to toast alert from the top of the screen
                            //AlertToast(displayMode: .hud, type: .regular, title: "Message Sent!")
        //                }
                }
            })
        .ignoresSafeArea(.all)
        .background(.white)
        .onKeyPressed(.escape) { event in
            print("escape")
            NSApp.hide(nil)
            return true
        }
    }

    var titleBar: some View {
        ConfigurableView(onBack: {
            onBack()
        }, title: "\(conversation.iconOrDefault) \(conversation.name)", showLeftButton: true, actions: {
            switch mode {
            case .normal: normalActions
            case .trial: trialActions
            }
        })
//        .navigationBarBackButtonHidden(true)
        .onAppear {
            print("chatView onAppear \(conversation.name) conversationId \(conversation.id)")
            Task { [self] in
                print("run task sendTapped conversationId \(conversation.id)")
                if (!vm.isInteractingWithChatGPT && !self.vm.inputMessage.isEmpty) {
                    await self.vm.sendTapped()
                }
            }
        }
        .onDisappear {
            print("chatView onDisappear \(conversation.name)")
        }
    }
    
    var normalActions: some View {
        PlainButton(icon: "slider.horizontal.3", shortcut: .init("e"), modifiers: .command, action: {
            // 编辑按钮的响应
            print("button down")
            pathManager.to(target: .editCommand(command: conversation))
        })
    }
    
    var trialActions: some View {
        PlainButton(icon: "rectangle.stack.badge.plus", label: "添加到常用", backgroundColor: Color.purple, pressedBackgroundColor: Color.purple.opacity(0.8), foregroundColor: .white, shortcut: .init("e"), modifiers: .command, action: {
            // 编辑按钮的响应
            print("添加到常用 \(conversation.name)")
            commandStore.addCommand(command: conversation)
            showToast = true
        })
    }
    
    @MainActor
    func setMessage(msg: String?) async {
        print("ChatView setMessage \(msg)")
        self.vm.inputMessage = msg ?? ""
        await self.vm.sendTapped()
    }
}
//
//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView()
//    }
//}

enum ChatMode {
    case normal
    case trial
}
