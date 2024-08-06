//
//  BardView.swift
//  Macaify
//
//  Created by lixindong on 2023/7/30.
//

import SwiftUI

struct BardView: View {
    @ObservedObject var bardStore = BardStore.shared
//    @State var bardInfo: BardInfo? = bardStore.bardInfo
//    @State var images: [String] = []
//    var images: [String]
//    var images: [String] {
//        get {
//            bardInfo?.images ?? []
//        }
//    }
    
    var body: some View {
        // 展示网络图片列表
        let images = bardStore.bardInfo?.images ?? []
//        if (images != nil) {
            VStack {
//                Text("count: \(images!.count)")
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(images, id: \.self) { image in
                            AsyncImage(url: URL(string: image)) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 200, height: 200)
                            .cornerRadius(20)
                        }
                    }
                }
            }
//        } else {
//            ZStack {}
//        }
        ZStack {}
            .onAppear {
                // 搜索 bard
                BardStore.shared.bardInfo = BardInfo(content: "", conversationId: "", responseId: "", factualityQueries: [], choices: [], links: [], images: BardStore.shared.readBardInfo()?.images ?? [])
//                BardStore.shared.search("cats")
//                print("bardInfo \(images.count)")
            }
    }
}

struct BardView_Previews: PreviewProvider {
    static var previews: some View {
        BardView()
    }
}
