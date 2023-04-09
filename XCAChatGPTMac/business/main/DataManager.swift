//
//  DataManager.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/8.
//

import Foundation

class DataManager {
    static let shared = DataManager()

    private init() {}

    func saveData(_ data: Data, to directory: FileManager.SearchPathDirectory, with filename: String) -> URL? {
        let fileManager = FileManager.default
        let path = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)[0] as NSString
        let directoryURL = URL(fileURLWithPath: path as String)

        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            let fileURL = directoryURL.appendingPathComponent(filename)
            try data.write(to: fileURL, options: .atomic)
            return fileURL
        } catch {
            print("Error saving data: \(error.localizedDescription)")
            return nil
        }
    }

    func loadData(from directory: FileManager.SearchPathDirectory, with filename: String) -> Data? {
        let fileManager = FileManager.default
        let path = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)[0] as NSString
        let directoryURL = URL(fileURLWithPath: path as String)
        let fileURL = directoryURL.appendingPathComponent(filename)

        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                return data
            } catch {
                print("Error loading data: \(error.localizedDescription)")
                return nil
            }
        } else {
            print("File not found: \(filename)")
            return nil
        }
    }

    func deleteData(from directory: FileManager.SearchPathDirectory, with filename: String) -> Bool {
        let fileManager = FileManager.default
        let path = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)[0] as NSString
        let directoryURL = URL(fileURLWithPath: path as String)
        let fileURL = directoryURL.appendingPathComponent(filename)

        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
                return true
            } catch {
                print("Error deleting data: \(error.localizedDescription)")
                return false
            }
        } else {
            print("File not found: \(filename)")
            return false
        }
    }
}
