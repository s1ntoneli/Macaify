import SwiftUI

// BardStore
class BardStore: ObservableObject {

    // 单例
    static var shared = BardStore()

    // bard 搜索结果
    @Published var bardInfo: BardInfo?

    // bard 搜索
    func search(_ text: String) {
        Bard.shared.request(text) { bardInfo in
            DispatchQueue.main.async {
                self.bardInfo = bardInfo
            }
        }
    }

    // MARK: - 以下是 bard 的本地模拟数据
    // 文件名
    let fileName = "bard_response.json"

    // 从文件中读取 BardInfo
    func readBardInfo() -> BardInfo? {
        let path = Bundle.main.path(forResource: fileName, ofType: nil)
        let url = URL(fileURLWithPath: path!)
        let data = try! Data(contentsOf: url)
        let bardInfo = try! JSONDecoder().decode(BardInfo.self, from: data)
        return bardInfo
    }
}
