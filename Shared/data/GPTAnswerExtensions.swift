//
//  GPTAnswerExtensions.swift
//  Found
//
//  Created by lixindong on 2023/4/25.
//

import Foundation
import CoreData

extension GPTAnswer {
    var uuid: UUID {
        get { return uuid_ ?? UUID() }
        set { uuid_ = newValue }
    }
    var parentMessageId: UUID? {
        get { return parentMessageId_ }
        set { parentMessageId_ = newValue }
    }
    var role: String {
        get { return role_ ?? "" }
        set { role_ = newValue }
    }
    var prompt: String {
        get { return prompt_ ?? "" }
        set { prompt_ = newValue }
    }
    var response: String {
        get { return response_ ?? "" }
        set { response_ = newValue }
    }
    var timestamp: Date {
        get { return timestamp_ ?? Date() }
        set { timestamp_ = newValue }
    }
    var contextClearedAfterThis: Bool {
        get { return contextClearedAfterThis_ }
        set { contextClearedAfterThis_ = newValue }
    }
    
    convenience init(role: String = "", prompt: String = "", response: String = "", timestamp: Date = Date(), contextClearedAfterThis: Bool = false, parentId: UUID? = nil, context: NSManagedObjectContext = PersistenceController.memoryContext) {
        self.init(context: context)
        self.uuid = UUID()
        self.role = role
        self.prompt = prompt
        self.response = response
        self.timestamp = timestamp
        self.contextClearedAfterThis = contextClearedAfterThis
        self.parentMessageId = parentId
    }
}
