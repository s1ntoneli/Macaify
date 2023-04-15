//
//  MyTextField.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/12.
//

import SwiftUI
import KeyboardShortcuts

struct MyTextField: View {
    @State private var text: String = ""
    @State private var numberOfLines: Int = 1
    
    let maxNumberOfLines = 5
    let lineHeight: CGFloat = 20.0
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextField("", text: $text)
//            TextEditor("", text: $text, onCommit: {})
                .task {
                    for await event in KeyboardShortcuts.events(for: KeyboardShortcuts.Name("kkb", default: .init(.return, modifiers: [.shift]))) where event == .keyUp {
//                        if event.keyCode == .return && !event.modifiers.contains(.shift) {
//                            // 如果按下的是 Enter 键，且没有按下 Shift 键，则提交内容
//                            submit()
//                        } else if event.keyCode == .return && event.modifiers.contains(.shift) {
                            // 如果按下的是 Shift+Enter，则在当前位置插入一个换行符
                        print("insert")
                            text.insert(contentsOf: "\n", at: text.index(text.startIndex, offsetBy: text.utf16.count))
//                        }
                    }
                }
                .frame(maxHeight: CGFloat(maxNumberOfLines) * lineHeight)
                .frame(height: height)
                .onChange(of: text, perform: { _ in
                    // 计算行数
                    let newNumberOfLines = text.components(separatedBy: .newlines).count
                    if newNumberOfLines != numberOfLines {
                        numberOfLines = newNumberOfLines
                        
                        // 更新高度
                        let newHeight = CGFloat(numberOfLines) * lineHeight
                        if newHeight <= CGFloat(maxNumberOfLines) * lineHeight {
                            // 如果高度没有超过最大高度，则更新高度
                            NSAnimationContext.runAnimationGroup({ context in
                                context.duration = 0.3
                                context.allowsImplicitAnimation = true
                            }, completionHandler: nil)
                        }
                    }
                })
                .onReceive(NotificationCenter.default.publisher(for: NSView.frameDidChangeNotification)) { _ in
                    // 监听视图框架变化
                    if let scrollView = findScrollView() {
                        scrollView.reflectScrolledClipView(scrollView.contentView)
                    }
                }
             
            
            // 显示占位符文本
            if text.isEmpty {
                Text("Placeholder Text")
                    .foregroundColor(Color(.placeholderTextColor))
                    .padding(.horizontal, 4.0)
                    .padding(.vertical, 8.0)
            }
        }
        .padding()
        .background(Color(.textBackgroundColor))
        .cornerRadius(8.0)
        .frame(height: height) // 设置文本框的高度
    }
    
      private func submit() {
          print("提交内容：\(text)")
          // 在这里可以添加提交内容的代码
      }
    
    private var height: CGFloat {
        // 根据当前行数计算文本框的高度
        let newHeight = CGFloat(numberOfLines) * lineHeight
        return min(newHeight, CGFloat(maxNumberOfLines) * lineHeight)
    }
    
    private func findScrollView() -> NSScrollView? {
        // 查找 TextEditor 所在的 NSScrollView
        var responder: NSResponder? = NSApplication.shared.keyWindow?.firstResponder
        while responder != nil {
            if let scrollView = responder as? NSScrollView, scrollView.documentView == NSApplication.shared.mainWindow?.contentView {
                return scrollView
            }
            responder = responder?.nextResponder
        }
        return nil
    }
}

struct MyTextField_Previews: PreviewProvider {
    static var previews: some View {
        MyTextField()
    }
}
