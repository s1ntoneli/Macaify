//
//  TypingInPlace.swift
//  Found
//
//  Created by lixindong on 2023/5/14.
//

import Foundation
import KeyboardShortcuts
import AppKit

private var queue = DispatchQueue(label: "trans")

func typeInPlace(conv: GPTConversation) {
    performGlobalCopyShortcut()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
        let cp = getLatestTextFromPasteboard()
        print("newClip", cp.text, cp.time)
        var newValue = cp.text ?? ""

        if (!newValue.isEmpty) {
            let api = conv.API
            
            print("asking api \(newValue)")
            Task {
                do {
                    let stream = try await api.sendMessageStream(text: newValue)
                    var sentence = ""
                    var puncted = false
                    let isNotion = isInNotion()
                    print("isNotion \(isNotion)")
                    
                    var delay = 0.0
                    for try await answer in stream {
//                        print("get answer \(answer)")
                        for char in answer {
                            if isNotion {
                                sentence += String(char)
                                if char.unicodeScalars.contains(where: { $0.value == 10 }) {
                                    paste(delay: delay, sentence: sentence)
                                    sentence = ""
                                    delay += 0.1

                                    //                                    print("sentence \(sentence)")
//                                    sentence = String(char)
                                }
                            } else {
                                if char.isPunctuation {
                                    //                                print("ispun")
                                    puncted = true
                                    sentence += String(char)
                                    continue
                                }
                                if !char.isPunctuation && puncted {
                                    if sentence.count > 10 {
                                        //                                    let s = sentence
                                        paste(delay: delay, sentence: sentence)
                                        
                                        delay += 0.1
                                        
                                        //                                    print("sentence \(sentence)")
                                        sentence = String(char)
                                        puncted = false
                                        continue
                                    } else {
                                        puncted = false
                                    }
                                }
                                sentence += String(char)
                            }
                        }
                    }
                    
                    paste(delay: delay, sentence: sentence)
                }
                catch {
                    
                }
            }
        }
    }
}

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
