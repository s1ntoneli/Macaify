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
            Text("welcome_to_macaify")
                .font(.largeTitle)
                .bold()
                .padding(.top, 20)
                .padding(.bottom, 20)
            
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Text("✨")
                        .font(.largeTitle)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("double_click_to_activate")
                            .font(.headline)
                        Text("quick_access_description")
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
                            Text("hold_cmd_for_shortcuts")
                                .font(.headline)
                            Text("shortcuts_help_description")
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
                            Text("bots_plaza")
                                .font(.headline)
                            Text("bots_plaza_description")
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
                            Text("unlimited_bots")
                                .font(.headline)
                            Text("custom_bots_description")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .frame(maxWidth: 370)
            Spacer()
            PlainButton(label: "get_started", width: 300, height: 40, backgroundColor: .blue.opacity(0.9), pressedBackgroundColor: .blue, foregroundColor: .white, cornerRadius: 8, shortcut: .init("s"), modifiers: .command, action: {
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
