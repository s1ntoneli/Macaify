//
//  GPTConversationExts.swift
//  Found
//
//  Created by lixindong on 2023/4/24.
//

import Foundation
import CoreData

extension GPTConversation {
    var uuid: UUID {
        get { return uuid_ ?? UUID() }
        set { uuid_ = newValue }
    }
    public var id: UUID {
        get { return uuid }
        set { uuid = newValue }
    }
    var name: String {
        get { return name_ ?? "" }
        set { name_ = newValue }
    }
    var prompt: String {
        get { return prompt_ ?? "" }
        set { prompt_ = newValue }
    }
    var desc: String {
        get { return desc_ ?? "" }
        set { desc_ = newValue }
    }
    var icon: String {
        get { return icon_ ?? "" }
        set { icon_ = newValue }
    }
    var shortcut: String {
        get { return shortcut_ ?? "" }
        set { shortcut_ = newValue }
    }
    var timestamp: Date {
        get { return timestamp_ ?? Date() }
        set { timestamp_ = newValue }
    }
    var autoAddSelectedText: Bool {
        get { return autoAddSelectedText_ }
        set { autoAddSelectedText_ = newValue }
    }
    var withContext: Bool {
        get { return withContext_ }
        set { withContext_ = newValue }
    }
    var own: [GPTAnswer] {
        get {
            return (own_?.array ?? []) as! [GPTAnswer]
        }
        set {
            own_ = NSOrderedSet(array: newValue)
        }
    }
    
    convenience init(_ name: String, id: UUID = UUID(), prompt: String = "", desc: String = "", icon: String = "", shortcut: String = "", timestamp: Date = Date(), autoAddSelectedText: Bool = false, withContext: Bool = true, context: NSManagedObjectContext = PersistenceController.memoryContext) {
        self.init(context: context)
        self.name = name
        self.uuid = uuid
        self.prompt = prompt
        self.desc = desc
        self.icon = icon
        self.shortcut = shortcut
        self.timestamp = timestamp
        self.autoAddSelectedText = autoAddSelectedText
        self.withContext = withContext
    }

    func copy(name: String? = nil,
             id: UUID? = nil,
             prompt: String? = nil,
             desc: String? = nil,
             icon: String? = nil,
             shortcut: String? = nil,
             timestamp: Date? = nil,
             autoAddSelectedText: Bool? = nil,
             withContext: Bool? = nil,
             context: NSManagedObjectContext? = nil) -> GPTConversation {
        let name = name ?? self.name
        let id = id ?? self.id
        let prompt = prompt ?? self.prompt
        let desc = desc ?? self.desc
        let icon = icon ?? self.icon
        let shortcut = shortcut ?? self.shortcut
        let timestamp = timestamp ?? self.timestamp
        let autoAddSelectedText = autoAddSelectedText ?? self.autoAddSelectedText
        let withContext = withContext ?? self.withContext
        let context = context ?? self.managedObjectContext!
        return GPTConversation(name, id: id, prompt: prompt, desc: desc, icon: icon, shortcut: shortcut, timestamp: timestamp, autoAddSelectedText: autoAddSelectedText, withContext: withContext, context: context)
    }
    func copyToCoreData() -> GPTConversation {
        return copy(context: PersistenceController.sharedContext)
    }

    func copyToMemory() -> GPTConversation {
        return copy(context: PersistenceController.memoryContext)
    }

    func addAnswer(answer: GPTAnswer) {
        self.own.append(answer)
        answer.belongsTo = self
        save()
    }
    
    func save() {
        do {
            try managedObjectContext?.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    static var new: GPTConversation {
        get {
            GPTConversation(context: PersistenceController.memoryContext)
        }
    }
}
