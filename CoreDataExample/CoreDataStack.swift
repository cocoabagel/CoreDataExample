//
//  CoreDataStack.swift
//  CoreDataExample
//
//  Created by Kazutoshi Baba on 1/12/16.
//  Copyright © 2016 Kazutoshi Baba. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataStack {
    
    public init() {
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public var managedObjectModel: NSManagedObjectModel = {
        var modelPath = NSBundle.mainBundle().pathForResource("CoreDataExample", ofType: "momd")
        var modelURL = NSURL.fileURLWithPath(modelPath!)
        var model = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        return model
    }()
    
    var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        print("Providing SQLite persistent store coordinator")
        
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("CoreDataExample.sqlite")
        var options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        
        var psc = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        do {
            try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL: url, options: options)
        } catch {
            print("Error when creating persistent store \(error)")
            fatalError()
        }
        
        return psc
    }()
    
    public lazy var rootContext: NSManagedObjectContext = {
        let context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }()
    
    public lazy var mainContext: NSManagedObjectContext = {
        let mainContext: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        mainContext.parentContext = self.rootContext
        mainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mainContextDidSave:", name: NSManagedObjectContextDidSaveNotification, object: mainContext)
        
        return mainContext
    }()
    
    public func newDerivedContext() -> NSManagedObjectContext {
        let context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.parentContext = self.mainContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }
    
    public func saveContext(context: NSManagedObjectContext) {
        if context.parentContext === self.mainContext {
            self.saveDerivedContext(context)
            return
        }
        
        context.performBlock() {
            do {
                try context.obtainPermanentIDsForObjects(Array(context.insertedObjects))
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
    
    public func saveDerivedContext(context: NSManagedObjectContext) {
        context.performBlock() {
            do {
                try context.obtainPermanentIDsForObjects(Array(context.insertedObjects))
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
    
    @objc func mainContextDidSave(notification: NSNotification) {
        self.saveContext(self.rootContext)
    }
    
}
