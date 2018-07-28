//
//  CoreDataStack.swift
//  MultiPeer
//
//  Created by Maxime Moison on 7/27/18.
//  Copyright © 2018 Maxime Moison. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    
    // MARK: - Container
    
    static var container:NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    // MARK: - Contexts
    
    static var mainContext:NSManagedObjectContext {
        return container.viewContext
    }
    
    static func newChildContext(withName name: String) -> NSManagedObjectContext {
        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        childContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        childContext.name = name
        childContext.parent = mainContext
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave,
                                               object: childContext,
                                               queue: nil,
                                               using: childContextDidSave)
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextWillSave,
                                               object: childContext,
                                               queue: nil,
                                               using: childContextWillSave)
        return childContext
    }
    
    
    // MARK: - Context saves
    
    private static func childContextWillSave(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext,
            context.parent == mainContext else { return }
        // Implement the logic when a child context will save
    }
    
    private static func childContextDidSave(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext,
            context.parent == mainContext else { return }
        // Implement the logic when a child context did save
        
        let contextChanges = [
            "inserted": Array(mainContext.insertedObjects),
            "updated": Array(mainContext.updatedObjects),
            "deleted": Array(mainContext.deletedObjects)
        ]
        
        mainContext.performAndWait {
            try? mainContext.save()
        }
        
        mainContextDidSave(withChanges: contextChanges)
    }
    
    private static func mainContextDidSave(withChanges changes: [String: [NSManagedObject]]=[:]) {
        for (_, handler) in contextChangeListeners {
            handler(changes)
        }
    }
    
    
    // MARK: - Change Listeners
    
    private static var contextChangeListeners:[NSObject: ([String: [NSManagedObject]])->()] = [:]
    
    static func addChangeListener(forListener listener: NSObject, handler: @escaping ([String: [NSManagedObject]])->()) {
        contextChangeListeners[listener] = handler
    }
    static func removeChangeListener(forListener listener: NSObject) {
        contextChangeListeners.removeValue(forKey: listener)
    }
    
}











// MARK: - TO DELETE

extension CoreDataStack {
    static func clearStore() {
        // Initialize Fetch Request
        let context = newChildContext(withName: "clear_all_items")
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ColoredItem")
        
        // Configure Fetch Request
        fetchRequest.includesPropertyValues = false
        
        do {
            let items = try context.fetch(fetchRequest) as! [NSManagedObject]
            
            for item in items {
                context.delete(item)
            }
            
            // Save Changes
            try context.save()
            
        } catch {
            // Error Handling
            // ...
        }
    }
}
