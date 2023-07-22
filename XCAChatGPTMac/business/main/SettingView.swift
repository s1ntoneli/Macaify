//
//  SettingView.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import SwiftUI
import KeyboardShortcuts

struct SettingView: View {
    // 返回按钮的操作
    var onBackButtonTap: () -> Void
    
    // openai-api-key
    @State private var apiKey: String = APIKeyManager.shared.getAPIKey()
    
    // 热键设置
    @State private var shortcut = KeyboardShortcutManager.shared.getShortcut()
    
    // 模型选择
    @State private var selectedModelIndex = ModelSelectionManager.shared.selectIndex
    
    @AppStorage("proxyAddress") private var proxyAddress = "https://openai.gokoding.com"
    @AppStorage("useProxy") private var useProxy = false
    @AppStorage("useVoice") private var useVoice = false
    @AppStorage("language") private var language = "en"
    @AppStorage("appShortcutOption") var appShortcutOption: String = "option"
    
    @FocusState private var focusField: FocusField?

    private enum FocusField {
        case title
        case shortcut
        case model
        case proxy
        case proxyUrl
        case useVoice
    }
    
    var body: some View {
        VStack {
            // 顶部导航栏
            ConfigurableView(onBack: { onBackButtonTap() }, title: "全局设置", showLeftButton: true) {}
            
            // 设置项
            if #available(macOS 13.0, *) {
                settingItems
            } else {
                settingItemsOld
            }
            
            Spacer()
            
            // 底部按钮
            HStack {
                Spacer()
                PlainButton(icon: "tray.full",label: "完成设置", shortcut: .init("s"), modifiers: .command, action: {
                    // 点击保存按钮
                    ModelSelectionManager.shared.setSelectedModelIndex(selectedModelIndex)
                    // 保存 openai-api-key 到 Keychain
                    APIKeyManager.shared.setAPIKey(apiKey)
                    onBackButtonTap()
                })
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(.white)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                focusField = .title
            }
        }
    }
    
    @available(macOS 13.0, *)
    var settingItems: some View {
        Form {
            Section("基础设置") {
                VStack {
                    AppShortcuts()
                    if appShortcutOption == "custom" {
                        KeyboardShortcuts.Recorder("", name: .quickAsk)
                            .transition(.opacity)
                    }
                }
            }
            
            Section("AI 设置") {
                ZStack(alignment: .trailing) {
                    TextField("输入API密钥", text: $apiKey)
                        .focused($focusField, equals: .title)
                        .textFieldStyle(.plain)
                    if apiKey.isEmpty {
                        Text("sk-xxxxxxxxxxxxxxxxxxxxx")
                            .opacity(0.4)
                    }
                }
                
                Picker(selection: $selectedModelIndex, label: Text("模型选择") ) {
                    ForEach(0..<ModelSelectionManager.shared.models.count) { index in
                        Text(ModelSelectionManager.shared.models[index].name)
                    }
                }
                
                Toggle("开启语音聊天", isOn: $useVoice)
                    .focusable()
                    .focused($focusField, equals: .useVoice)
            }
            
            Section("代理") {
                VStack {
                    Toggle("使用代理", isOn: $useProxy)
                        .focusable(true)
                        .focused($focusField, equals: .proxy)
                    
                    TextField("", text: $proxyAddress)
                        .disabled(!useProxy)
                        .focusable()
                        .focused($focusField, equals: .proxyUrl)
                }
            }
            
            Section("系统设置") {
                LanguageOptions()
            }
        }
        .listStyle(.bordered)
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background(.white)
    }
    
    var settingItemsOld: some View {
        List {
            MSection("基础设置") {
                AppShortcuts()
                    .buttonStyle(.borderless)
                
                if appShortcutOption == "custom" {
                    KeyboardShortcuts.Recorder("", name: .quickAsk)
                        .transition(.opacity)
                }
            }
            
            MSection("AI 设置") {
                Item("输入API密钥") {
                    ZStack(alignment: .trailing) {
                        TextField("", text: $apiKey)
                            .focused($focusField, equals: .title)
                            .multilineTextAlignment(.trailing)
                        if apiKey.isEmpty {
                            Text("sk-xxxxxxxxxxxxxxxxxxxxx")
                                .opacity(0.4)
                        }
                    }
                }
                
                Divider()
                    .opacity(0.3)

                Picker(selection: $selectedModelIndex, label: Text("模型选择") ) {
                    ForEach(0..<ModelSelectionManager.shared.models.count) { index in
                        Text(ModelSelectionManager.shared.models[index].name)
                    }
                }
                .buttonStyle(.borderless)
                .labelStyle(.automatic)

                Divider()
                    .opacity(0.3)

                Toggle("开启语音聊天", isOn: $useVoice)
                    .focusable()
                    .focused($focusField, equals: .useVoice)
                    .toggleStyle(.switch)
                    .controlSize(.mini)
            }

            MSection("代理") {
                Toggle("使用代理", isOn: $useProxy)
                    .focusable(true)
                    .focused($focusField, equals: .proxy)
                    .toggleStyle(.switch)
                    .controlSize(.mini)
                
                Divider()
                    .opacity(0.3)

                Item("") {
                    TextField("", text: $proxyAddress)
                        .disabled(!useProxy)
                        .focusable()
                        .multilineTextAlignment(.trailing)
                        .focused($focusField, equals: .proxyUrl)
                }
            }
            
            MSection("系统设置") {
                LanguageOptions()
                    .buttonStyle(.borderless)
            }
        }
        .listStyle(.plain)
        .background(.white)
        .padding()
    }
}

extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear //<<here clear
            drawsBackground = true
        }
    }
}
