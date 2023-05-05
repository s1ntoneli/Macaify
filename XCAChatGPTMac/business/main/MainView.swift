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

    @EnvironmentObject var convViewModel: ConversationViewModel

    @EnvironmentObject var pathManager: PathManager
    // 搜索关键字
    @State private var searchText = ""
    @State private var showSettings = false
    // 添加 AddCommandView 的显示状态变量
    @State private var isAddCommandViewPresented = false
    @FocusState private var focus:FocusedField?
    @State private var changedByKeyboard = false
    @State private var animating = false
    
    var selectedItemIndex: Int {
        get {
            convViewModel.selectedItemIndex
        }
    }
    
    init() {
//        commandStore.$selectedItemIndex
//            .sink { newValue in
//
//            }
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
                TextField("写下你的问题 Tab", text: $searchText)
                    .disabled(!isEnabled)
                    .focusable()
                    .focused($focus, equals: .name)
                    .textFieldStyle(.plain)
                    .padding()
                    .font(.system(size: 20))
                    .foregroundColor(Color.text)
                    .onChange(of: searchText) { newValue in
                        MainViewModel.shared.searchText = newValue
                    }
                    .onSubmit {
                        print("onSubmit")
                        startChat(convViewModel.selectedCommandOrDefault, searchText)
                    }
            }
            .padding(.horizontal)

            Divider().background(Color.divider)
            
            if convViewModel.conversations.isEmpty {
                emptyView
            } else {
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
            changedByKeyboard = true
            convViewModel.selectedItemIndex = (selectedItemIndex - 1 + convViewModel.conversations.count) % convViewModel.conversations.count
            return true
        }
        .onKeyPressed(.downArrow) { event in
            print("downArrow")
            changedByKeyboard = true
            convViewModel.selectedItemIndex = (selectedItemIndex + 1 + convViewModel.conversations.count) % convViewModel.conversations.count
            return true
        }
        .onKeyPressed(.enter) { event in
            print("enter")
            if focus != .name {
                startChat(convViewModel.selectedCommandOrDefault, searchText)
                return true
            }
            return false
        }
    }
    
    var emptyView: some View {
        ZStack(alignment: .center) {
            Color.clear
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("⌘N").font(.title3).foregroundColor(.text)
                    Text("⌘按住").font(.title3).foregroundColor(.text)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("添加机器人").font(.title3).foregroundColor(.text)
                    Text("显示快捷提示").font(.title3).foregroundColor(.text)
                }
            }
        }
    }
    
    var commands: some View {
        // 列表
        ScrollViewReader { proxy in
            List {
                Text("常用操作")
                    .padding(.bottom, 6)
                    .foregroundColor(.text)
                    .bold()
                    .font(.headline)
                ForEach(convViewModel.conversations) { command in
                    makeCommandItem(command, selected: convViewModel.conversations[selectedItemIndex].id == command.id)
                        .onTapGesture {
                            pathManager.toChat(command, msg: searchText)
                        }
                        .onHover(perform: { hovered in
                            if (hovered && !animating) {
                                changedByKeyboard = false
                                convViewModel.selectedItemIndex = (convViewModel.conversations.firstIndex(of: command) ?? 0)
                            }
                        })
                        .id(command.id)
                }
                .onDelete(perform: convViewModel.removeCommand)
                .onChange(of: convViewModel.selectedItemIndex) { newValue in
                    print("selectedItem changed newValue \(newValue)")
                    if changedByKeyboard {
                        withAnimation {
                            animating = true
                            print("animating")
                            proxy.scrollTo(convViewModel.conversations[selectedItemIndex].id, anchor: .bottom)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                animating = false
                                print("end of animating")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 0)
            .padding(.vertical, 8)
        }
    }
    
    var details: some View {
        ZStack {
            if (convViewModel.conversations.indices.contains(selectedItemIndex)) {
                ZStack {
//                    ForEach(commandStore.commands) {command in
                        CommandDetailView(command: $convViewModel.conversations[selectedItemIndex])
                        //                    .keyboardShortcut(.init("e"), modifiers: .command)
                            .id(convViewModel.conversations[selectedItemIndex].id)
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
            HStack(alignment: .center) {
                Text("反馈")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .onTapGesture {
                        if let url = URL(string: "mailto:antiless.dev@gmail.com") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                Text("Twitter")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .onTapGesture {
                        if let url = URL(string: "https://twitter.com/s1ntone") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                Text("Weibo")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .onTapGesture {
                        if let url = URL(string: "https://weibo.com/u/2293237681") {
                            NSWorkspace.shared.open(url)
                        }
                    }
            }
            Spacer()
            HStack {
                PlainButton(icon: "gear", label: "全局设置", shortcut: .init("p"), modifiers: .command) {
                    // 点击设置按钮
                    pathManager.to(target: .setting)
                }
                PlainButton(icon: "sparkles.rectangle.stack", label: "机器人广场", shortcut: .init("l"), modifiers: .command) {
                    // 点击添加指令按钮
                    pathManager.to(target: .playground)
                }
                PlainButton(icon: "square.stack.3d.up.badge.a", label: "添加机器人", shortcut: .init("n"), modifiers: .command) {
                    // 点击添加指令按钮
                    pathManager.to(target: .addCommand)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    func makeCommandItem(_ command: GPTConversation, selected: Bool) -> some View {
        return ZStack {
            Color.clear
            HStack(alignment: .center) {
                Group {
                    ConversationIconView(conversation: command, size: 24).id(command.icon)
                }

                HStack(alignment: .center, spacing: 8) {
                    Text(command.name)
                        .font(.title2)
                        .foregroundColor(Color.hex(0x37414F))
                    Spacer()
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
    
    func startChat(_ command: GPTConversation,_ searchText: String) {
        pathManager.toChat(command, msg: searchText)
        self.searchText.removeAll()
    }
}

// 列表项数据模型
//struct GPTConversation: Identifiable, Hashable, Codable {
//    var id = UUID()
//    let name: String
//    let icon: String
//    let protmp: String
//    let shortcut: String
//    let autoAddSelectedText: Bool
//}

enum FocusedField:Hashable{
    case name
}
