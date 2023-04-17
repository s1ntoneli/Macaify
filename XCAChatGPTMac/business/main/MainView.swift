//
//  MainView.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import Foundation
import SwiftUI
import KeyboardShortcuts

struct MainView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.isEnabled) private var isEnabled: Bool

    @EnvironmentObject var commandStore: CommandStore

    @EnvironmentObject var pathManager: PathManager
    // 搜索关键字
    @State private var searchText = ""
    @State private var showSettings = false
    // 添加 AddCommandView 的显示状态变量
    @State private var isAddCommandViewPresented = false
    @FocusState var focus:FocusedField?
    
    var selectedItemIndex: Int {
        get {
            commandStore.selectedItemIndex
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 搜索框
            HStack(alignment: .center, spacing: 0) {
                Spacer(minLength: 6)
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .foregroundColor(Color.text)
                    .frame(width: 20, height: 20)
                TextField("写下你的问题", text: $searchText)
                    .disabled(!isEnabled)
                    .focusable()
                    .textFieldStyle(.plain)
                    .padding()
                    .font(.system(size: 20))
                    .foregroundColor(Color.text)
                    .onChange(of: searchText) { newValue in
                        MainViewModel.shared.searchText = newValue
                    }
            }
            .padding(.horizontal)
            Divider().background(Color.divider)
            
            HStack(spacing: 0) {
                GeometryReader { reader in
                    HStack(spacing: 0) {
                        commands
                            .frame(width: reader.size.width * 0.7)
                        
                        Divider()
                            .background(Color.divider)
                        
                        details
                            .frame(width: reader.size.width * 0.3)
                    }
                }
            }
            
            // 底部信息栏
            bottomBar
        }
        .background(.white)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                print("onAppear")
                focus = .name
            }
        }
        .onKeyPressed(.upArrow) { event in
            print("upArrow")
            commandStore.selectedItemIndex = (selectedItemIndex - 1 + commandStore.commands.count) % commandStore.commands.count
            return true
        }
        .onKeyPressed(.downArrow) { event in
            print("downArrow")
            commandStore.selectedItemIndex = (selectedItemIndex + 1 + commandStore.commands.count) % commandStore.commands.count
            return true
        }
        .onKeyPressed(.enter) { event in
            print("enter")
            startChat(commandStore.commands[selectedItemIndex], searchText)
            return true
        }
    }
    
    var commands: some View {
        // 列表
        List {
            Text("常用操作")
                .padding(.bottom, 6)
                .foregroundColor(.text)
                .bold()
                .font(.headline)
            ForEach(commandStore.commands) { command in
                makeCommandItem(command, selected: commandStore.commands[selectedItemIndex].id == command.id)
                    .onTapGesture {
                        pathManager.toChat(command, msg: searchText)
                    }
            }
            .onDelete(perform: commandStore.removeCommand)
        }
        .padding(.horizontal, 0)
        .padding(.vertical, 8)
    }
    
    var details: some View {
        ZStack {
            if (commandStore.commands.indices.contains(selectedItemIndex)) {
                ZStack {
//                    ForEach(commandStore.commands) {command in
                        CommandDetailView(command: $commandStore.commands[selectedItemIndex])
                        //                    .keyboardShortcut(.init("e"), modifiers: .command)
                            .id(commandStore.commands[selectedItemIndex].id)
//                    }
                }
//                    .onKeyboardShortcut(.init("edit", default: .init(.e, modifiers: .command)), perform: { type in
//                        if (type == .keyDown) {
//                            pathManager.to(target: .editCommand(command: commandStore.commands[selectedItemIndex]))
//                        }
//                    })
            }
        }
    }
    
    var bottomBar: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("应用程序名称")
                    .font(.footnote)
                    .foregroundColor(.gray)
                Text("版本")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            Spacer()
            HStack {
                PlainButton(icon: "gear", label: "全局设置 ⌘P", shortcut: .init("p"), modifiers: .command) {
                    // 点击设置按钮
                    pathManager.to(target: .setting)
                }
                PlainButton(icon: "plus.circle", label: "添加指令 ⌘N", shortcut: .init("n"), modifiers: .command) {
                    // 点击添加指令按钮
                    pathManager.to(target: .addCommand)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    func makeCommandItem(_ command: Command, selected: Bool) -> some View {
        return ZStack {
            Color.clear
            HStack(alignment: .center) {
                Image(systemName: "lightbulb")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 24)
                    .foregroundColor(Color.hex(0xFFB717))
                HStack(alignment: .center, spacing: 8) {
                    Text(command.name)
                        .font(.title2)
                        .foregroundColor(Color.hex(0x37414F))
                    Text(KeyboardShortcuts.getShortcut(for: KeyboardShortcuts.Name(command.id.uuidString))?.description ?? "")
                        .font(.body)
                        .foregroundColor(Color.hex(0x37414F).opacity(0.5))
                }
                .padding(.leading)
                Spacer()
            }
            .padding(.leading, 8)
        }
        .padding(12)
        .background(selected ? Color.hex(0xF9FAFC) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    func startChat(_ command: Command,_ searchText: String) {
        pathManager.toChat(command, msg: searchText)
        self.searchText.removeAll()
    }
}

// 列表项数据模型
struct Command: Identifiable, Hashable, Codable {
    var id = UUID()
    let name: String
    let icon: String
    let protmp: String
    let shortcut: String
    let autoAddSelectedText: Bool
}

enum FocusedField:Hashable{
    case name
}
