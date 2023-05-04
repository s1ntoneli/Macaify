import SwiftUI

struct EmojiPickerView: View {
    @StateObject private var viewModel = EmojiPickerViewModel()
    @StateObject private var recentViewModel = RecordManager(maxCount: 12)
    @Binding var selectedEmoji: Emoji?

    var body: some View {
        VStack(spacing: 0) {
            // 搜索栏
            HStack {
                SearchBar(text: $viewModel.searchText)
                Button(action: {
                    selectedEmoji = viewModel.randomOnce()
                    recentViewModel.addRecord(content: selectedEmoji!.emoji)
                }) {
                    Image(systemName: "shuffle")
                        .padding(8)
                        .background(.gray.opacity(0.1))
                        .cornerRadius(4)
                        .foregroundColor(.text)
                }
                .buttonStyle(.plain)
                Button(action: {
                    selectedEmoji = nil
                }) {
                    Image(systemName: "xmark")
                        .padding(8)
                        .background(.gray.opacity(0.1))
                        .cornerRadius(4)
                        .foregroundColor(.text)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Emoji 列表
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    Text("最近使用").font(.body)
                        .opacity(0.5)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 10), spacing: 4) {
                        ForEach(recentViewModel.records) { emoji in
                            Button(action: {
                                if let emoji = viewModel.findEmoji(by: emoji.content) {
                                    selectedEmoji = emoji
                                    recentViewModel.addRecord(content: emoji.emoji)
                                }
                            }) {
                                Text(emoji.content)
                                    .font(.system(size: 24))
                            }
                            .buttonStyle(EmojiButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 0)
                    
                    Text("全部").font(.body)
                        .opacity(0.5)
                        .padding(.horizontal)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 10), spacing: 4) {
                        ForEach(viewModel.filteredEmojis, id: \.emoji) { emoji in
                            Button(action: {
                                selectedEmoji = emoji
                                recentViewModel.addRecord(content: emoji.emoji)
                            }) {
                                Text(emoji.emoji)
                                    .font(.system(size: 24))
                            }
                            .buttonStyle(EmojiButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    .padding(.top, 0)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 400, height: 300)
        .background(.white)
    }
}
//
//struct EmojiPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        EmojiPickerView()
//    }
//}
