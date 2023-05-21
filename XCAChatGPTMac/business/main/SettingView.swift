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
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .background(.white)

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
        .navigationBarBackButtonHidden(true)
        .background(.white)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                focusField = .title
            }
        }
    }
}
//
//// 键盘快捷键设置视图
//struct KeyboardShortcutView: View {
//    @Binding var shortcut: KeyboardShortcut
//
//    var body: some View {
//        HStack {
//            Text("打开 QuickType")
//                .font(.subheadline)
//            KeyboardShortcutInputView(shortcut: $shortcut)
//        }
//    }
//}
//
//// 键盘快捷键输入视图
//struct KeyboardShortcutInputView: View {
//    @Binding var shortcut: KeyboardShortcut
//
//    var body: some View {
//        HStack {
//            Text(shortcut.description)
//                .foregroundColor(.secondary)
//            Button(action: {
//                // 重置快捷键
//                shortcut = KeyboardShortcut()
//            }) {
//                Text("重置")
//                    .font(.subheadline)
//                    .foregroundColor(.red)
//            }
//        }
//        .background(Color.primary.colorInvert())
//        .cornerRadius(5)
//        .padding(.horizontal, 10)
//        .onReceive(NotificationCenter.default.publisher(for: NSMenuItem.keyEquivalentModifierMaskChangedNotification)) { _ in
//            // 更新快捷键
//            shortcut = KeyboardShortcutManager.shared.getShortcut()
//        }
//    }
//}
//
//struct SettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingView()
//    }
//}
