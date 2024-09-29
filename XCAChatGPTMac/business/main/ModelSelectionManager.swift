//
//  ModelSelectionManager.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import Foundation
import Defaults

class ModelSelectionManager {
    static let shared = ModelSelectionManager()

    let models = LLMModelsManager.shared.modelCategories.flatMap { $0.models }

    func model(name: String) -> Model? {
        models.first(where: { $0.name == name }) ?? Model(name: name, contextLength: 4096)
    }

    private init() {
        
    }

    func getSelectedModelId() -> String {
        let modelId = Defaults[.selectedModelId]
        if modelId.isEmpty {
            return models.first!.id
        } else {
            return modelId
        }
    }
}
