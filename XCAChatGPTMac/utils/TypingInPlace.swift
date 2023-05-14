//
//  TypingInPlace.swift
//  Found
//
//  Created by lixindong on 2023/5/14.
//

import Foundation
import KeyboardShortcuts

private var queue = DispatchQueue(label: "trans")

func typeInPlace() {
    
    // MARK: - QuickOpen
    //        NSWorkspace.shared.runningApplications.forEach { app in
    //            if let id = app.bundleIdentifier, !id.isEmpty {
    //                print("register hotkey \(id)")
    //                KeyboardShortcuts.onKeyDown(for: .init(id)) {
    //                    print("onKeyDown \(id)")
    //                    let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: id)
    //                    if appURL != nil {
    //                        do {
    //                            try NSWorkspace.shared.launchApplication(at: appURL!, configuration: [:])
    //                        } catch {
    //                            print("")
    //                        }
    //                    }
    //                }
    //            }
    //        }
    KeyboardShortcuts.onKeyDown(for: .quickTranslateCh) {
        performGlobalCopyShortcut()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let cp = getLatestTextFromPasteboard()
            print("newClip", cp.text, cp.time)
            var newValue = cp.text ?? ""
            
            if (!newValue.isEmpty) {
                let api = ChatGPTAPI(apiKey: "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", systemPrompt: "你是一个语言能力者，你帮我把``` 内包裹的文字优化成高情商说法，你的回应格式是：<优化后的文字>", temperature: 0,baseURL: "https://openai.gokoding.com", withContext: false)
                
                print("asking api \(newValue)")
                Task {
                    do {
                        //                            let answer = try await api.sendMessage("```\(newValue)```")
                        //                            print("get answer \(answer)")
                        //                            copy(text: answer)
                        //                            print("copy into clipboard")
                        //                            performGlobalPasteShortcut()
                        //                            print("paste \(answer)")
                        
                        let stream = try await api.sendMessageStream(text: newValue)
                        var sentence = ""
                        var puncted = false
                        
                        var delay = 0.0
                        for try await answer in stream {
                            //                                queue.asyncAfter(deadline: .now() + delay) {
                            //                                    Task { @MainActor in
                            print("get answer \(answer)")
                            for char in answer {
                                if char.isPunctuation {
                                    print("ispun")
                                    puncted = true
                                    sentence += String(char)
                                    continue
                                }
                                if !char.isPunctuation && puncted {
                                    //                                                newLine(text: sentence)
                                    
                                    let s = sentence
                                    queue.asyncAfter(deadline: .now() + delay) {
                                        //                                                                                    Task { @MainActor in
                                        copy(text: s)
                                        print("copy into clipboard")
                                        performGlobalPasteShortcut()
                                        print("paste \(s)")
                                    }
                                    delay += 0.1
                                    
                                    print("sentence \(sentence)")
                                    puncted = false
                                    sentence = String(char)
                                    continue
                                }
                                sentence += String(char)
                            }
                            //                                    }
                            //                                }
                            //                                delay += 0.05
                        }
                        
                        let s = sentence
                        queue.asyncAfter(deadline: .now() + delay) {
                            //                                                                                    Task { @MainActor in
                            copy(text: s)
                            print("copy into clipboard")
                            performGlobalPasteShortcut()
                            print("paste \(s)")
                        }
                        
                    }
                    catch {
                        
                    }
                }
            }
        }
    }
    KeyboardShortcuts.onKeyDown(for: .quickTranslateEng) {
        performGlobalCopyShortcut()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let cp = getLatestTextFromPasteboard()
            print("newClip", cp.text, cp.time)
            var newValue = cp.text ?? ""
            
            if (!newValue.isEmpty) {
                let api = ChatGPTAPI(apiKey: "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", systemPrompt: "把```包裹的文本翻译成英文，你的回应应只包含翻译后的文本，不要带多余的符号。回应格式：<翻译成英文的文本>", temperature: 0, withContext: false)
                
                print("asking api \(newValue)")
                Task {
                    do {
                        //                            let answer = try await api.sendMessage("```\(newValue)```")
                        //                            print("get answer \(answer)")
                        //                            copy(text: answer)
                        //                            print("copy into clipboard")
                        //                            performGlobalPasteShortcut()
                        //                            print("paste \(answer)")
                        
                        let stream = try await api.sendMessageStream(text: newValue)
                        var sentence = ""
                        var puncted = false
                        
                        var delay = 0.0
                        for try await answer in stream {
                            //                                queue.asyncAfter(deadline: .now() + delay) {
                            //                                    Task { @MainActor in
                            print("get answer \(answer)")
                            for char in answer {
                                if char.isPunctuation {
                                    print("ispun")
                                    puncted = true
                                    sentence += String(char)
                                    continue
                                }
                                if !char.isPunctuation && puncted {
                                    //                                                newLine(text: sentence)
                                    
                                    let s = sentence
                                    queue.asyncAfter(deadline: .now() + delay) {
                                        //                                                                                    Task { @MainActor in
                                        copy(text: s)
                                        print("copy into clipboard")
                                        performGlobalPasteShortcut()
                                        print("paste \(s)")
                                    }
                                    delay += 0.1
                                    
                                    print("sentence \(sentence)")
                                    puncted = false
                                    sentence = String(char)
                                    continue
                                }
                                sentence += String(char)
                            }
                            //                                    }
                            //                                }
                            //                                delay += 0.05
                        }
                        
                        let s = sentence
                        queue.asyncAfter(deadline: .now() + delay) {
                            //                                                                                    Task { @MainActor in
                            copy(text: s)
                            print("copy into clipboard")
                            performGlobalPasteShortcut()
                            print("paste \(s)")
                        }
                        
                    }
                    catch {
                        
                    }
                }
                
            }
        }
    }
}
