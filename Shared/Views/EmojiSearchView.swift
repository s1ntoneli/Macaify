
import SwiftUI

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.text)
                .opacity(0.5)
            TextField("Search", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(8)
        .background(.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct EmojiSearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant(""))
            .previewLayout(.sizeThatFits)
    }
}
