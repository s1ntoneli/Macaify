
import SwiftUI

struct EmojiCategoryView: View {
    let category: EmojiCategory
    @Binding var selectedCategory: EmojiCategory?

    var body: some View {
        Button(action: {
            selectedCategory = category
        }) {
            VStack {
                Image(systemName: category.iconName)
                    .font(.system(size: 20))
                Text(category.rawValue.description)
                    .font(.system(size: 12))
            }
            .foregroundColor(selectedCategory == category ? .primary : .secondary)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

//struct EmojiCategoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        EmojiCategoryView(category: EmojiCategory(name: "Smileys & Emotion", iconName: "face.smiling"), selectedCategory: .constant(nil))
//            .previewLayout(.sizeThatFits)
//    }
//}
