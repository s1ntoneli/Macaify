//
//  ChatView.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/9.
//

import SwiftUI

struct ChatView: View {
    let id: UUID
    var command: Command {
        get {
            commandStore.commands.first(where: {$0.id == id})!
        }
    }
    var pathManager: PathManager = PathManager.shared
    var commandStore: CommandStore = CommandStore.shared
    let vm: ViewModel
    @AppStorage("proxyAddress") private var proxyAddress = ""
    @AppStorage("useProxy") private var useProxy = false

    init(id: UUID) {
        self.id = id
//        self.command = command
//        self.vm = ViewModel(api: ChatGPTAPI(apiKey: APIKeyManager.shared.key ?? "", model: ModelSelectionManager.shared.selectedModel.name, systemPrompt: command.protmp, temperature: 0.5, baseURL: _useProxy.wrappedValue ? _proxyAddress.wrappedValue : nil), enableSpeech: true)
        self.vm = commandStore.commandViewModel(for: id)
        print("proxy \(useProxy) \(proxyAddress)")
    }
    
    var body: some View {
        VStack {
            titleBar
            ContentView(vm: self.vm)
        }.background(.white)
    }

    var titleBar: some View {
        HStack {
            Button(action: {
                pathManager.back()
            }) {
                Image(systemName: "chevron.backward")
                    .foregroundColor(.blue)
            }
            Spacer()
            Text(command.name)
                .font(.headline)
                .fontWeight(.bold)
            Spacer()
            Button(action: {
                // 编辑按钮的响应
                pathManager.to(target: .editCommand(command: command))
            }) {
                Image(systemName: "lineweight")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}
//
//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView()
//    }
//}
