//
//  CommandDetailView.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/9.
//

import SwiftUI

struct CommandDetailView: View {
    
    let command: Command
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "app.fill")
                    .resizable()
                    .frame(width: 48, height: 48)
                Spacer()
                Button(action: {
                    // 点击设置按钮的响应
                }) {
                    Image(systemName: "gear")
                        .font(.title)
                }
                .buttonStyle(.plain)
            }
            HStack(alignment: .bottom) {
                Text(command.name)
                    .font(.title)

                Text(command.shortcutDescription)
                    .font(.title2)
                    .opacity(0.5)
            }
            .padding(.top, 12)
            Text("prompt")
                .font(.subheadline)
                .padding(.top)
            Text(command.protmp)
                .font(.title3)
            Spacer()
//            Button(action: {
//                // 点击开始聊天按钮的响应
//            }) {
//                Text("编辑 ⌘E")
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//            }
//            .buttonStyle(PurpleButtonStyle())
        }
        .padding(.all, 24)
    }
}
