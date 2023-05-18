//
//  TypingInPlace.swift
//  Found
//
//  Created by lixindong on 2023/5/14.
//

import Foundation
import KeyboardShortcuts
import AppKit

class TypingInPlace: ObservableObject {
    static let shared = TypingInPlace()
    
    @Published var typing: Bool = false
    private var sendTask: Task<Void, Error>? = nil
    private var api: ChatGPTAPI? = nil
    private var pasteTimer: Timer? = nil
    
    func typeInPlace(conv: GPTConversation) {
        performGlobalCopyShortcut()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let cp = getLatestTextFromPasteboard()
            print("newClip", cp.text, cp.time)
            var newValue = cp.text ?? ""

            if (!newValue.isEmpty) {
                self.interupt()
                self.api = conv.API
                print("asking api \(newValue)")
                self.sendTask = Task { [weak self] in
                    do {
                        guard let self = self else { return }
                        guard let api = self.api else { return }
                        TypingInPlace.shared.typing = true
                        api.systemPrompt += "用户输入："
                        let stream = try await api.sendMessageStream(text: newValue)
                        var sentence = ""
                        var puncted = false
                        let isNotion = isInNotion()
                        print("isNotion \(isNotion)")
                        
                        self.pasteTimer = Timer.scheduledTimer(withTimeInterval: 1.0/3.0, repeats: true) { timer in
                            if !sentence.isEmpty {
                                paste(delay: 0, sentence: sentence)
                                sentence = ""
                            }
                        }
                        for try await answer in stream {
                            sentence += answer
                        }
                        
                        self.interupt()
                        if !sentence.isEmpty {
                            paste(delay: 0, sentence: sentence)
                            sentence = ""
                        }
                    }
                    catch {
                        self?.interupt()
                    }
                }
            }
        }
    }
    
    func interupt() {
        sendTask?.cancel()
        sendTask = nil
        
        api?.interupt()
        api = nil
        
        typing = false
        
        pasteTimer?.invalidate()
        pasteTimer = nil
    }
}

private var queue = DispatchQueue(label: "trans")

func paste(delay: CGFloat, sentence: String) {
    queue.asyncAfter(deadline: .now() + delay) {
        copy(text: sentence)
//        print("copy into clipboard")
        performGlobalPasteShortcut()
        print("paste \(sentence)")
    }
}

func isInNotion() -> Bool {
    let notionBundleID = "notion.id"

    return NSWorkspace.shared.frontmostApplication?.bundleIdentifier == notionBundleID
}
