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

    var body: some View {
        Group {
            let icon = conversation.iconOrDefault
            Text(icon)
                .font(.custom("", size: size))
        }
    }
}

extension GPTConversation {
    static let defaultIcon: String = "🍌"

    var iconOrDefault: String {
        icon.isEmpty ? GPTConversation.defaultIcon : icon
    }
}
