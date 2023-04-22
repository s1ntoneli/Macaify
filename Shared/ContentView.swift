//
//  ContentView.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import SwiftUI
import AVKit

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var vm: ViewModel
    @FocusState var isTextFieldFocused: Bool
    
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
                scrollToBottom(proxy: proxy)
            }
            .onAppear {
                scrollToBottom(proxy: proxy)
            }
        }
        .background(colorScheme == .light ? .white : Color(red: 52/255, green: 53/255, blue: 65/255, opacity: 0.5))
    }

    func bottomView(image: String, proxy: ScrollViewProxy) -> some View {
        HStack(alignment: .top, spacing: 8) {
            InputEditor(placeholder: "按 Tab 聚焦", text: $vm.inputMessage, onShiftEnter: {
                Task { @MainActor in
                    isTextFieldFocused = false
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
                    PlainButton(label: "发送 ↩", shortcut: .return, action: {
                        Task { @MainActor in
                            scrollToBottom(proxy: proxy)
                            await vm.sendTapped()
                        }
                    })
                    .disabled(vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)

                    PlainButton(label: "使用最后的回答 ⌘↩", shortcut: .return, modifiers: .command) {
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
        proxy.scrollTo(id, anchor: .bottomTrailing)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContentView(vm: ViewModel(api: ChatGPTAPI(apiKey: "")))
        }
    }
}
