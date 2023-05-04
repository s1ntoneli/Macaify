//
//  EmojiCategoryTabView.swift
//  Found
//
//  Created by lixindong on 2023/4/28.
//

import Foundation
import SwiftUI

struct EmojiCategoryTabView: View {
    let categories: [EmojiCategory]
    @State var selectedCategory: EmojiCategory?
//    var categories: [EmojiCategory] = EmojiCategory.allCases
    @EnvironmentObject private var viewModel: EmojiPickerViewModel

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    EmojiCategoryView(category: category, selectedCategory: $selectedCategory)
//                    Text(category.iconName)
//                    emojis
                        .tabItem {
                            Text(category.iconName)
                        }
                        .tag(category)
                }
            }
//            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.horizontal)
            .padding(.top, 10)
        }
//        .frame(height: 300)
    }
    
    func EmojiView() -> some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 16) {
                ForEach(viewModel.filteredEmojis) { emoji in
                    Button(action: {
                        viewModel.selectEmoji(emoji)
                    }) {
                        Text(emoji.emoji)
                            .font(.system(size: 32))
                    }
                    .buttonStyle(EmojiButtonStyle())
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
