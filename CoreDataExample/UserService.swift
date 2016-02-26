//
//  UserService.swift
//  CoreDataExample
//
//  Created by Kazutoshi Baba on 1/12/16.
//  Copyright © 2016 Kazutoshi Baba. All rights reserved.
//

import Foundation
import CoreData

public class UserService {
    let managedObjectContext: NSManagedObjectContext
    let coreDataStack: CoreDataStack
    
    public init(managedObjectContext: NSManagedObjectContext, coreDataStack: CoreDataStack) {
        self.managedObjectContext = managedObjectContext
        self.coreDataStack = coreDataStack
    }
    
    public func addUser(name: String, phoneNumber: String) -> User? {
        let user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: managedObjectContext) as! User
        user.fullName = name
        user.phoneNumber = phoneNumber
        
        coreDataStack.saveContext(managedObjectContext)
        
        return user
    }
    
    public func deleteUser(name: String) {
        if let user = getUser(name) {
            managedObjectContext.deleteObject(user)
            coreDataStack.saveContext(managedObjectContext)
        }
    }
    
    public func getUser(name: String) -> User? {
        let fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "fullName == %@", name)
        let results: [AnyObject]?
        do {
            results = try managedObjectContext.executeFetchRequest(fetchRequest)
        } catch {
            return nil
        }
        
        return results!.first as! User?
    }
}