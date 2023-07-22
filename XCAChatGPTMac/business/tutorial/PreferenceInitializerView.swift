//
//  PreferenceInitializerView.swift
//  Found
//
//  Created by lixindong on 2023/5/19.
//

import SwiftUI
import KeyboardShortcuts

struct PreferenceInitializerView: View {
    @Environment(\.presentationMode) var presentationMode

    @AppStorage("showPreferenceInitializer_1") var showPreferenceInitializer: Bool = true

    // openai-api-key
    @AppStorage("selectedLanguage") var language: String = "en"
    @AppStorage("apiKey") var apiKey: String = ""
    @FocusState private var focused: Bool
    @State private var name = ""
    @State private var age = 0
    @State private var isMarried = false
    @AppStorage("appShortcutOption") var appShortcutOption: String = "option"

    var body: some View {
        VStack {
            Text("初始设置")
                .font(.largeTitle)
                .bold()
                .padding(.top, 20)
                .padding(.bottom, 20)

            Spacer()
            List {
                MSection("完成设置以开始使用") {
                    lang
                        .buttonStyle(.borderless)

                    Divider()
                        .opacity(0.3)
                    VStack {
                        AppShortcuts()
                            .buttonStyle(.borderless)
                        if appShortcutOption == "custom" {
                            KeyboardShortcuts.Recorder("", name: .quickAsk)
                                .disabled(appShortcutOption != "custom")
                        }
                    }
                    Divider()
                        .opacity(0.3)

                    Item("输入 API 密钥") {
                        TextField("sk-xxxxxxxxxxxxxxxxxxxxx", text: $apiKey)
                            .textFieldStyle(.plain)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            submit
        }
        .frame(width: 450, height: 420)
        .padding(20)
        .onAppear {
            focused = true
        }
    }
    
    var lang: some View {
        LanguageOptions()
    }
    
    var submit: some View {
        PlainButton(label: "完成设置", width: 300, height: 40, backgroundColor: .blue.opacity(0.9), pressedBackgroundColor: .blue, foregroundColor: .white, cornerRadius: 8, shortcut: .init("s"), modifiers: .command, action: {
            showPreferenceInitializer = false
            initializeIfNeeded(language)
            self.presentationMode.wrappedValue.dismiss()
        })
    }
}



struct PreferenceInitializerView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceInitializerView()
    }
}
