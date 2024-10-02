//
//  PromptPlayground.swift
//  Found
//
//  Created by lixindong on 2023/4/21.
//

import SwiftUI
//import AlertToast

struct PromptPlayground: View {
    
    @StateObject private var promptStore = PromptStore()
    @State var id: UUID = UUID()

    private var selected: Int {
        get {
            promptStore.selected
        }
        set(newValue) {
            promptStore.selected = newValue
        }
    }
    @EnvironmentObject var pathManager: PathManager
    @FocusState var focusState: Bool
    @State private var showToast = false

    var body: some View {
        VStack(spacing: 0) {
            ConfigurableView(onBack: { pathManager.back() }, title: "机器人广场", showLeftButton: true) {
                searchbar
            }
            .zIndex(100)
//            .toast(isPresenting: $showToast) {
                // `.alert` is the default displayMode
//                AlertToast(displayMode: .hud, type: .regular, title: "Added to favorites", style: .style(backgroundColor: .white))

                //Choose .hud to toast alert from the top of the screen
                //AlertToast(displayMode: .hud, type: .regular, title: "Message Sent!")
//            }

            Divider()
                .background(Color.divider)

            HStack(spacing: 0) {
                GeometryReader { reader in
                    HStack(spacing: 0) {
                        category
                            .frame(width: reader.size.width * 0.18)

                        Divider()
                            .background(Color.divider)
                            .opacity(0.5)

                        VStack {
                            prompts
                        }
                        .frame(width: reader.size.width * 0.82)
                    }
                }
            }
        }
//        .navigationBarBackButtonHidden(true)
        .background(.white)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                focusState = true
            }
        }
        .onKeyPressed(.upArrow) { event in
            print("prompt upArrow")
            let count = promptStore.prompts.count + 1
            promptStore.selected = (selected - 1 + count) % count
            print("prompt upArrow after \(selected)")
            return true
        }
        .onKeyPressed(.downArrow) { event in
            print("prompt downArrow")
            let count = promptStore.prompts.count + 1
            promptStore.selected = (selected + 1 + count) % count
            print("prompt downArrow after \(selected)")
            return true
        }
    }
    
    var category: some View {
        List {
            CategoryItem(name: "all", selected: selected == 0)
                .onTapGesture {
                    promptStore.selected = 0
                }
            ForEach(promptStore.prompts, id: \.title) {category in
                CategoryItem(name: category.title, selected: selected != 0 && category.title == promptStore.prompts[selected - 1].title)
                    .onTapGesture {
                        print("tap category \(category.title)")
                        if let index = promptStore.prompts.firstIndex(where: { cate in
                            cate.title == category.title
                        }) {
                            promptStore.selected = index + 1
                        } else {
                            promptStore.selected = 0
                        }
                    }
            }
        }
    }
    
    var searchbar: some View {
//        VStack {
//            TextField("SearchBar", text: $searchText)
//                .textFieldStyle(CustomTextFieldStyle())
//                .textFieldStyle(.plain)
//        }
        // 搜索框
        HStack(alignment: .center, spacing: 0) {
            Spacer(minLength: 6)
            Image(systemName: "magnifyingglass")
                .resizable()
                .foregroundColor(Color.text)
                .frame(width: 16, height: 16)
                .opacity(0.7)
            TextField("搜索", text: $promptStore.searchText)
                .focusable()
                .focused($focusState, equals: true)
                .textFieldStyle(.plain)
                .padding(.horizontal)
                .font(.system(size: 16))
                .foregroundColor(Color.text)
                .keyboardShortcut(.init("k"))
        }
        .frame(width: 200)
    }

    var prompts: some View {
        List {
            ForEach(promptStore.filteredPrompts, id: \.title) { prompt in
                PromptItem(prompt: prompt) {
                    PlainButton(icon: "captions.bubble", label: "聊聊看") {
                        pathManager.toChat(prompt.command, mode: .trial)
                    }
                    PlainButton(icon: "rectangle.stack.badge.plus", label: "添加到常用", backgroundColor: Color.purple, pressedBackgroundColor: Color.purple.opacity(0.8), foregroundColor: .white, action: {
                        // 编辑按钮的响应
                        print("添加到常用 \(prompt.title)")
                        ConversationViewModel.shared.addCommand(command: prompt.command)
                        showToast = true
                    })
                }
            }
        }
        .id(id)
        .onChange(of: promptStore.filteredPrompts.count) { _ in
            id = UUID()
        }
    }
}

struct CategoryItem: View {
    let name: String
    let selected: Bool
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            Text(LocalizedStringKey(name))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.vertical, 8)
        .background(selected ? Color.hex(0xF9FAFC) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct PromptItem<Content: View>: View {
    let prompt: PromptTemplate
    @ViewBuilder let actions: Content
    
    @State private var expand: Bool = false
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(prompt.title).font(.title).foregroundColor(.text)
                Text(prompt.prompt).font(.body).foregroundColor(.text.opacity(0.55))
                    .lineLimit(expand ? nil : 2)
                    .onTapGesture {
                        expand.toggle()
                    }
            }
            Spacer()
            actions
        }
        .padding()
        .background(.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct PromptPlayground_Previews: PreviewProvider {
    static var previews: some View {
        PromptPlayground()
    }
}
