//
//  APIKeyManager.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import Foundation

class APIKeyManager: ObservableObject {
    
    static let shared = APIKeyManager()
    
    @Published var key: String?

    private let apiKeyKey = "apiKey"

    private init() {
        key = getAPIKey()
    }

    func getAPIKey() -> String {
        return UserDefaults.standard.string(forKey: apiKeyKey) ?? ""
    }

    func setAPIKey(_ apiKey: String) {
        key = apiKey
        UserDefaults.standard.set(apiKey, forKey: apiKeyKey)
    }
}
