//
//  Persistence.swift
//  gptexpir
//
//  Created by lixindong on 2023/2/20.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    static let memoryContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    static var sharedContext: NSManagedObjectContext {
        shared.container.viewContext
    }

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = GPTConversation(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "gptexpir")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func loadConversations() -> [GPTConversation] {
        // 获取 NSManagedObjectContext 实例
        let context = container.viewContext
        
        // 创建一个 NSFetchRequest 实例，并指定要获取的数据类
        let fetchRequest: NSFetchRequest<GPTConversation> = GPTConversation.fetchRequest()
        
        // 按最后修改时间排序
        let sortDescriptor = NSSortDescriptor(key: "timestamp_", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        // 执行查询
        do {
            let conversations = try context.fetch(fetchRequest)
            return conversations
        } catch {
            print("Error fetching conversations: \(error)")
            return []
        }
    }

    func deleteConversation(conversation: GPTConversation) {
        let viewContext = container.viewContext
        viewContext.delete(conversation)
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func addConvasation() {
        let viewContext = container.viewContext
        let newItem = GPTConversation(context: viewContext)
        newItem.uuid = UUID()
        newItem.name = ""
        newItem.prompt = ""
        newItem.desc = ""
        newItem.icon = ""
        newItem.shortcut = ""
        newItem.timestamp = Date()
        newItem.own = []
        do {
            print("try")
            try viewContext.save()
        } catch {
            print("catch")
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func updateConvasationInfo(conversation: GPTConversation, id: UUID? = nil, name: String? = nil, prompt: String? = nil, desc: String? = nil, icon: String? = nil, shortcut: String? = nil, timestamp: Date? = nil, own: [GPTAnswer]? = nil) {
        let viewContext = container.viewContext
        
        if let id = id {
            conversation.uuid = id
        }
        if let name = name {
            conversation.name = name
        }
        if let prompt = prompt {
            conversation.prompt = prompt
        }
        if let desc = desc {
            conversation.desc = desc
        }
        if let icon = icon {
            conversation.icon = icon
        }
        if let shortcut = shortcut {
            conversation.shortcut = shortcut
        }
        if let timestamp = timestamp {
            conversation.timestamp = timestamp
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func addAnswer(conversation: GPTConversation, role: String, response: String, prompt: String, parentId: UUID? = nil, contextClearedAfterThis: Bool = false) {
        let viewContext = container.viewContext
        let newItem = GPTAnswer(context: viewContext)
        newItem.uuid = UUID()
        newItem.role = role
        newItem.response = response
        newItem.prompt = prompt
        newItem.parentMessageId = parentId
        newItem.contextClearedAfterThis = contextClearedAfterThis
        newItem.prompt = prompt
        newItem.timestamp = Date()
        newItem.belongsTo = conversation
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func clearContext(conversation: GPTConversation) {
        let viewContext = container.viewContext
        if let answer = conversation.own?.array.last as? GPTAnswer {
            answer.contextClearedAfterThis = true
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func clearAnswers(conversation: GPTConversation) {
        let viewContext = container.viewContext
        conversation.own?.array.forEach({ item in
            if let item = item as? GPTAnswer {
                viewContext.delete(item)
            }
        })
        conversation.own = []
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
