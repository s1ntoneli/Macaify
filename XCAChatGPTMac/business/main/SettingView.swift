//
//  SettingView.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import SwiftUI
import KeyboardShortcuts
import Defaults

struct SettingView: View {
    // 返回按钮的操作
    var onBackButtonTap: () -> Void
    
    // openai-api-key
    @State private var apiKey: String = APIKeyManager.shared.getAPIKey()
    
    // 热键设置
    @State private var shortcut = KeyboardShortcutManager.shared.getShortcut()
    
    @AppStorage("proxyAddress") private var proxyAddress = "https://openai.gokoding.com"
    @AppStorage("useProxy") private var useProxy = false
    @AppStorage("useVoice") private var useVoice = false
    @AppStorage("language") private var language = "en"
    @AppStorage("appShortcutOption") var appShortcutOption: String = "option"
    
    @Default(.selectedModelId)
    var selectedModelId: String
    
    @Default(.selectedProvider)
    var selectedProvider: String
    
    @Default(.maxToken)
    var maxToken: Int
    
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
                TextField("输入API密钥", text: $apiKey)
                    .focused($focusField, equals: .title)
                
                LabeledContent("选择模型") {
                    HStack(alignment: .center) {
                        Menu {
                            ForEach(LLMModelsManager.shared.modelCategories, id: \.name) { category in
                                Section(category.name) {
                                    ForEach(category.models, id: \.id) { model in
                                        Button {
                                            selectedModelId = model.id
                                            selectedProvider = category.provider
                                            maxToken = model.contextLength
                                        } label: {
                                            Text(model.name)
                                        }
                                    }
                                }
                            }
                        } label: {
                            TextField("", text: $selectedModelId)
                                .fixedSize(horizontal: true, vertical: true)
                                .frame(minWidth: 100, alignment: .trailing)
                                .offset(x: 0, y: -2)
                            Image(systemName: "chevron.down")
                                .controlSize(.mini)
                                .foregroundStyle(.primary)
                                .bold()
                                .background {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(.regularMaterial)
                                        .frame(width: 16, height: 16)
                                }
                        }
                        .buttonStyle(.plain)
                        .fixedSize(horizontal: true, vertical: false)
                    }
                }
               LabeledContent("接口格式") {
                    HStack(alignment: .center) {
                        Menu {
                            ForEach(LLMModelsManager.shared.providers, id: \.self) { provider in
                                Button {
                                    selectedProvider = provider
                                } label: {
                                    Text(provider)
                                }
                            }
                        } label: {
                            TextField("", text: $selectedProvider)
                                .fixedSize(horizontal: true, vertical: true)
                                .offset(x: 0, y: -2)
                            Image(systemName: "chevron.down")
                                .controlSize(.mini)
                                .foregroundStyle(.primary)
                                .bold()
                                .background {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(.regularMaterial)
                                        .frame(width: 16, height: 16)
                                }
                        }
                        .buttonStyle(.plain)
                        .fixedSize(horizontal: true, vertical: false)
                    }
                }
                TextField("max_token", value: $maxToken, formatter: NumberFormatter())

                TextField("Base URL", text: $proxyAddress)
                    .focusable()
                    .focused($focusField, equals: .proxyUrl)
            }
            
            Section {
                Toggle("开启语音聊天", isOn: $useVoice)
                    .focusable()
                    .focused($focusField, equals: .useVoice)
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

                Picker(selection: $selectedModelId, label: Text("模型选择")) {
                    ForEach(LLMModelsManager.shared.modelCategories, id: \.name) { category in
                        Section(category.name) {
                            ForEach(category.models, id: \.id) { model in
                                Text(model.name)
                            }
                        }
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
