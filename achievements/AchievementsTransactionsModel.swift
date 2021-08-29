//
//  AchievementsTransactionsModel.swift
//  achievements
//
//  Created by Maximilian Schluer on 29.08.21.
//

import Foundation
import CoreData

class AchievementsTransactionsModel {
    private let persistentContainer : NSPersistentContainer
    
    init() {
        self.persistentContainer = NSPersistentContainer(name: "AchievementsDataModel")
        self.persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error: \(error)")
            }
        }
    }
    
    var viewContext : NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    var achievementTransactions : [AchievementTransaction] {
        let request : NSFetchRequest<AchievementTransaction> = AchievementTransaction.fetchRequest()
        return try! viewContext.fetch(request)
    }
    
    func createAchievementTransaction() -> AchievementTransaction {
        return NSEntityDescription.insertNewObject(forEntityName: AchievementTransaction.entityName, into: self.viewContext) as! AchievementTransaction
    }
    
    func save() {
        assert(Thread.isMainThread)
        do {
            try self.viewContext.save()
        } catch let error {
            NSLog("%@", "An error occured when saving: \(error)")
        }
    }
}
