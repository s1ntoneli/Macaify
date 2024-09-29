//
//  LLMModels.swift
//  XCAChatGPT
//
//  Created by lixindong on 2024/9/28.
//

import Foundation

class LLMModelsManager: NSObject, XMLParserDelegate {
    static let shared = LLMModelsManager()
    
    var modelCategories: [ModelCategory] = []
    var providers: [String] = []  // 新增属性来存储提供商列表
    private var currentCategory: ModelCategory?
    private var currentModel: Model?
    private var currentElement: String?
    private var currentArchitecture: Architecture?
    private var currentPricing: Pricing?
    private var currentTopProvider: TopProvider?
    
    private override init() {
        super.init()
        parseXML()
        parseProvidersXML()  // 新增调用
    }
    
    private func parseXML() {
        guard let xmlPath = Bundle.main.path(forResource: "models", ofType: "xml")?.string,
              let xmlData = try? Data(contentsOf: URL(fileURLWithPath: xmlPath)) else {
            print("无法加载XML文件")
            return
        }
        
        let parser = XMLParser(data: xmlData)
        parser.delegate = self
        parser.parse()
    }
    
    // 新增方法来解析 providers.xml
    private func parseProvidersXML() {
        guard let xmlPath = Bundle.main.path(forResource: "providers", ofType: "xml")?.string,
              let xmlData = try? Data(contentsOf: URL(fileURLWithPath: xmlPath)) else {
            print("无法加载providers.xml文件")
            return
        }
        
        let parser = XMLParser(data: xmlData)
        parser.delegate = self
        parser.parse()
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        switch elementName {
        case "category":
            if let name = attributeDict["name"], let provider = attributeDict["provider"] {
                currentCategory = ModelCategory(name: name, provider: provider, models: [])
            }
        case "model":
            currentModel = Model()
        case "architecture":
            currentArchitecture = Architecture()
        case "pricing":
            currentPricing = Pricing()
        case "top_provider":
            currentTopProvider = TopProvider()
        case "provider":
            // 不需要特殊处理,因为我们只需要获取内容
            break
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "category":
            if let category = currentCategory {
                modelCategories.append(category)
                currentCategory = nil
            }
        case "model":
            if let model = currentModel {
                currentCategory?.models.append(model)
                currentModel = nil
            }
        case "architecture":
            currentModel?.architecture = currentArchitecture
            currentArchitecture = nil
        case "pricing":
            currentModel?.pricing = currentPricing
            currentPricing = nil
        case "top_provider":
            currentModel?.topProvider = currentTopProvider
            currentTopProvider = nil
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !data.isEmpty else { return }
        
        switch currentElement {
        case "name":
            currentModel?.name = data
        case "description":
            currentModel?.description = data
        case "context_length":
            if let contextLength = Int(data) {
                currentModel?.contextLength = contextLength
                currentTopProvider?.contextLength = contextLength
            }
        case "modality":
            currentArchitecture?.modality = data
        case "tokenizer":
            currentArchitecture?.tokenizer = data
        case "instruct_type":
            currentArchitecture?.instructType = data
        case "prompt":
            currentPricing?.prompt = Double(data) ?? 0
        case "completion":
            currentPricing?.completion = Double(data) ?? 0
        case "image":
            currentPricing?.image = Double(data) ?? 0
        case "request":
            currentPricing?.request = Double(data) ?? 0
        case "max_completion_tokens":
            currentTopProvider?.maxCompletionTokens = Int(data) ?? 0
        case "is_moderated":
            currentTopProvider?.isModerated = (data.lowercased() == "true")
        case "provider":
            providers.append(data)  // 添加提供商到列表
        default:
            break
        }
    }
}

struct ModelCategory {
    var name: String
    var provider: String
    var models: [Model]
}

struct Model: Identifiable {
    var id: String { name }
    var name: String = ""
    var description: String = ""
    var contextLength: Int = 0
    var architecture: Architecture?
    var pricing: Pricing?
    var topProvider: TopProvider?
}

struct Architecture {
    var modality: String = ""
    var tokenizer: String = ""
    var instructType: String = ""
}

struct Pricing {
    var prompt: Double = 0
    var completion: Double = 0
    var image: Double = 0
    var request: Double = 0
}

struct TopProvider {
    var contextLength: Int = 0
    var maxCompletionTokens: Int = 0
    var isModerated: Bool = false
}

