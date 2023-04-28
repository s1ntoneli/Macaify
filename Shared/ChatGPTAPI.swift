//
//  ChatGPTAPI.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import Foundation
import GPTEncoder

class ChatGPTAPI: @unchecked Sendable {
    
    private let gptEncoder = GPTEncoder()
    private var systemMessage: Message
    private let temperature: Double
    private let model: String
    
    private let apiKey: String
    private var historyList = [Message]()
    // 携带上下文
    var withContext: Bool

    private var baseURL: String
    private let urlSession = URLSession.shared
    private var urlRequest: URLRequest {
        get {
            let url = URL(string: "\(baseURL)/v1/chat/completions")!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            headers.forEach {  urlRequest.setValue($1, forHTTPHeaderField: $0) }
            return urlRequest
        }
    }
    
    var systemPrompt: String {
        get { systemMessage.content }
        set { systemMessage = .init(role: "system", content: newValue) }
    }
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd"
        return df
    }()
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
    
    private var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
    

    init(apiKey: String, model: String = "gpt-3.5-turbo", systemPrompt: String = "You are a helpful assistant", temperature: Double = 0.5, baseURL: String? = nil, withContext: Bool = true) {
        self.apiKey = apiKey
        self.model = model
        self.systemMessage = .init(role: "system", content: systemPrompt)
        self.temperature = temperature
        self.withContext = withContext
        if let baseURL = baseURL {
            self.baseURL = baseURL
        } else {
            self.baseURL = "https://api.openai.com"
        }
    }
    
    func disableProxy() {
        self.baseURL = "https://api.openai.com"
    }
    
    func useProxy(proxy: String) {
        self.baseURL = proxy
    }
    
    var history: [Message] {
        get {
            historyList
        }
        set(newValue) {
            historyList.removeAll()
            historyList.append(contentsOf: newValue)
        }
    }
    
    private func generateMessages(from text: String) -> [Message] {
        var messages: [Message] = []
        messages += [systemMessage]
        if withContext {
            messages += historyList
        }
        messages += [Message(role: "user", content: text)]
        
        let token =  messages.token
//        print("msg token \(token) \(messages)")
        if token > 4000 {
            if withContext && !historyList.isEmpty {
                _ = historyList.removeFirst()
                messages = generateMessages(from: text)
            } else {
                let lastIndex = max(1, text.count - 100)
                let start = text.index(text.startIndex, offsetBy: 0)
                let end = text.index(text.startIndex, offsetBy: max(0, text.count - 100))
                messages = generateMessages(from: String(text[start...end]))
            }
        }
        return messages
    }
    
    private func jsonBody(text: String, stream: Bool = true) throws -> Data {
        let msgs = generateMessages(from: text)
        print("messages","withContext \(withContext)", msgs)
        let request = Request(model: model, temperature: temperature,
                              messages: msgs, stream: stream)
        return try JSONEncoder().encode(request)
    }
    
    private func appendToHistoryList(userText: String, responseText: String) {
        self.historyList.append(.init(role: "user", content: userText))
        self.historyList.append(.init(role: "assistant", content: responseText))
    }
    
    func sendMessageStream(text: String) async throws -> AsyncThrowingStream<String, Error> {
        var urlRequest = self.urlRequest
        urlRequest.httpBody = try jsonBody(text: text)
        
        let (result, response) = try await urlSession.bytes(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw "Invalid response"
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            var errorText = ""
            for try await line in result.lines {
                errorText += line
            }
            
            if let data = errorText.data(using: .utf8), let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
                errorText = "\n\(errorResponse.message)"
            }
            
            throw "Bad Response: \(httpResponse.statusCode), \(errorText)"
        }
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                do {
                    var responseText = ""
                    for try await line in result.lines {
                        if line.hasPrefix("data: "),
                           let data = line.dropFirst(6).data(using: .utf8),
                           let response = try? self.jsonDecoder.decode(StreamCompletionResponse.self, from: data),
                           let text = response.choices.first?.delta.content {
                            responseText += text
                            continuation.yield(text)
                        }
                    }
                    self.appendToHistoryList(userText: text, responseText: responseText)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    func sendMessage(_ text: String) async throws -> String {
        var urlRequest = self.urlRequest
        urlRequest.httpBody = try jsonBody(text: text, stream: false)
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw "Invalid response"
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            var error = "Bad Response: \(httpResponse.statusCode)"
            if let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
                error.append("\n\(errorResponse.message)")
            }
            throw error
        }
        
        do {
            let completionResponse = try self.jsonDecoder.decode(CompletionResponse.self, from: data)
            let responseText = completionResponse.choices.first?.message.content ?? ""
            self.appendToHistoryList(userText: text, responseText: responseText)
            return responseText
        } catch {
            throw error
        }
    }
    
    func deleteHistoryList() {
        self.historyList.removeAll()
    }
}

extension String: CustomNSError {
    
    public var errorUserInfo: [String : Any] {
        [
            NSLocalizedDescriptionKey: self
        ]
    }
}


