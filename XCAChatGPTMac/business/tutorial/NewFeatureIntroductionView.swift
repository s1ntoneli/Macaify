//
//  NewFeatureIntroductionView.swift
//  Found
//
//  Created by lixindong on 2023/5/14.
//

import SwiftUI

struct NewFeatureIntroductionView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("showNewFeature_0_4") var showNewFeatureIntroduction: Bool = true

    var body: some View {
        VStack {
            Text("欢迎使用 Macaify")
                .font(.largeTitle)
                .bold()
                .padding(.top, 20)
                .padding(.bottom, 20)
            
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Text("✨")
                        .font(.largeTitle)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("双击 ⌘ 呼出 Macaify")
                            .font(.headline)
                        Text("任意场景快速呼出，立即开始提问并获得答案")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.bottom, 20)
                HStack(alignment: .center) {
                    Text("💕")
                        .font(.largeTitle)
                    VStack(alignment: .leading, spacing: 4) {
                        Group {
                            Text("长按 ⌘ 显示快捷键提示")
                                .font(.headline)
                            Text("快捷键提示帮助你放下鼠标，全程快捷键操作")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.bottom, 20)
                
                HStack(alignment: .center) {
                    Text("🤖️")
                        .font(.largeTitle)
                    VStack(alignment: .leading, spacing: 4) {
                        Group {
                            Text("机器人广场")
                                .font(.headline)
                            Text("在机器人广场，上百种机器人助理等你试玩！")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.bottom, 20)
                
                HStack(alignment: .center) {
                    Text("♾️")
                        .font(.largeTitle)
                    VStack(alignment: .leading, spacing: 4) {
                        Group {
                            Text("无限制的机器人数量")
                                .font(.headline)
                            Text("快速添加你的自定义机器人🤖️助理，完成多种复杂操作")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .frame(maxWidth: 370)
            Spacer()
            PlainButton(label: "开始使用", width: 300, height: 40, backgroundColor: .blue.opacity(0.9), pressedBackgroundColor: .blue, foregroundColor: .white, cornerRadius: 8, shortcut: .init("s"), modifiers: .command, action: {
                showNewFeatureIntroduction = false
                self.presentationMode.wrappedValue.dismiss()
            })
        }
        .frame(width: 450, height: 430)
        .padding(20)
    }
}


struct NewFeatureIntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        NewFeatureIntroductionView()
    }
}
