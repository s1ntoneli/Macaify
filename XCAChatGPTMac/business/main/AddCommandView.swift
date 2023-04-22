//
//  AddCommandView.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import SwiftUI
import AppKit
import KeyboardShortcuts

struct AddCommandView: View {

    @EnvironmentObject var commandStore: CommandStore
    @EnvironmentObject var pathManager: PathManager
    @State var id: UUID = UUID()
    @State var commandName = ""
    @State var prompt = ""
    @State var shortcut = ""
    @State var autoAddSelectedText = false
    
    @FocusState private var focusField: FocusField?
    
    private enum FocusField {
        case title
        case prompt
        case shortcut
        case autoAddText
    }

    var isNew: Bool {
        get {
            !commandStore.commands.contains(where: { $0.id == id })
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ConfigurableView(onBack: { pathManager.back() }, title: isNew ? "添加指令" : "编辑指令", showLeftButton: true) {
                if !isNew {
                    PlainButton(icon: "rectangle.stack.badge.minus", foregroundColor: .red, shortcut: .init("d"), modifiers: .command) {
                        // 删除按钮的响应
                        commandStore.removeCommand(by: id)
                        pathManager.toMain()
                    }
                }
            }

            List {
                VStack(alignment: .leading) {
                    Text("指令名字").font(.headline)
                    TextField("输入指令名称方便记忆", text: $commandName, onCommit: {
                        print("onCommit")
                        focusField = .prompt })
                    .focusable(true)
                            .onSubmit {
                                print("onSumbit")
                                focusField = .prompt
                            }
                        .textFieldStyle(CustomTextFieldStyle())
                        .focused($focusField, equals: .title)
                    Text("系统提示").font(.headline)
                    TextEditor(text: $prompt)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray).opacity(0.3), lineWidth: 1)
                                )
                        )
                        .foregroundColor(.text)
                        .font(.body)
                        .lineLimit(4...6)
                        .frame(maxHeight: 160)
                        .frame(minHeight: 64)
                        .focusable(true) { focused in
                            focusField = .prompt
                        }
                        .focused($focusField, equals: .prompt)
                    Spacer(minLength: 12)
                    Text("热键").font(.headline)
                    Form {
                        KeyboardShortcuts.Recorder("", name: KeyboardShortcuts.Name(id.uuidString))
                    }
                    Spacer(minLength: 12)

                    Text("自动添加选中文本").font(.headline)
                    Toggle(isOn: $autoAddSelectedText) {
                        Text("启用")
                    }
                }
                .padding(.top, 12)
            }
            .padding(.horizontal)

            Spacer()

            // 底部信息栏
            HStack {
                VStack(alignment: .leading) {
                    Text("App信息")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text("版本 1.0.0")
                        .font(.footnote)
                }
                Spacer()
                PlainButton(icon: "tray.full", label: "保存指令", shortcut: .init("s"), modifiers: .command) {
                    // 保存按钮的响应
                    commandStore.addCommand(id: id, title: commandName, prompt: prompt, shortcut: shortcut, autoAddSelectedText: autoAddSelectedText)
                    pathManager.back()
                }
            }
            .padding()
            .onAppear {
                print("AddCommandView onAppear")
                focusField = .title
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    focusField = .title
                }
            }
        }
        .background(Color(.white))
        .navigationBarBackButtonHidden(true)
    }
}
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray).opacity(0.3), lineWidth: 1)
                    )
            )
            .foregroundColor(.text)
            .font(.body)
    }
}
