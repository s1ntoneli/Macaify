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
    var command: GPTConversation {
        GPTConversation(self.title, prompt: self.prompt)
    }
}
