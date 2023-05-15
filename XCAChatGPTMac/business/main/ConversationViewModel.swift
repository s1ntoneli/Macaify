//
//  CommandStore.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import Foundation
import SwiftUI
import KeyboardShortcuts

class ConversationViewModel: ObservableObject {
    
    static let shared = ConversationViewModel()
    
    @Published var conversations: [GPTConversation] = []
    
    // 选中的列表项下标
    @Published var selectedItemIndex = -1
    
    private let userDefaults = UserDefaults.standard
    private let commandsKey = "commands"
    private var viewModels: [UUID: ViewModel] = [:]
    
    var useVoice: Bool {
        UserDefaults.standard.object(forKey: "useVoice") as? Bool ?? false
    }

    //    let menuBarCommand = GPTConversation("showMenuBar", autoAddSelectedText: false)
    
    //    var menuViewModel: ViewModel {
    //        commandViewModel(menuBarCommand)
    //    }

    var selectedCommandOrDefault: GPTConversation {
        conversations.indices.contains(selectedItemIndex) ? conversations[selectedItemIndex] : GPTConversation.empty
    }
    
    init() {
        self.loadCommands()
    }
    
    func updateCommand(command: GPTConversation) {
        command.save()
        notifyConversationChanged()
    }
    
    func addCommand(command: GPTConversation) {
        command.copyToCoreData().save()
        notifyConversationChanged()
    }
    
    func removeCommand(at indexSet: IndexSet) {
        indexSet.forEach { index in
            conversations[index].delete()
        }
        notifyConversationChanged()
    }
    
    func removeCommand(_ command: GPTConversation) {
        command.delete()
        notifyConversationChanged()
    }
    
    func commandViewModel(_ conversation: GPTConversation) -> ViewModel {
        let id = conversation.id
        let useVoice = UserDefaults.standard.object(forKey: "useVoice") as? Bool ?? false
        let api = conversation.API
        if let viewModel = viewModels[id] {
            viewModel.updateAPI(api: api)
            viewModel.enableSpeech = useVoice
            return viewModel
        } else {
            let viewModel = ViewModel(conversation: conversation, api: api, enableSpeech: useVoice)
            print("主动 init")
            viewModels[id] = viewModel
            return viewModel
        }
    }
    
    func loadCommands() {
        conversations = PersistenceController.shared.loadConversations()
        updateSelectedIndex()
        print("CommandStore loadCommands", conversations)
    }
    
    private func notifyConversationChanged() {
        loadCommands()
        HotKeyManager.initHotKeys()
    }
    
    private func updateSelectedIndex() {
        let count = conversations.count
        if (selectedItemIndex >= count) {
            selectedItemIndex = count - 1
        }
        if (selectedItemIndex < 0) {
            selectedItemIndex = -1
        }
    }
}

extension GPTConversation {
    
    var API: ChatGPTAPI {
        let proxyAddress = UserDefaults.standard.object(forKey: "proxyAddress") as? String ?? ""
        let useProxy = UserDefaults.standard.object(forKey: "useProxy") as? Bool ?? false
        return ChatGPTAPI(apiKey: APIKeyManager.shared.key ?? "", model: ModelSelectionManager.shared.selectedModel.name, systemPrompt: prompt, temperature: 0, baseURL: useProxy ? proxyAddress : nil)
    }
    
    var shortcutDescription: String {
        KeyboardShortcuts.getShortcut(for: KeyboardShortcuts.Name(uuid.uuidString))?.description ?? ""
    }

    static var empty: GPTConversation {
        get {
            GPTConversation("随便聊聊", icon: "💬", withContext: true)
        }
    }
}
