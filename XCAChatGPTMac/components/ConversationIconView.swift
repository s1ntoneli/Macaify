//
//  ConversationIconView.swift
//  Found
//
//  Created by lixindong on 2023/5/3.
//

import Foundation
import SwiftUI

struct ConversationIconView: View {
    let conversation: GPTConversation
    let size: CGFloat
    var defaultIcon: String = "lightbulb"

    var body: some View {
        Group {
            if conversation.icon.isEmpty {
                Image(systemName: defaultIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .foregroundColor(Color.hex(0xFFB717))
            } else {
                Text(conversation.icon)
                    .font(.custom("", size: size))
            }
        }
    }
}
