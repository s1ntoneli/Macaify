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
    @ObservedObject var vm: ViewModel
    @AppStorage("proxyAddress") private var proxyAddress = ""
    @AppStorage("useProxy") private var useProxy = false

    init(id: UUID, msg: String? = nil) {
        self.id = id
        self.vm = commandStore.commandViewModel(for: id)
        print("proxy \(useProxy) \(proxyAddress) \(msg)")
        self.vm.inputMessage = msg ?? ""
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
            .buttonStyle(RoundedButtonStyle(cornerRadius: 6))
            .keyboardShortcut(.init("b"), modifiers: .command)

            Spacer()
            Text(command.name)
                .font(.headline)
                .fontWeight(.bold)
            Spacer()
            PlainButton(icon: "lineweight", shortcut: .init("e"), modifiers: .command, action: {
                // 编辑按钮的响应
                print("button down")
                pathManager.to(target: .editCommand(command: command))
            })
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task { [self] in
                print("run task sendTapped")
                if (!self.vm.inputMessage.isEmpty) {
                    await self.vm.sendTapped()
                }
            }
        }
    }
}
//
//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView()
//    }
//}
