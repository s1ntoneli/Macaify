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
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var commandStore: CommandStore
    @State var id: UUID = UUID()
    @State var commandName = ""
    @State var prompt = ""
    @State var shortcut = ""
    @State var autoAddSelectedText = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.blue)
                }
                Spacer()
                Text("添加指令")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    // 删除按钮的响应
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            .padding()
//            .background(Color(.secondarySystemBackground))
            
            // 中间设置项
            Form {
                Section(header: Text("指令名称")) {
                    TextField("eg: SwiftUI Master", text: $commandName)
                }
                Section(header: Text("系统提示")) {
                    TextField("请填写系统提示", text: $prompt)
                }
                Section(header: Text("热键")) {
                    Form {
                        KeyboardShortcuts.Recorder("", name: KeyboardShortcuts.Name(id.uuidString))
                    }
                }
                Section(header: Text("自动添加选中文本")) {
                    Toggle(isOn: $autoAddSelectedText) {
                        Text("启用")
                    }
                }
            }
            Color.clear

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
                Button("保存") {
                    // 保存按钮的响应
                    commandStore.addCommand(id: id, title: commandName, prompt: prompt, shortcut: shortcut, autoAddSelectedText: autoAddSelectedText)
                }
                .frame(width: 80)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(5)
            }
            .padding()
//            .background(Color(.secondarySystemBackground))
        }
        .navigationBarBackButtonHidden(true)
    }
}
