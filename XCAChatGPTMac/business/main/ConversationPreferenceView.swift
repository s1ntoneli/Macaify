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
    @State var typingInPlace: Bool
    @State var oneTimeChat: Bool
    @State var prompt: String
    let mode: ConversationPreferenceMode

    @FocusState private var focusField: FocusField?
    @State private var isShowingPopover = false
    @State private var icon: Emoji? = nil
    
    @State private var showingAlert = false

    init(conversation: GPTConversation, mode: ConversationPreferenceMode) {
        self.conversation = conversation
        self.autoAddSelectedText = conversation.autoAddSelectedText
        self.typingInPlace = conversation.typingInPlace
        self.oneTimeChat = conversation.withContext
        self.mode = mode
        self.prompt = conversation.prompt
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
            }, title: isNew ? "create_bot" : "edit_bot", showLeftButton: true) {
                if !isNew {
                    PlainButton(icon: "trash", foregroundColor: .red, shortcut: .init("d"), modifiers: .command) {
                        // 删除按钮的响应
                        commandStore.removeCommand(conversation)
                        pathManager.toMain()
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                        Alert(title: Text("error"), message: Text("user_cannot_empty"), dismissButton: .default(Text("ok")))
                    }

            List {
                VStack(alignment: .leading, spacing: 12) {
                    iconView
                    name
                    systemProtmp
                    
                    hotkey
                    useContext

                    autoAddText
                    
                    typingInPlaceItem
                }
                .padding(.top, 12)
            }
            .padding(.horizontal)

            Spacer()

            // 底部信息栏
            HStack {
                Spacer()
                PlainButton(icon: "tray.full", label: "done", shortcut: .init("s"), modifiers: .command) {
                    // 保存按钮的响应
                    switch (mode) {
                    case .add:
                        if (conversation.name.isEmpty) {
                            conversation.name = "Untitled"
                        }
                        commandStore.addCommand(command: conversation)
                        commandStore.selectedItemIndex = 0
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
//        .navigationBarBackButtonHidden(true)
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
                        Text("add_icon")
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
    
    var name: some View {
        Group {
            Text("bot_name").font(.headline)
            TextField("input_bot_name", text: $conversation.name, onCommit: {
                print("onCommit")
            })
            .focusable(true)
            .onSubmit {
                print("onSumbit")
                focusField = .prompt
            }
            .textFieldStyle(CustomTextFieldStyle())
            .focused($focusField, equals: .title)
            .background(Color.white)
        }
    }
    
    var systemProtmp: some View {
        Group {
            Text("system_prompt").font(.headline)
            ZStack(alignment: .topLeading) {
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
//                    .lineLimit(4...6)
                    .frame(maxHeight: 160)
                    .frame(minHeight: 64)
                    .focusable(true) { focused in
                        focusField = .prompt
                    }
                    .focused($focusField, equals: .prompt)
                    .onChange(of: prompt) { newValue in
                        print("prompt changed")
                        conversation.prompt = prompt
                    }
                if prompt.isEmpty {
                    Text("prompt_placeholder")
                        .opacity(0.4)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 10)
                }
            }
        }
    }
    
    var hotkey: some View {
        Group {
            Text("hotkey").font(.headline)
            Form {
                KeyboardShortcuts.Recorder(for: conversation.Name) { shortcut in
                    print("shortcut \(shortcut) \(conversation.uuid.uuidString)")
                    if shortcut != nil {
                        HotKeyManager.register(conversation)
                    } else {
                        KeyboardShortcuts.reset(conversation.Name)
                    }
                }
            }
        }
    }
    
    var useContext: some View {
        Group {
            Text("use_context").font(.headline)
            Toggle(isOn: $oneTimeChat) {
                Text("enable")
            }.onChange(of: oneTimeChat) { newValue in
                conversation.withContext = newValue
            }
        }
    }
    
    var autoAddText: some View {
        Group {
            Text("auto_add_selected_text").font(.headline)
            Toggle(isOn: $autoAddSelectedText) {
                Text("enable")
            }.onChange(of: autoAddSelectedText) { newValue in
                conversation.autoAddSelectedText = newValue
            }
        }
    }
    
    var typingInPlaceItem: some View {
        Group {
            HStack {
                Text("tip_mode").font(.headline)
                Text("experimental_function")
                    .font(.footnote)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.blue.cornerRadius(4))
            }
            Text("tip_mode_description").font(.subheadline)
                .opacity(0.7)
            Toggle(isOn: $typingInPlace) {
                Text("enable")
            }.onChange(of: typingInPlace) { newValue in
                conversation.typingInPlace = newValue
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
