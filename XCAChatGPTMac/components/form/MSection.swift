//
//  MSection.swift
//  Macaify
//
//  Created by lixindong on 2023/7/22.
//

import Foundation
import SwiftUI

struct MSection<Content>: View where Content: View {
    
    var title: LocalizedStringKey
    @ViewBuilder var content: Content
    
    init(_ title: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color.clear
            VStack(alignment: .leading) {
                Text(title)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
                    .font(.headline)
                VStack(alignment: .leading, spacing: 12) {
                    content
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.gray.opacity(0.04))
                        .border(.gray.opacity(0.08))
                        .cornerRadius(4)
                )
                .font(.body)
            }
        }
    }
}

struct Item<Content: View>: View {
    
    var label: String
    @ViewBuilder var content: Content
    
    init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Text(label)
            Spacer()
            content
        }
    }
}
