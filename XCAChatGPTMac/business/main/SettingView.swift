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
    @AppStorage("appShortcutOption") var appShortcutOption: String = "custom"
    
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
            List {
                VStack(alignment: .leading, spacing: 12) {
                    Text("API-Key").font(.headline)
                    TextField("输入API密钥", text: $apiKey, onCommit: {
                        print("onCommit")
                        focusField = .proxyUrl
                    })
                    .textFieldStyle(CustomTextFieldStyle())
                    .focusable(true)
                    .focused($focusField, equals: .title)
                    .onSubmit {
                        print("onSubmit")
                        focusField = .proxyUrl
                    }
                    
                    VStack(alignment: .leading) {
                        Text("全局唤醒热键").font(.headline)
                        Form {
                            HStack {
                                AppShortcuts()
                                if appShortcutOption == "custom" {
                                    KeyboardShortcuts.Recorder("", name: .quickAsk)
                                }
                            }
                        }
                    }
                    
                    Group {
                        Text("模型选择").font(.headline)
                        Picker(selection: $selectedModelIndex, label: Text("") ) {
                            ForEach(0..<ModelSelectionManager.shared.models.count) { index in
                                Text(ModelSelectionManager.shared.models[index].name)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: 200)
                    }
                    Text("使用代理")
                        .font(.headline)
                    Toggle("启用", isOn: $useProxy)
                        .focusable(true)
                        .focused($focusField, equals: .proxy)
                    
                    TextField("Proxy address", text: $proxyAddress)
                        .disabled(!useProxy)
                        .textFieldStyle(CustomTextFieldStyle())
                        .focusable()
                        .focused($focusField, equals: .proxyUrl)
                    
                    Group {
                        Text("开启语音聊天")
                            .font(.headline)
                        Toggle("启用", isOn: $useVoice)
                            .focusable()
                            .focused($focusField, equals: .useVoice)
                    }
                    
                    Group {
                        Text("语言设置")
                            .font(.headline)
                        Form {
                            LanguageOptions()
                                .frame(maxWidth: 120)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
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
