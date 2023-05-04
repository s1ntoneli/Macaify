//
//  EmojiPickerPopoverView.swift
//  Found
//
//  Created by lixindong on 2023/4/28.
//

import Foundation
import SwiftUI

struct EmojiPickerPopoverView: View {
    var selectedEmoji: Emoji?
    
    var body: some View {
        VStack {
            Text(selectedEmoji?.emoji ?? "")
                .font(.system(size: 50))
                .padding(.top, 10)
            
            Spacer()
        }
        .frame(width: 150, height: 150)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
