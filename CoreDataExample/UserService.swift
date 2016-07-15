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
    
    @discardableResult
    public func addUser(_ name: String, phoneNumber: String) -> User? {
        let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: managedObjectContext) as! User
        user.fullName = name
        user.phoneNumber = phoneNumber
        
        coreDataStack.saveContext(managedObjectContext)
        
        return user
    }
    
    public func deleteUser(_ name: String) {
        if let user = getUser(name) {
            managedObjectContext.delete(user)
            coreDataStack.saveContext(managedObjectContext)
        }
    }
    
    public func getUser(_ name: String) -> User? {
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        fetchRequest.predicate = Predicate(format: "fullName == %@", name)
        let results: [AnyObject]?
        do {
            results = try managedObjectContext.fetch(fetchRequest)
        } catch {
            return nil
        }
        
        return results!.first as! User?
    }
}
