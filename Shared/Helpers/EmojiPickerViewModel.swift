//
//  EmojiViewModel.swift
//  Found
//
//  Created by lixindong on 2023/4/28.
//

import Foundation
import SwiftUI

class EmojiPickerViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var selectedCategory: EmojiCategory? = nil
    @Published var selectedEmoji: Emoji? = nil
    @Published var isShowingPopover: Bool = false

    var categories: [EmojiCategory] {
        return EmojiCategory.allCases
    }

    var filteredEmojis: [Emoji] {
        var result = EmojiManager.shared.emojis

        // 过滤搜索文本
        if !searchText.isEmpty {
            result = result.filter { emoji in
                emoji.description.localizedCaseInsensitiveContains(searchText) ||
                emoji.aliases.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }

        // 过滤分类
        if let category = selectedCategory {
            result = result.filter { emoji in
                emoji.category == category
            }
        }

        return result
    }

    func selectEmoji(_ emoji: Emoji) {
        selectedEmoji = emoji
        isShowingPopover = true
    }
    
    func randomOnce() -> Emoji {
        EmojiManager.shared.randomOnce()
    }
    
    func findEmoji(by content: String) -> Emoji? {
        EmojiManager.shared.findEmoji(by: content)
    }
}
