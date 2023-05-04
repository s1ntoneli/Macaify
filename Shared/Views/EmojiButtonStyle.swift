//
//  EmojiButtonStyle.swift
//  Found
//
//  Created by lixindong on 2023/4/29.
//

import Foundation
import SwiftUI

struct EmojiButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20))
            .frame(width: 30, height: 30)
            .background((configuration.isPressed ? Color.gray.opacity(0.3) : Color.transparent).cornerRadius(6))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring())
    }
}
