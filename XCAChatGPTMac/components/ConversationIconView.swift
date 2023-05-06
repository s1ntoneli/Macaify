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
    var defaultIcon: String = "🍌"

    var body: some View {
        Group {
            let icon = conversation.icon.isEmpty ? defaultIcon : conversation.icon
            Text(icon)
                .font(.custom("", size: size))
        }
    }
}
