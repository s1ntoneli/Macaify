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

    @EnvironmentObject var commandStore: CommandStore
    
    @EnvironmentObject var pathManager: PathManager
    // 搜索关键字
    @State private var searchText = ""
    @State private var showSettings = false
    // 添加 AddCommandView 的显示状态变量
    @State private var isAddCommandViewPresented = false
    @FocusState var focus:FocusedField?

    // 选中的列表项下标
    @State private var selectedItemIndex = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // 搜索框
            HStack(alignment: .center, spacing: 0) {
                Spacer(minLength: 6)
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .foregroundColor(Color.text)
                    .frame(width: 20, height: 20)
                TextField("写下你的问题", text: $searchText, onCommit: {
                    if(!searchText.isEmpty) {
                        startChat(commandStore.commands[selectedItemIndex], searchText)
                    }
                })
//                .focused($focus, equals: .name)
                .focused(commandStore.$focus, equals: .name)
                .textFieldStyle(.plain)
                .padding()
                .font(.system(size: 20))
                .foregroundColor(Color.text)
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
//            KeyboardShortcuts.onKeyUp(for: KeyboardShortcuts.Name("upArrow", default: .init(.upArrow) )) {
//                print("up")
//                selectedItemIndex = (selectedItemIndex - 1 + commandStore.commands.count) % commandStore.commands.count
//            }
//            KeyboardShortcuts.onKeyUp(for: KeyboardShortcuts.Name("downArrow", default: .init(.downArrow) )) {
//                print("down")
//                selectedItemIndex = (selectedItemIndex + 1) % commandStore.commands.count
//            }
//            KeyboardShortcuts.onKeyUp(for: KeyboardShortcuts.Name("edit", default: .init(.e, modifiers: [.command]) )) {
//                pathManager.to(target: .editCommand(command: commandStore.commands[selectedItemIndex]))
//            }
        }
        .onChange(of: scenePhase) { s in
            switch s {
            case .background:
                print("background")

            case .inactive:
                print("mainView inactive")
            case .active:
                print("mainView active")
                
            @unknown default:
                print("default")
            }
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
            ForEach(0..<commandStore.commands.count) { index in
                let command = commandStore.commands[index]
                makeCommandItem(command, selected: index == selectedItemIndex)
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
        CommandDetailView(command: commandStore.commands[selectedItemIndex])
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
                Button(action: {
                    // 点击设置按钮
                    //                            self.showSettings = true
                    pathManager.to(target: .setting)
                }) {
                    Image(systemName: "gear")
                }
                Button(action: {
                    // 点击添加指令按钮
                    pathManager.to(target: .addCommand)
                }) {
                    Image(systemName: "plus.circle")
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
                VStack(alignment: .leading, spacing: 4) {
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
        self.searchText = ""
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
