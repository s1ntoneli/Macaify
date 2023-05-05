//
//  AddCommandView.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import SwiftUI
import AppKit
import KeyboardShortcuts

struct ConversationPreferenceView: View {

    @EnvironmentObject var commandStore: ConversationViewModel
    @EnvironmentObject var pathManager: PathManager
    @State var conversation: GPTConversation
    @State var autoAddSelectedText: Bool
    @State var oneTimeChat: Bool
    let mode: ConversationPreferenceMode

    @FocusState private var focusField: FocusField?
    @State private var isShowingPopover = false
    @State private var icon: Emoji? = nil
    
    @State private var showingAlert = false

    init(conversation: GPTConversation, mode: ConversationPreferenceMode) {
        self.conversation = conversation
        self.autoAddSelectedText = conversation.autoAddSelectedText
        self.oneTimeChat = conversation.withContext
        self.mode = mode
    }
    
    private enum FocusField {
        case title
        case prompt
        case shortcut
        case autoAddText
    }

    var isNew: Bool {
        get { mode == .add }
    }

    var body: some View {
        VStack(spacing: 0) {
            ConfigurableView(onBack: {
                if (mode == .edit) {
                    if (conversation.name.isEmpty) {
                        conversation.name = "Untitled"
                    }
                    commandStore.updateCommand(command: conversation)
                }
                pathManager.back()
            }, title: isNew ? "添加机器人" : "编辑机器人", showLeftButton: true) {
                if !isNew {
                    PlainButton(icon: "rectangle.stack.badge.minus", foregroundColor: .red, shortcut: .init("d"), modifiers: .command) {
                        // 删除按钮的响应
                        commandStore.removeCommand(conversation)
                        pathManager.toMain()
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                        Alert(title: Text("错误"), message: Text("用户名不能为空"), dismissButton: .default(Text("确定")))
                    }

            List {
                VStack(alignment: .leading, spacing: 12) {
                    iconView
                    
                    Group {
                        Text("机器人名字").font(.headline)
                        TextField("输入机器人名称方便记忆", text: $conversation.name, onCommit: {
                            print("onCommit")
                            focusField = .prompt })
                        .focusable(true)
                        .onSubmit {
                            print("onSumbit")
                            focusField = .prompt
                        }
                        .textFieldStyle(CustomTextFieldStyle())
                        .focused($focusField, equals: .title)
                    }
                    Group {
                        Text("系统提示").font(.headline)
                        TextEditor(text: $conversation.prompt)
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
                    }
                    Group {
                        Text("热键").font(.headline)
                        Form {
                            KeyboardShortcuts.Recorder("", name: KeyboardShortcuts.Name(conversation.id.uuidString))
                        }
                    }

                    autoAddText
                    
                    useContext
                }
                .padding(.top, 12)
            }
            .padding(.horizontal)

            Spacer()

            // 底部信息栏
            HStack {
                Spacer()
                PlainButton(icon: "tray.full", label: "完成", shortcut: .init("s"), modifiers: .command) {
                    // 保存按钮的响应
                    switch (mode) {
                    case .add:
                        if (conversation.name.isEmpty) {
                            conversation.name = "Untitled"
                        }
                        commandStore.addCommand(command: conversation)
                    case .edit:
                        if (conversation.name.isEmpty) {
                            conversation.name = "Untitled"
                        }
                        commandStore.updateCommand(command: conversation)
                    default:
                        break
                    }
                    pathManager.back()
                }
                .disabled(mode == .trial)
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
    
    var iconView: some View {
        Group {
            Group {
                VStack {
                    if (!conversation.icon.isEmpty) {
                        ConversationIconView(conversation: conversation, size: 40).id(conversation.icon)
                            .onTapGesture {
                                isShowingPopover.toggle()
                            }
                    } else {
                        Text("􀎸 添加图标")
                            .font(.body)
                            .opacity(0.5)
                            .onTapGesture {
                                icon = EmojiManager.shared.randomOnce()
                                isShowingPopover.toggle()
                            }
                    }
                }
            }
            .popover(isPresented: $isShowingPopover) {
                EmojiPickerView(selectedEmoji: $icon)
            }
            .onChange(of: icon?.emoji) { newValue in
                print("emoji selected \(newValue)")
                conversation.icon = newValue ?? ""
                ConversationViewModel.shared.updateCommand(command: conversation)
            }
        }
    }
    
    var useContext: some View {
        Group {
            Text("使用上下文").font(.headline)
            Toggle(isOn: $oneTimeChat) {
                Text("启用")
            }.onChange(of: oneTimeChat) { newValue in
                conversation.withContext = newValue
            }
        }
    }
    
    var autoAddText: some View {
        Group {
            Text("自动添加选中文本").font(.headline)
            Toggle(isOn: $autoAddSelectedText) {
                Text("启用")
            }.onChange(of: autoAddSelectedText) { newValue in
                conversation.autoAddSelectedText = newValue
            }
        }
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

enum ConversationPreferenceMode {
    case add
    case edit
    case trial
}
