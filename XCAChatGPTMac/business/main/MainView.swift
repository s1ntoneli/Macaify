//
//  MainView.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import Foundation
import SwiftUI

struct MainView: View {
    @StateObject var vm: ViewModel
    
    @EnvironmentObject var commandStore: CommandStore

    @EnvironmentObject var pathManager: PathManager
    // 搜索关键字
    @State private var searchText = ""
    @State private var showSettings = false
    // 添加 AddCommandView 的显示状态变量
    @State private var isAddCommandViewPresented = false
    
    // 选中的列表项下标
    @State private var selectedItemIndex = 0
    
    var body: some View {
        VStack {
            // 搜索框
            HStack {
                TextField("写下你的问题", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            
            // 列表
            List {
                ForEach(commandStore.commands) { command in
                    ZStack {
                        Color.clear
                        HStack {
                            Image(systemName: command.icon)
                            Text(command.name)
                                .padding(.leading, 10)
                            Spacer()
                            Text(command.shortcut)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    .background(Color.gray.opacity(0.1))
                    .onTapGesture {
                        pathManager.toChat(command)
                    }
                }
                .onDelete(perform: commandStore.removeCommand)
            }
            .padding(.horizontal, -20)
            
            // 底部信息栏
            HStack {
                VStack(alignment: .leading) {
                    Text("应用程序名称")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Text("版本")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                Spacer()
                HStack {
                    Button(action: {
                        // 点击设置按钮
                        //                            self.showSettings = true
                        pathManager.to(target: .setting)
                    }) {
                        Image(systemName: "gear")
                    }
                    Button(action: {
                        // 点击添加指令按钮
                        //                            isAddCommandViewPresented = true
                        pathManager.to(target: .addCommand)
                    }) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .sheet(isPresented: $showSettings) {
            SettingView {
                showSettings = false
            }
        }
        // 使用 sheet 函数将 AddCommandView 包装成一个弹出窗口
        .sheet(isPresented: $isAddCommandViewPresented) {
            AddCommandView()
        }
    }
}

// 列表项数据模型
struct Command: Identifiable, Hashable, Codable {
    var id = UUID()
    let name: String
    let icon: String
    let protmp: String
    let shortcut: String
    let autoAddSelectedText: Bool
}
