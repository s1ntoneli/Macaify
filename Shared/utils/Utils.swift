//
//  Utils.swift
//  Found
//
//  Created by lixindong on 2023/5/16.
//

import Foundation
import AppKit

func isApiKeyValid(apiKey: String) -> Bool {
    do {
        let urlString = "https://api.openai.com/v1/completions"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        let requestData = ["model": "text-ada-001", "prompt": "Hello, world!", "max_tokens": 5] as [String : Any]
        let jsonData = try JSONSerialization.data(withJSONObject: requestData, options: [])
        request.httpBody = jsonData
        let semaphore = DispatchSemaphore(value: 0)
        var choicesNotEmpty = false
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                if let choices = json["choices"] as? [[String: Any]], !choices.isEmpty {
                    choicesNotEmpty = true
                }
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return choicesNotEmpty
    } catch {
        print("Error: \(error)")
        return false
    }
}

func appShortcutOption() -> String {
    UserDefaults.standard.string(forKey: "appShortcutOption") ?? "option"
}

func appShortcutKey() -> NSEvent.ModifierFlags? {
    switch appShortcutOption() {
    case "command": return .command
    case "option": return .option
    case "control": return .control
    case "function": return .function
    default: return nil
    }
}
