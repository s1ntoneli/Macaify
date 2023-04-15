//
//  CommandStore.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import Foundation
import SwiftUI
import KeyboardShortcuts

class CommandStore: ObservableObject {

    static let shared = CommandStore()

    @Published var commands: [Command] = []
    @FocusState var focus:FocusedField?

    private let userDefaults = UserDefaults.standard
    private let commandsKey = "commands"
    private var viewModels: [UUID: ViewModel] = [:]
    
    let menuBarCommand = Command(name: "showMenuBar", icon: "", protmp: "", shortcut: "", autoAddSelectedText: false)
    
    var menuViewModel: ViewModel {
        commandViewModel(menuBarCommand)
    }

    init() {
        loadCommands()
    }
    
    func focusName() {
        self.focus = .name
    }

    func addCommand(id: UUID, title: String, prompt: String, shortcut: String, autoAddSelectedText: Bool) {
        let command = Command(id: id, name: title, icon: "", protmp: prompt, shortcut: shortcut, autoAddSelectedText: autoAddSelectedText)
        if let index = commands.firstIndex(where: { $0.id == id }) {
            commands[index] = command
        } else {
            commands.append(command)
        }
        saveCommands()
    }
    
    func removeCommand(at indexSet: IndexSet) {
        commands.remove(atOffsets: indexSet)
        saveCommands()
    }
    
    func removeCommand(_ command: Command) {
        commands.removeAll(where: { $0.id == command.id })
        saveCommands()
    }

    func commandViewModel(for id: UUID) -> ViewModel {
        let command = commands.first(where: { $0.id == id })!
        return commandViewModel(command)
    }

    func commandViewModel(_ command: Command) -> ViewModel {
        let id = command.id
        let useVoice = UserDefaults.standard.object(forKey: "useVoice") as? Bool ?? false
        let api = command.API
        if let viewModel = viewModels[id] {
            viewModel.updateAPI(api: api)
            viewModel.enableSpeech = useVoice
            return viewModel
        } else {
            let viewModel = ViewModel(api: api, enableSpeech: useVoice)
            viewModels[id] = viewModel
            return viewModel
        }
    }
    private func loadCommands() {
        if let data = userDefaults.data(forKey: commandsKey) {
            do {
                let decoder = JSONDecoder()
                commands = try decoder.decode([Command].self, from: data)
            } catch {
                print("Error decoding commands: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveCommands() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(commands)
            userDefaults.set(data, forKey: commandsKey)
        } catch {
            print("Error encoding commands: \(error.localizedDescription)")
        }
    }
}

extension Command {
    
    var API: ChatGPTAPI {
        let proxyAddress = UserDefaults.standard.object(forKey: "proxyAddress") as? String ?? ""
        let useProxy = UserDefaults.standard.object(forKey: "useProxy") as? Bool ?? false
        return ChatGPTAPI(apiKey: APIKeyManager.shared.key ?? "", model: ModelSelectionManager.shared.selectedModel.name, systemPrompt: protmp, temperature: 0.5, baseURL: useProxy ? proxyAddress : nil)
    }
    
    var shortcutDescription: String {
        KeyboardShortcuts.getShortcut(for: KeyboardShortcuts.Name(id.uuidString))?.description ?? ""
    }
}
