//
//  CMDKService.swift
//  XCAChatGPT
//
//  Created by lixindong on 2024/8/11.
//

import Foundation
import Cocoa


class CMDKService {
    @objc func handleSelectedText(_ pasteboard: NSPasteboard, userData: String?,  error: AutoreleasingUnsafeMutablePointer<NSString>) {
        print("processSelectedText", pasteboard.name)
        guard let content = pasteboard.string(forType: .string) else {
            error.pointee = "无法获取剪贴板内容" as NSString
            return
        }
        // Use `content`…
//        NSPasteboard.selected.setString(content)
        print("processSelectedText content:", content)
        
        pasteboard.clearContents()
        pasteboard.setString("", forType: .string)
    }
//    @objc func handleSelectedText(_ pboard: NSPasteboard, userData: String?, error: NSErrorPointer) {
//        print("handleSelectedText")
//        //        guard let items = pboard.pasteboardItems else { return }
//        guard let content = pboard.string(forType: .string) else { return }
//        
//        print("handling")
//        // 遍历选中的文本
//        // 在这里处理选中的文本
//        let processedText = processText(content)
//        
//        // 将处理后的文本写回剪贴板
//        pboard.clearContents()
//        pboard.setString(processedText, forType: .string)
//    }
    
    private func processText(_ text: String) -> String {
        // 在这里实现您的文本处理逻辑
        // 这只是一个示例,将文本转换为大写
        return text.uppercased()
    }
}
