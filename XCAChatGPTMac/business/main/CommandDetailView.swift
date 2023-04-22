//
//  CommandDetailView.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/9.
//

import SwiftUI
import MarkdownUI

struct CommandDetailView: View {
    @Environment(\.scenePhase) private var scenePhase

    @EnvironmentObject var pathManager: PathManager
    @Binding var command: Command

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image("profile")
                        .resizable()
                        .frame(width: 48, height: 48)
                    Spacer()
                    PlainButton(icon: "square.stack.3d.up", label: "编辑 ⌘E", shortcut: .init("e"), modifiers: .command) {
                        print("edit command \(command.id) \(command.name)")
                        pathManager.to(target: .editCommand(command: command))
                    }
                }
                HStack(alignment: .bottom) {
                    Text(command.name)
                        .font(.title)
                }
                .padding(.top, 8)
                
                Text(command.shortcutDescription)
                    .font(.title2)
                    .opacity(0.5)
                Markdown(command.protmp)
                    .font(.title3)
                    .opacity(0.7)
                    .padding(.top, 12)
                Spacer()
            }
            .padding(.all, 24)
        }
        .onAppear {
            print("detailView onAppear")
        }
        .onDisappear {
            print("detailView onDisappear")
        }
    }
}
