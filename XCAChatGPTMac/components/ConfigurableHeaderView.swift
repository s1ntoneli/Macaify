//
//  ConfigurableHeaderView.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/16.
//

import SwiftUI

struct ConfigurableView<Content: View>: View {
    var onBack: () -> Void
    let title: String
    let showLeftButton: Bool
    @ViewBuilder let actions: Content
    
    var body: some View {
        ZStack {
            HStack {
                if showLeftButton {
                    PlainButton(icon: "chevron.backward", foregroundColor: .blue, shortcut: "b",modifiers: .command) {
                        onBack()
                    }
                }
                
                Spacer()
                
                actions
            }
            HStack(alignment: .center) {
                Spacer()
                
                Text(LocalizedStringKey(title))
                    .font(.subheadline)
                    .fontWeight(.bold)

                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }
}

//
//
//struct ConfigurableHeaderView_Previews: PreviewProvider {
//    static var previews: some View {
//    }
//}
