//
//  EmojiManager.swift
//  Found
//
//  Created by lixindong on 2023/5/4.
//

import Foundation
import Combine

// EmojiManager
class EmojiManager {
    static var shared = EmojiManager()

    var emojis: [Emoji] = []
    private var subscriptions = Set<AnyCancellable>()

    init() {
        loadEmojis()
    }
    
    func randomOnce() -> Emoji {
        emojis.shuffled().first!
    }
    
    func findEmoji(by content: String) -> Emoji? {
        emojis.first { emoji in
            emoji.emoji == content
        }
    }

    private func loadEmojis() {
        guard let url = Bundle.main.url(forResource: "emoji_metadata", withExtension: "json") else {
            fatalError("Failed to locate emoji.json in app bundle.")
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map {
                print("load data from json", $0.data)
                return $0.data
            }
            .decode(type: [Emoji].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] emojis in
                print("load emojis \(emojis.count)")
                self?.emojis = emojis
            }
            .store(in: &subscriptions)
    }
}
