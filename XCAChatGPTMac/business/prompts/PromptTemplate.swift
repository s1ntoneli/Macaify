//
//  PromptTemplate.swift
//  Found
//
//  Created by lixindong on 2023/4/21.
//

import Foundation

struct PromptTemplate: Decodable {
    let title: String
    var desc: String?
    let prompt: String
}

struct PromptCategory: Decodable {
    let title: String
    let prompts: [PromptTemplate]
}

extension PromptTemplate {
    var command: Command {
        Command(name: self.title, icon: "", protmp: self.prompt, shortcut: "", autoAddSelectedText: false)
    }
}
