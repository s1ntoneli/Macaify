//
//  MainView.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import Foundation
import SwiftUI
import KeyboardShortcuts
import Defaults

struct MainView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.hoveredColor) private var hoveredColor: Color

    @EnvironmentObject var convViewModel: ConversationViewModel

    @EnvironmentObject var pathManager: PathManager
    // 搜索关键字
    @State private var searchText = ""
    @State private var showSettings = false
    // 添加 AddCommandView 的显示状态变量
    @State private var isAddCommandViewPresented = false
    @FocusState private var focus:FocusedField?
    @State private var indexChangedSource: IndexChangeEvent = .none
    
    @Default(.collapsed)
    private var collapsed: Bool
    
    @State
    private var shouldCollapsedCommands: Bool = false
    
    private var currentChat: GPTConversation? {
        get {
            convViewModel.currentChat
        }
        set {
            convViewModel.currentChat = newValue
        }
    }
    
    var selectedItemIndex: Int {
        get {
            convViewModel.selectedItemIndex
        }
    }

    var body: some View {
        Group {
            if convViewModel.conversations.isEmpty {
                emptyView
            } else {
                GeometryReader { reader in
                    HStack(spacing: 0) {
                        commands
                            .if(!shouldCollapsedCommands, {
                                $0.frame(width: currentChat == nil ? reader.size.width * 1 : reader.size.width * 0.3)
                            })
                        if let currentChat {
                            Divider()
                                .shadow(color: .gray.opacity(0.05), radius: 10, x: -5, y: 0)
                                .shadow(color: .gray.opacity(0.05), radius: 10, x: 5, y: 0)
                            makeChatView(currentChat, msg: nil)
                        }
                    }
                }
            }
        }
        .onChange(of: convViewModel.currentChat, { oldValue, newValue in
            withAnimation {
                shouldCollapsedCommands = collapsed && newValue != nil
            }
        })
        .onChange(of: collapsed, { oldValue, newValue in
            withAnimation {
                shouldCollapsedCommands = newValue && convViewModel.currentChat != nil
            }
        })
        .background(.white.opacity(0.95))
        .background(.gray)
        .safeAreaInset(edge: .top, alignment: .center, spacing: 0) {
            // 搜索框
            if currentChat == nil {
                VStack(spacing: 0) {
                    searchBar
                    Divider().background(Color.divider)
                }
                .background(.white.opacity(0.8))
                .background(.regularMaterial)
//                .shadow(color: .gray.opacity(0.05), radius: 20)
            }
        }
        .safeAreaInset(edge: .bottom) {
            // 底部信息栏
            if currentChat == nil {
                VStack(spacing: 0) {
                    Divider()
                        .opacity(0.5)
                    bottomBar
                }
                .background(.white.opacity(0.7))
                .background(.regularMaterial)
                .shadow(color: .gray.opacity(0.05), radius: 20, y: -10)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                print("onAppear")
                self.focus = .name
            }
        }
        .onKeyPressed(.upArrow) { event in
            print("upArrow")
            indexChangedSource = .upArrow
            if convViewModel.selectedItemIndex == -1 {
                convViewModel.selectedItemIndex = convViewModel.conversations.count - 1
            } else {
                convViewModel.selectedItemIndex = (selectedItemIndex - 1 + convViewModel.conversations.count) % convViewModel.conversations.count
            }
            return true
        }
        .onKeyPressed(.downArrow) { event in
            print("downArrow")
            indexChangedSource = .downArrow
            convViewModel.selectedItemIndex = (selectedItemIndex + 1 + convViewModel.conversations.count) % convViewModel.conversations.count
            return true
        }
        .onKeyPressed(.escape) { event in
            print("escape")
            if convViewModel.selectedItemIndex != -1 {
                indexChangedSource = .escape
                convViewModel.selectedItemIndex = -1
                return true
            } else {
                MainWindowController.shared.closeWindow()
                return false
            }
        }
        .onKeyPressed(.enter) { event in
            print("enter")
            if currentChat == nil {
                withAnimation {
                    convViewModel.currentChat = convViewModel.selectedCommandOrDefault
                }
                return true
            }
            return false
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("toMain"))) { notification in
            DispatchQueue.main.async {
                focus = .name
            }
        }
    }

    var placeholder: String {
        convViewModel.selectedCommandOrDefault.name
    }
    
    var emptyView: some View {
        ZStack(alignment: .center) {
            Color.clear
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("⌘N").font(.body).foregroundColor(.text)
                    Text("cmd_press_and_hold").font(.body).foregroundColor(.text)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("添加机器人").font(.body).foregroundColor(.text)
                    Text("display_shortcut_tips").font(.body).foregroundColor(.text)
                }
            }
        }
    }
    
    var rightTips: some View {
        HStack {
            Text("enter")
                .padding(4)
                .background(Color.gray.opacity(0.1).cornerRadius(4))
            Text("ask")

            Text("up_down_arrows")
                .padding(4)
                .background(Color.gray.opacity(0.1).cornerRadius(4))
            Text("select")

            Text("esc")
                .padding(4)
                .background(Color.gray.opacity(0.1).cornerRadius(4))
            Text("cancel_selection")
        }
        .foregroundColor(.gray)
    }
    
    var commands: some View {
        // 列表
        ScrollViewReader { reader in
            ScrollView {
                LazyVStack(alignment: .leading) {
                    Text("bots")
                        .padding(.bottom, 6)
                        .foregroundColor(.text)
                        .font(.headline)
                    ForEach(convViewModel.conversations) { command in
                        makeCommandItem(command, selected: convViewModel.hoveredCommand == command)
                            .if(shouldCollapsedCommands, { $0.help(command.name) })
                            .contentShape(.rect)
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    convViewModel.currentChat = command
                                }
                            }
                            .id(command.id)
                            .listRowSeparator(visibility: .hidden)
                    }
                    .onDelete(perform: convViewModel.removeCommand)
                    .contentMargins(0)
                    .onChange(of: convViewModel.selectedCommand) { newValue in
                        print("selectedItem changed newValue \(newValue)")
                        if [.upArrow, .downArrow].contains(indexChangedSource), let newValue {
                            withAnimation {
                                reader.scrollTo(newValue.id, anchor: .bottom)
                            }
                        }
                    }
                }
                .if(shouldCollapsedCommands, { $0.fixedSize() })
                .padding(.vertical, 8)
            }
            .scrollIndicators(.never)
            .contentMargins(0)
            .padding(.horizontal)
            .safeAreaInset(edge: .bottom, alignment: .trailing) {
                if currentChat != nil {
                    HStack {
                        Button {
                            withAnimation(.easeInOut) {
                                self.collapsed.toggle()
                            }
                        } label: {
                            Image(systemName: collapsed ? "arrow.right.to.line" : "arrow.left.to.line")
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0.7))
                    .background(.regularMaterial)
                    .fixedSize()
                }
            }
        }
    }
    
    var details: some View {
        ZStack {
            let command = convViewModel.hoveredCommand ?? convViewModel.selectedCommandOrDefault
            CommandDetailView(command: command)
                .id(command.id)
        }
    }
    
    var searchBar: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer(minLength: 6)
            Image(systemName: "magnifyingglass")
                .resizable()
                .foregroundColor(Color.text)
                .frame(width: 20, height: 20)
            TextField(placeholder, text: $searchText)
                .disabled(!isEnabled)
                .focusable()
                .focused($focus, equals: .name)
                .textFieldStyle(.plain)
                .padding()
                .font(.system(size: 18))
                .foregroundColor(Color.text)
                .onChange(of: searchText) { newValue in
                    Task {
                        MainViewModel.shared.searchText = newValue
                    }
                }
                .onSubmit {
                    print("onSubmit")
                    startChat(convViewModel.selectedCommandOrDefault, searchText)
                }
                .task {
                    print("search is going to appear")
                    focus = .name
                }
            Spacer()
            rightTips
        }
        .padding(.horizontal)
    }
    
    var bottomBar: some View {
        HStack {
            HStack(alignment: .center) {
                Text("feedback")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .onTapGesture {
                        if let url = URL(string: "mailto:\(String.mail)") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                Text("twitter")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .onTapGesture {
                        if let url = URL(string: .twitter) {
                            NSWorkspace.shared.open(url)
                        }
                    }
                Text("weibo")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .onTapGesture {
                        if let url = URL(string: .weibo) {
                            NSWorkspace.shared.open(url)
                        }
                    }
            }
            Spacer()
            HStack {
                PlainButton(icon: "gear", label: "global_settings", backgroundColor: Color.gray.opacity(0.05), pressedBackgroundColor: .gray.opacity(0.1), shortcut: .init(","), modifiers: .command) {
                    // 点击设置按钮
                    pathManager.to(target: .setting)
                }
                PlainButton(icon: "sparkles.rectangle.stack", label: "bots_plaza", backgroundColor: Color.gray.opacity(0.05), pressedBackgroundColor: .gray.opacity(0.1), shortcut: .init("l"), modifiers: .command) {
                    // 点击添加指令按钮
                    pathManager.to(target: .playground)
                }
                PlainButton(icon: "square.stack.3d.up.badge.a", label: "create_bot", backgroundColor: Color.gray.opacity(0.05), pressedBackgroundColor: .gray.opacity(0.1), shortcut: .init("n"), modifiers: .command) {
                    // 点击添加指令按钮
                    pathManager.to(target: .addCommand)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 4)
    }
    
    func makeCommandItem(_ command: GPTConversation, selected: Bool) -> some View {
        CommandItem(state: commandsViewState)
            .environmentObject(command)
            .if(shouldCollapsedCommands, { $0.padding(.horizontal, 4) }, else: { $0.padding(.horizontal, currentChat != nil ? 8 : 12) })
            .padding(.vertical, 8)
            .hoveredEffect()
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(selected ? hoveredColor : .clear)
            )
    }
    
    var commandsViewState: CommandItem.ViewState {
        if currentChat == nil {
            return .normal
        }
        if collapsed {
            return .collapsed
        }
        return .simple
    }
    
    func startChat(_ command: GPTConversation,_ searchText: String) {
        pathManager.toChat(command, msg: searchText)
        self.searchText.removeAll()
    }
    
    func makeChatView(_ command: GPTConversation, msg: String?, mode: ChatMode = .normal) -> some View {
        return ChatView(command: command, msg: msg, mode: mode) {
            if case .main(_) = pathManager.top {
                withAnimation {
                    convViewModel.currentChat = nil
                }
            }
        }
        .id(command.id)
        .frame(maxWidth: .infinity)
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

enum IndexChangeEvent {
    case upArrow
    case downArrow
    case escape
    case hover
    case none
}

struct CommandItem: View {
    let state: ViewState
    @EnvironmentObject var command: GPTConversation
    
    var body: some View {
        HStack(alignment: .center) {
            Group {
                ConversationIconView(conversation: command, size: 16).id(command.icon)
            }

            if state != .collapsed {
                HStack(alignment: .center, spacing: 8) {
                    Text(command.name)
                        .foregroundColor(Color.hex(0x37414F))
                        .lineLimit(1)
                    if state == .normal && command.typingInPlace {
                        Text("tip")
                            .font(.footnote)
                            .foregroundColor(.white)
                            .padding(2)
                            .background(Color.purple.cornerRadius(4))
                            .help("tip_mode_description")
                    }
                    
                    Spacer()
                    if state == .normal {
                        Text(KeyboardShortcuts.getShortcut(for: KeyboardShortcuts.Name(command.id.uuidString))?.description ?? "")
                            .font(.body)
                            .foregroundColor(Color.hex(0x37414F).opacity(0.5))
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    enum ViewState {
        case normal
        case simple
        case collapsed
    }
}
