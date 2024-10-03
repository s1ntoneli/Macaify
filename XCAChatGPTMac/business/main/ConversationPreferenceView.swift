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

            Form {
                iconView
                
                Section {
                    name
                    systemProtmp
                }
                
                useContext

                hotkey
                
                typingInPlaceItem
            }
            .background(.white)
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)

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
        LabeledContent("icon") {
            Button {
                if !conversation.icon.isEmpty {
                    isShowingPopover.toggle()
                } else {
                    icon = EmojiManager.shared.randomOnce()
                    isShowingPopover.toggle()
                }
            } label: {
                if (!conversation.icon.isEmpty) {
                    ConversationIconView(conversation: conversation, size: 40).id(conversation.icon)
                } else {
                    Text("add_icon")
                        .font(.body)
                        .opacity(0.5)
                }
            }
            .buttonStyle(.plain)
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
        TextField("bot_name", text: $conversation.name)
    }
    
    var systemProtmp: some View {
        Group {
            Text("system_prompt")
            TextEditor(text: $prompt)
                .onChange(of: prompt) { newValue in
                    print("prompt changed")
                    conversation.prompt = prompt
                }
        }
    }
    
    var hotkey: some View {
        Section("hotkey") {
            KeyboardShortcuts.Recorder(for: conversation.Name) { shortcut in
                print("shortcut \(shortcut) \(conversation.uuid.uuidString)")
                if shortcut != nil {
                    HotKeyManager.register(conversation)
                } else {
                    KeyboardShortcuts.reset(conversation.Name)
                }
            }
            .controlSize(.large)
        }
    }
    
    var useContext: some View {
        Toggle(isOn: $oneTimeChat) {
            Text("use_context")
        }
        .onChange(of: oneTimeChat) { newValue in
            conversation.withContext = newValue
        }
    }
    
    var autoAddText: some View {
        Toggle(isOn: $autoAddSelectedText) {
            Text("auto_add_selected_text")
        }.onChange(of: autoAddSelectedText) { newValue in
            conversation.autoAddSelectedText = newValue
        }
    }
    
    var typingInPlaceItem: some View {
        Section {
            Group {
                if #available(macOS 14, *) {
                    Picker("bot_type", selection: $typingInPlace) {
                        Text("bot_type_edit").tag(true)
                        Text("bot_type_chat").tag(false)
                    }
                    .pickerStyle(.segmented)
                } else {
                    Picker("bot_type", selection: $typingInPlace) {
                        Text("bot_type_edit").tag(true)
                        Text("bot_type_chat").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .fixedSize()
            .onChange(of: typingInPlace) { newValue in
                conversation.typingInPlace = newValue
            }
            Text(typingInPlace ? "tip_mode_description" : "chat_mode_description")
                .opacity(0.7)
            
            if !typingInPlace {
                autoAddText
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
