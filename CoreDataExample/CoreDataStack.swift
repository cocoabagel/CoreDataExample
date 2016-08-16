//
//  CoreDataStack.swift
//  CoreDataExample
//
//  Created by Kazutoshi Baba on 1/12/16.
//  Copyright © 2016 Kazutoshi Baba. All rights reserved.
//

import Foundation
import CoreData

open class CoreDataStack {
    
    public init() {
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public var managedObjectModel: NSManagedObjectModel = {
        var modelPath = Bundle.main.path(forResource: "CoreDataExample", ofType: "momd")
        var modelURL = URL(fileURLWithPath: modelPath!)
        var model = NSManagedObjectModel(contentsOf: modelURL)!
        
        return model
    }()
    
    var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as URL
    }()
    
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        print("Providing SQLite persistent store coordinator")
        
        let url = self.applicationDocumentsDirectory.appendingPathComponent("CoreDataExample.sqlite")
        var options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        
        var psc = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName:nil, at: url, options: options)
        } catch {
            print("Error when creating persistent store \(error)")
            fatalError()
        }
        
        return psc
    }()
    
    public lazy var rootContext: NSManagedObjectContext = {
        let context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }()
    
    public lazy var mainContext: NSManagedObjectContext = {
        let mainContext: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        mainContext.parent = self.rootContext
        mainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        NotificationCenter.default.addObserver(self, selector: #selector(CoreDataStack.mainContextDidSave(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: mainContext)
        
        return mainContext
    }()
    
    public func newDerivedContext() -> NSManagedObjectContext {
        let context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.mainContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }
    
    public func saveContext(_ context: NSManagedObjectContext) {
        if context.parent === self.mainContext {
            self.saveDerivedContext(context)
            return
        }
        
        context.perform() {
            do {
                try context.obtainPermanentIDs(for: Array(context.insertedObjects))
            } catch {
                print("Error obtaining permanent IDs for \(context.insertedObjects), \(error)")
            }
            
            do {
                try context.save()
            } catch {
                print("Unresolved core data error: \(error)")
                abort()
            }
        }
    }
    
    public func saveDerivedContext(_ context: NSManagedObjectContext) {
        context.perform() {
            do {
                try context.obtainPermanentIDs(for: Array(context.insertedObjects))
            } catch {
                print("Error obtaining permanent IDs for \(context.insertedObjects), \(error)")
            }
            
            do {
                try context.save()
            } catch {
                print("Unresolved core data error: \(error)")
                abort()
            }
            
            self.saveContext(self.mainContext)
        }
    }
    
    @objc func mainContextDidSave(_ notification: Notification) {
        self.saveContext(self.rootContext)
    }
    
}
