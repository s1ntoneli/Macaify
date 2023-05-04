//
//  RecordManager.swift
//  Found
//
//  Created by lixindong on 2023/5/3.
//

import Foundation

struct Record: Identifiable, Codable {
    var id = UUID()
    let content: String
    let timestamp: Date
    
    init(content: String, timestamp: Date) {
        self.content = content
        self.timestamp = timestamp
    }
    
    init(from data: Data) throws {
        self = try JSONDecoder().decode(Record.self, from: data)
    }
    
    func encode() throws -> Data {
        try JSONEncoder().encode(self)
    }
}

class RecordManager: ObservableObject {
    @Published var records: [Record] = []
    let maxCount: Int
    
    private let key = "records"
    
    init(maxCount: Int) {
        self.maxCount = maxCount
        loadData()
    }
    
    func addRecord(content: String) {
        if let index = records.firstIndex(where: { $0.content == content }) {
            let record = records.remove(at: index)
            records.insert(record, at: 0)
        } else {
            let record = Record(content: content, timestamp: Date())
            records.insert(record, at: 0)
        }
        
        if records.count > maxCount {
            records.removeLast()
        }
        
        saveData()
    }
    
    func getRecords() -> [Record] {
        let sortedRecords = records.sorted(by: { $0.timestamp > $1.timestamp })
        return Array(sortedRecords.prefix(maxCount))
    }
    
    private func loadData() {
        guard let data = UserDefaults.standard.array(forKey: key) as? [String] else {
            return
        }
        
        records = data.compactMap { try? Record(from: Data(base64Encoded: $0)!) }
    }
    
    private func saveData() {
        let data = records.prefix(maxCount).compactMap { try? $0.encode().base64EncodedString() }
        UserDefaults.standard.set(data, forKey: key)
    }
}
