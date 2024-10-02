//
//  CommandStore.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import Foundation
import SwiftUI
import KeyboardShortcuts
import Defaults

class ConversationViewModel: ObservableObject {
    
    static let shared = ConversationViewModel()
    
    @Published var conversations: [GPTConversation] = []
    @Published var filteredConvs: [GPTConversation] = []
    
    // 当前进行的聊天
    @Published var currentChat: GPTConversation?
    
    // 选中的列表项下标
    @Published var hoveredCommand: GPTConversation?
    var selectedItemIndex: Int {
        get {
            if let hoveredCommand {
                return conversations.firstIndex(of: hoveredCommand) ?? -1
            } else {
                return -1
            }
        }
        set {
            hoveredCommand = conversations.indices.contains(newValue) ? conversations[newValue] : nil
        }
    }

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

    var selectedCommand: GPTConversation? {
        conversations.indices.contains(selectedItemIndex) ? conversations[selectedItemIndex] : nil
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
        print("CommandStore loadCommands", conversations.count)
    }
    
    func indexOf(conv: GPTConversation) -> Int {
        for i in conversations.indices {
            if conv.id == conversations[i].id {
                return i
            }
        }
        return -1
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
        return ChatGPTAPI(apiKey: Defaults[.apiKey], model: ModelSelectionManager.shared.getSelectedModelId(), provider: Defaults[.selectedProvider], maxToken: Defaults[.maxToken], systemPrompt: prompt, temperature: 0.5, baseURL: Defaults[.proxyAddress])
    }
    
    var shortcutDescription: String {
//        "\(KeyboardShortcuts.getShortcut(for: KeyboardShortcuts.Name(uuid.uuidString)))"
        ""
    }

    static var empty: GPTConversation {
        get {
            GPTConversation(String(localized: "Ask a Question", locale: Locale(identifier: "en"), comment: ""), icon: "✨", withContext: true)
        }
    }
}
