
import Foundation

class EmojiData {
    static let shared = EmojiData()

    private var emojis: [Emoji] = []

    private init() {
        loadEmojis()
    }

    func allCategories() -> [EmojiCategory] {
        return EmojiCategory.allCases
    }

    func emojis(for category: EmojiCategory? = nil, searchText: String? = nil) -> [Emoji] {
        var result = emojis

        if let category = category {
            result = result.filter { $0.category == category }
        }

        if let searchText = searchText, !searchText.isEmpty {
            result = result.filter { emoji in
                emoji.description.localizedCaseInsensitiveContains(searchText) ||
                emoji.aliases.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }

        return result
    }

    func emoji(by id: String) -> Emoji? {
        return emojis.first(where: { $0.id == id })
    }

    private func loadEmojis() {
        guard let url = Bundle.main.url(forResource: "emoji_metadata", withExtension: "json") else {
            fatalError("Failed to locate emoji_metadata.json in app bundle.")
        }

        do {
            let data = try Data(contentsOf: url)
            emojis = try JSONDecoder().decode([Emoji].self, from: data)
        } catch {
            fatalError("Failed to decode emoji.json: \(error.localizedDescription)")
        }
    }
}
