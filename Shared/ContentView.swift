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
        chatListView
            .navigationTitle("XCA ChatGPT")
    }
    
    var chatListView: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
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
//                vm?.goBackOrForwardBy(delta: Int(event?.deltaY ?? 0))
                print("event.deltaY \(event?.deltaY)")
                if let deltaY = event?.deltaY, deltaY != 0 {
                    scrolledByUser = true
                }
            }
            .store(in: &subs)
    }

    @State var subs = Set<AnyCancellable>() // Cancel onDisappear

    func bottomView(image: String, proxy: ScrollViewProxy) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Button {
                vm.clearMessages()
            } label: {
                Image(systemName: "clear")
            }
            .help("清除聊天记录")
            Button {
                vm.clearContext()
            } label: {
                Image(systemName: "lasso.sparkles")
            }
            .help("清除上下文")

            InputEditor(placeholder: "按 Tab 聚焦", text: $vm.inputMessage, onShiftEnter: {
                Task { @MainActor in
                    isTextFieldFocused = false
                    scrolledByUser = false
                    scrollToBottom(proxy: proxy)
                    await vm.sendTapped()
                }
            })
            .frame(height: 40)
#if os(iOS) || os(macOS)
            .textFieldStyle(.roundedBorder)
#endif
            .focused($isTextFieldFocused)
            .disabled(vm.isInteractingWithChatGPT)
            
            if vm.isInteractingWithChatGPT {
                DotLoadingView().frame(width: 60, height: 30)
            } else {
                HStack {
                    PlainButton(label: "发送 ↩", shortcut: .return, showHelp: false, action: {
                        Task { @MainActor in
                            scrolledByUser = false
                            scrollToBottom(proxy: proxy)
                            await vm.sendTapped()
                        }
                    })
                    .disabled(vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)

                    PlainButton(label: "使用最后的回答 ⌘↩", shortcut: .return, modifiers: .command, showHelp: false) {
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
        .padding(.top, 12)
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = vm.messages.last?.id else { return }
        proxy.scrollTo(id, anchor: .bottom)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContentView(vm: ViewModel(conversation: GPTConversation(), api: ChatGPTAPI(apiKey: "")))
        }
    }
}
