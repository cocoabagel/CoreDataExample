//
//  TestCoreDataStack.swift
//  CoreDataExample
//
//  Created by Kazutoshi Baba on 1/12/16.
//  Copyright © 2016 Kazutoshi Baba. All rights reserved.
//

import CoreDataExample
import Foundation
import CoreData

class TestCoreDataStack: CoreDataStack {
    override init() {
        super.init()
        self.persistentStoreCoordinator = {
            let psc = NSPersistentStoreCoordinator(
                managedObjectModel: self.managedObjectModel)
            
            do {
                try psc.addPersistentStore(
                    ofType: NSInMemoryStoreType, configurationName: nil,
                    at: nil, options: nil)
            } catch {
                fatalError()
            }
            
            return psc
        }()
    }
}
