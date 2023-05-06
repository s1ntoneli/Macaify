//
//  ContentView.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import SwiftUI
import AVKit
import Combine

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var vm: ViewModel
    @FocusState var isTextFieldFocused: Bool
    @State var scrolledByUser = false

    var body: some View {
        ZStack {
            chatListView
        }
    }

    var emptyView: some View {
        ZStack(alignment: .center) {
            Color.clear
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("⌘R").font(.title3).foregroundColor(.text)
                    Text("⌘N").font(.title3).foregroundColor(.text)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("清除聊天记录").font(.title3).foregroundColor(.text)
                    Text("清除上下文，开始新聊天").font(.title3).foregroundColor(.text)
                }
            }
        }
    }
    
    var chatListView: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                if vm.messages.isEmpty {
                    emptyView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(0..<vm.messages.count, id: \.self) { index in
                                let message = vm.messages[index]
                                MessageRowView(message: message, tag: "\(vm.messages.count - index)") { message in
                                    Task { @MainActor in
                                        await vm.retry(message: message)
                                    }
                                }.id(message.id)
                            }
                        }
                        .onTapGesture {
                            isTextFieldFocused = false
                        }
                    }
                }
//                .background(GeometryReader {
//                                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: $0.frame(in: .global).minY)
//                })
#if os(iOS) || os(macOS)
                Divider()
                bottomView(image: "profile", proxy: proxy)
                Spacer()
#endif
            }
            .onChange(of: vm.messages.last?.responseText) { _ in
                if (!scrolledByUser) {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: vm.messages.last?.clearContextAfterThis) { _ in
                scrollToBottom(proxy: proxy)
            }
            .onAppear {
                scrollToBottom(proxy: proxy)
                trackScrollWheel()
            }
        }
        .background(colorScheme == .light ? .white : Color(red: 52/255, green: 53/255, blue: 65/255, opacity: 0.5))
    }
    
    
    func trackScrollWheel() {
        NSApplication.shared.publisher(for: \.currentEvent)
            .filter { event in event?.type == .scrollWheel }
            .throttle(for: .milliseconds(200),
                      scheduler: DispatchQueue.main,
                      latest: true)
            .sink { [weak vm] event in
                print("event.deltaY \(event?.deltaY)")
                if let deltaY = event?.deltaY, deltaY > 0 {
                    scrolledByUser = true
                }
            }
            .store(in: &subs)
    }

    @State var subs = Set<AnyCancellable>() // Cancel onDisappear

    func bottomView(image: String, proxy: ScrollViewProxy) -> some View {
        HStack(alignment: .center, spacing: 8) {
            PlainButton(icon: "clear", shortcut: .init("r"), modifiers: .command, showHelp: false) {
                vm.clearMessages()
            }
            .help("清除聊天记录 ⌘R")
            PlainButton(icon: "lasso.sparkles", shortcut: .init("n"), modifiers: .command, showHelp: false) {
                vm.clearContext()
            }
            .help("新聊天 ⌘N")

            InputEditor(placeholder: "按 Tab 聚焦", text: $vm.inputMessage, onShiftEnter: {
                Task { @MainActor in
                    if !vm.inputMessage.isEmpty {
                        isTextFieldFocused = false
                        scrolledByUser = false
                        scrollToBottom(proxy: proxy)
                        await vm.sendTapped()
                    }
                }
            })
//            TextEditor(text: $vm.inputMessage)
//                .lineLimit(1)
            .frame(maxHeight: CGFloat(vm.inputMessage.lineCount) * 20)
            .animation(.easeInOut)
//                .frame(minHeight: 20)
#if os(iOS) || os(macOS)
            .textFieldStyle(.roundedBorder)
#endif
            .focused($isTextFieldFocused)
            .disabled(vm.isInteractingWithChatGPT)
            
            if vm.isInteractingWithChatGPT {
                HStack {
                    DotLoadingView().frame(width: 40, height: 30)
                    PlainButton(icon: "stop.circle", label: "停止生成", backgroundColor: Color.hex(0xFF0000).opacity(0.5), foregroundColor: .white, shortcut: .init("s"), modifiers: .command) {
                        scrolledByUser = false
                        vm.interupt()
                    }
                }
            } else {
                HStack {
                    PlainButton(label: "发送 ↩", backgroundColor: .purple, foregroundColor: .white, shortcut: .return, showHelp: false, action: {
                        Task { @MainActor in
                            if !vm.inputMessage.isEmpty {
                                isTextFieldFocused = false
                                scrolledByUser = false
                                scrollToBottom(proxy: proxy)
                                await vm.sendTapped()
                            }
                        }
                    })
                    .disabled(vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)

                    PlainButton(label: "复制回答 ⌘↩", shortcut: .return, modifiers: .command, showHelp: false) {
                        print("mini")
                        Task { @MainActor in
                            print("mini")
                            copy(text: vm.messages.last?.responseText ?? "")
                            NSApplication.shared.hide(nil)
//                            NSApplication.shared.windows.first?.miniaturize(nil)
                        }
                    }
                    .disabled(vm.messages.last?.responseText?.isEmpty ?? true)
                    .opacity(vm.messages.last?.responseText?.isEmpty ?? true ? 0.5 : 1)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .animation(.easeInOut)
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = vm.messages.last?.id else { return }
        proxy.scrollTo(id, anchor: .bottom)
    }
}
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContentView(vm: ViewModel(conversation: GPTConversation(), api: ChatGPTAPI(apiKey: "")))
        }
    }
}
