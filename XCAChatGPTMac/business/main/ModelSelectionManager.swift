//
//  ModelSelectionManager.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import Foundation

class ModelSelectionManager {
    static let shared = ModelSelectionManager()

    struct Model {
        let name: String
        let id: String
    }

    let models = [
        Model(name: "gpt-3.5-turbo", id: "gpt3turbo"),
        Model(name: "gpt-4", id: "gpt4"),
    ]
    
    var selectIndex: Int {
        models.firstIndex(where: { $0.id == getSelectedModelId() }) ?? 0
    }
    
    var selectedModel: Model {
        models[selectIndex]
    }

    private let selectedModelId = "selectedModelId"

    private init() {
        
    }

    func getSelectedModelId() -> String {
        return UserDefaults.standard.string(forKey: selectedModelId) ?? models.first!.id
    }

    func setSelectedModelId(_ id: String) {
        UserDefaults.standard.set(id, forKey: selectedModelId)
    }

    func setSelectedModelIndex(_ index: Int) {
        UserDefaults.standard.set(models[index].id, forKey: selectedModelId)
    }
}
