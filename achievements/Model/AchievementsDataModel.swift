//
//  AchievementTransactionsModel.swift
//  achievements
//
//  Created by Maximilian Schluer on 29.08.21.
//

import Foundation
import CoreData

class AchievementsDataModel {
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
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return try! viewContext.fetch(request)
    }
    
    var historicalTransactions : [HistoricalTransaction] {
        let request : NSFetchRequest<HistoricalTransaction> = HistoricalTransaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return try! viewContext.fetch(request)
    }
    
    func createAchievementTransaction() -> AchievementTransaction {
        return NSEntityDescription.insertNewObject(forEntityName: AchievementTransaction.entityName, into: self.viewContext) as! AchievementTransaction
    }
    
    func createHistoricalTransaction() -> HistoricalTransaction {
        return NSEntityDescription.insertNewObject(forEntityName: HistoricalTransaction.entityName, into: self.viewContext) as! HistoricalTransaction
    }
    
    func createAchievementTransactionWith(text: String, amount: Float, date: Date) -> AchievementTransaction {
        // Prepare Transaction
        let transaction = createAchievementTransaction()
        transaction.text = text
        transaction.amount = amount
        transaction.date = date
        
        // Prepare History-Item
        let historicalTransaction = createHistoricalTransaction()
        historicalTransaction.text = text
        historicalTransaction.amount = amount
        historicalTransaction.date = date
        
        // Establish Link
        transaction.historicalTransaction = historicalTransaction
        historicalTransaction.recentTransaction = transaction
        
        self.recalculateHistoricalBalances(from: historicalTransaction)
        
        // Save
        self.save()
        
        return transaction
    }
    
    func remove(achievementTransaction transaction: AchievementTransaction) {
        self.viewContext.delete(transaction)
    }
    
    func remove(historicalTransaction transaction: HistoricalTransaction) {
        // Remove Recent Item to prevent Items without history
        if let recentTransaction = transaction.recentTransaction {
            self.viewContext.delete(recentTransaction)
        }
        
        let index = historicalTransactions.firstIndex(of: transaction)
        
        self.viewContext.delete(transaction)
        
        recalculateHistoricalBalances(from: index)
        
        self.save()
    }
    
    func clear() {
        let request = NSBatchDeleteRequest(fetchRequest: AchievementTransaction.fetchRequest())
        
        try! viewContext.execute(request)
    }
    
    func save() {
        assert(Thread.isMainThread)
        do {
            try self.viewContext.save()
        } catch let error {
            NSLog("%@", "An error occured when saving: \(error)")
        }
    }
    
    func recalculateHistoricalBalances(from element: HistoricalTransaction?) {
        if element != nil {
            recalculateHistoricalBalances(from: historicalTransactions.firstIndex(of: element!))
        } else {
            recalculateHistoricalBalances(from: 0)
        }
    }
    
    func recalculateHistoricalBalances(from beginIndex: Int?) {
        var i = 0
        if beginIndex != nil {
            i = beginIndex!
            if i > 0 {
                i -= 1
            }
        }
        
        var currentBalance : Float = 0
        if i > 0 {
            currentBalance = historicalTransactions[i].balance
        }
        
        while i < historicalTransactions.count {
            currentBalance = historicalTransactions[i].calculateHistoricalBalance(balanceBefore: currentBalance)
            historicalTransactions[i].balance = currentBalance
            
            i += 1
        }
    }
}
