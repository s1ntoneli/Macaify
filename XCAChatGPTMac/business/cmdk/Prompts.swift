//
//  Prompts.swift
//  Macaify
//
//  Created by lixindong on 2024/8/13.
//

import Foundation

func getPrompt(text: String, cmd: String) -> (String, String) {
    if isCodeSnippet(text) {
        print("ooooo is code snippet")
        return codeEditPrompt(code: text, cmd: cmd)
    } else {
        print("ooooo is text")
        return nonCodeEditPrompt(text: text, cmd: cmd)
    }
}


func codeEditPrompt(code: String, cmd: String) -> (String, String) {
    let systemPrompt = """
You are an intelligent programmer. You are helping a colleague rewrite a piece of code.
    
Your colleague is going to give you a file and a selection to edit, along with a set of instructions. Please rewrite the selected code according to their instructions.

Think carefully and critically about the rewrite that best follows their instructions.
"""
    
    let userPrompt = """
Please rewrite this selection following these instructions:

## Edit Prompt

\(cmd)

## Selection to Rewrite
// Start of Selection
\(code)
// End of Selection
Please rewrite the selected code according to the instructions. Remember to only rewrite the code in the selection.



Please format your output as:
// Start of Selection
// INSERT_YOUR_REWRITE_HERE
// End of Selection

Immediately start your response with ```
"""
    
    return (systemPrompt, userPrompt)
}

func isCodeSnippet(_ text: String) -> Bool {
    let codePattern = "^(?:\\s*[\\w\\W]+\\s*|\\s*//.*|/\\*[\\s\\S]*?\\*/\\s*)+$"
    let regex = try! NSRegularExpression(pattern: codePattern, options: [])
    let range = NSRange(location: 0, length: text.utf16.count)
    return regex.firstMatch(in: text, options: [], range: range) != nil
}


func nonCodeEditPrompt(text: String, cmd: String) -> (String, String) {
    let systemPrompt = """
你是一个twitter营销大师，你要帮助我完成twitter内容的生产和发布。

你的任务是我会给你一段主题和相关资料，你把它用英文重写出来，记住要有亲和力，最好有些幽默元素。但是切记，要像真人。
"""

    let userPrompt = """
Please rewrite this selection following these instructions:

## Edit Prompt

\(cmd)

## Selection to Rewrite
// Start of Selection
\(text)
// End of Selection
Please rewrite the selected code according to the instructions. Remember to only rewrite the code in the selection.


Please format your output as:
// Start of Selection
// INSERT_YOUR_REWRITE_HERE
// End of Selection
"""
    
    return (systemPrompt, userPrompt)
}
