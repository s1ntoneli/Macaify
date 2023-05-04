
import Foundation

struct Emoji: Codable, Identifiable {
    var id: String {
        get { emoji }
    }
    let description: String
    let category: EmojiCategory
    let aliases: [String]
    let emoji: String

    enum CodingKeys: String, CodingKey {
//        case id
        case description
        case category
        case aliases
        case emoji
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(String.self, forKey: .id)
        description = try container.decode(String.self, forKey: .description)
        category = try container.decode(EmojiCategory.self, forKey: .category)
        aliases = try container.decode([String].self, forKey: .aliases)
        emoji = try container.decode(String.self, forKey: .emoji)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
        try container.encode(description, forKey: .description)
        try container.encode(category, forKey: .category)
        try container.encode(aliases, forKey: .aliases)
        try container.encode(emoji, forKey: .emoji)
    }
}

enum EmojiCategory: String, CaseIterable, Codable {
    case smileysAndEmotion = "Smileys & Emotion"
    case people = "People & Body"
    case animalsAndNature = "Animals & Nature"
    case foodAndDrink = "Food & Drink"
    case travelAndPlaces = "Travel & Places"
    case activities = "Activities"
    case objects = "Objects"
    case symbols = "Symbols"
    case flags = "Flags"

    var iconName: String {
        switch self {
        case .smileysAndEmotion:
            return "😃"
        case .people:
            return "🙎‍♂️"
        case .animalsAndNature:
            return "🦊"
        case .foodAndDrink:
            return "🍉"
        case .travelAndPlaces:
            return "✈️"
        case .activities:
            return "🎉"
        case .objects:
            return "💡"
        case .symbols:
            return "0️⃣"
        case .flags:
            return "🚩"
        }
    }
}

extension Emoji {
//    var id: String {
//        get { description }
//    }
}
