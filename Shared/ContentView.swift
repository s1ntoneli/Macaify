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
                        ForEach(vm.messages) { message in
                            MessageRowView(message: message) { message in
                                Task { @MainActor in
                                    await vm.retry(message: message)
                                }
                            }
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
            .onChange(of: vm.messages.last?.responseText) { _ in  scrollToBottom(proxy: proxy)
            }
        }
        .background(colorScheme == .light ? .white : Color(red: 52/255, green: 53/255, blue: 65/255, opacity: 0.5))
    }

    func bottomView(image: String, proxy: ScrollViewProxy) -> some View {
        HStack(alignment: .top, spacing: 8) {
            InputEditor(placeholder: "", text: $vm.inputMessage, onShiftEnter: {
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
                    Button {
                        Task { @MainActor in
                            isTextFieldFocused = false
                            scrollToBottom(proxy: proxy)
                            await vm.sendTapped()
                        }
                    } label: {
                        HStack {
                            Text("发送 ↩")
                        }
                    }
#if os(macOS)
                    .buttonStyle(RoundedButtonStyle(cornerRadius: 6))
                    .keyboardShortcut(.return)
                    .foregroundColor(Color.gray.opacity(0.5))
#endif
                    .disabled(vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .onKeyPressed(.enter) { event in
                        Task { @MainActor in
                            isTextFieldFocused = false
                            scrollToBottom(proxy: proxy)
                            await vm.sendTapped()
                        }
                        return true
                    }

                    Button {
                        Task { @MainActor in
                            print("mini")
                            NSApplication.shared.windows.first?.miniaturize(nil)
                        }
                    } label: {
                        HStack {
                            Text("使用最后的回答 ⌘↩")
                        }
                    }
#if os(macOS)
                    .buttonStyle(RoundedButtonStyle(cornerRadius: 6))
                    .keyboardShortcut(.return, modifiers: .command)
                    .foregroundColor(Color.gray.opacity(0.5))
#endif
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
