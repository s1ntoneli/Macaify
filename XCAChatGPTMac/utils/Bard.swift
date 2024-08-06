//
//  Bard.swift
//  Macaify
//
//  Created by lixindong on 2023/7/29.
//

import Foundation

class Bard {

    // 单例
    static let shared = Bard()

    // base url
    let baseUrl = "https://bard.gokoding.com"

    // 请求 bard 接口
    // base url
    // 参数：图片描述
    // 返回：图片描述对应的图片
    func request(_ text: String, completion: @escaping (BardInfo?) -> Void) {
        let url = URL(string: "\(baseUrl)/bard?prompt=\(text)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 打印调试信息，如果有错误，打印错误信息
            if let error = error {
                print("Error: \(error)")
                return
            }
            // 打印调试信息，如果有返回数据，打印返回数据
            if let data = data {
                let str = String(data: data, encoding: .utf8)!
                print(str)

                // 转成 BardInfo
                let decoder = JSONDecoder()
                // 从 BardInfo 中获取图片描述对应的图片
                let bardInfo = try? decoder.decode(BardInfo.self, from: data)
                completion(bardInfo)
            }
        }
        task.resume()
    }
}

// 根据下面的json生成model
struct BardInfo: Codable {
    let content: String
    let conversationId: String?
    let responseId: String?
    let factualityQueries: [String]?
//    let textQuery: [String]?
    let choices: [Choice]?
    let links: [String]?
    let images: [String]?
    
    struct Choice: Codable {
        let id: String
        let content: [String]
    }
}
