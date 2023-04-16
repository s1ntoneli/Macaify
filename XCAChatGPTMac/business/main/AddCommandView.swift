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
    var isNew: Bool {
        get {
            !commandStore.commands.contains(where: { $0.id == id })
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ConfigurableView(onBack: { pathManager.back() }, title: isNew ? "添加指令" : "编辑指令", showLeftButton: true) {
                if !isNew {
                    PlainButton(icon: "trash", shortcut: .init("d"), modifiers: .command) {
                        // 删除按钮的响应
                        commandStore.removeCommand(by: id)
                        pathManager.toMain()
                    }
                }
            }


            List {
                VStack(alignment: .leading) {
                    Text("指令名字").font(.headline)
                    TextField("eg: SwiftUI 大师", text: $commandName)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                VStack(alignment: .leading) {
                    Text("系统提示").font(.headline)
                    TextField("请填写系统提示", text: $prompt)
                        .textFieldStyle(CustomTextFieldStyle())
                        .lineLimit(4)
                        .frame(height: 40)
                }
                .padding(.top, 12)
                VStack(alignment: .leading) {
                    Text("热键").font(.headline)
                    Form {
                        KeyboardShortcuts.Recorder("", name: KeyboardShortcuts.Name(id.uuidString))
                    }
                }
                .padding(.top, 12)
                VStack(alignment: .leading) {
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

            .foregroundColor(Color(.systemGray))
            .font(.body)
    }
}
