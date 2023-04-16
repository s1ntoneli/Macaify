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
        HStack {
            if showLeftButton {
                Button(action: {
                    // left button action
                    onBack()
                }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.blue)
                }
                .buttonStyle(RoundedButtonStyle(cornerRadius: 6))
                .keyboardShortcut(.init("b"), modifiers: .command)
            }
            
            Spacer()
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            Spacer()
            
            actions
        }
        .padding()
    }
}

//
//
//struct ConfigurableHeaderView_Previews: PreviewProvider {
//    static var previews: some View {
//    }
//}
