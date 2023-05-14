//
//  NewFeatureIntroductionView.swift
//  Found
//
//  Created by lixindong on 2023/5/14.
//

import SwiftUI

struct NewFeatureIntroductionView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("欢迎使用 Found.AI")
                .font(.largeTitle)
                .bold()
                .padding(.top, 20)
                .padding(.bottom, 20)
            
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Text("✨")
                        .font(.largeTitle)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("双击 ⌘ 呼出 Found.AI")
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
            Spacer()
            Button(action: {
                UserDefaults.standard.set(true, forKey: "hasShownNewFeatureIntroduction")
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("开始使用")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .buttonStyle(StartUpButtonStyle(cornerRadius: 8, backgroundColor: .blue.opacity(0.9), pressedBackgroundColor: .blue))
        }
        .frame(width: 450, height: 420)
        .padding(20)
    }
}


struct NewFeatureIntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        NewFeatureIntroductionView()
    }
}
