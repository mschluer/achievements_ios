//
//  AchievementTransactionsModel.swift
//  achievements
//
//  Created by Maximilian Schluer on 29.08.21.
//

import Foundation
import CoreData
import UIKit

class AchievementsDataModel {
    private let persistentContainer : NSPersistentContainer
    
    // MARK: Variables
    var achievementTransactions : [AchievementTransaction] {
        if(Settings.applicationSettings.automaticPurge) {
            purgeRecent()
        }
        
        let request : NSFetchRequest<AchievementTransaction> = AchievementTransaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return try! viewContext.fetch(request)
    }
    var groupedAchievementTransactions : [Date: [AchievementTransaction]] {
        let transactions = achievementTransactions
        
        var result = [Date: [AchievementTransaction]]()
        
        for transaction in transactions {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: transaction.date!)
            let date = Calendar.current.date(from: components)
            
            var dateEntry = result[date!] ?? []
            dateEntry.append(transaction)
            result[date!] = dateEntry
        }
        
        return result
    }
    var groupedHistoricalTransactions : [Date: [HistoricalTransaction]] {
        let transactions = historicalTransactions
        
        var result = [Date: [HistoricalTransaction]]()
        
        for transaction in transactions {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: transaction.date!)
            let date = Calendar.current.date(from: components)
            
            var dateEntry = result[date!] ?? []
            dateEntry.append(transaction)
            result[date!] = dateEntry
        }
        
        return result
    }
    var historicalExpenses : [HistoricalTransaction] {
        let fetchRequest : NSFetchRequest<HistoricalTransaction> = HistoricalTransaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "amount < 0")
        return try! self.viewContext.fetch(fetchRequest)
    }
    var historicalIncomes : [HistoricalTransaction] {
        let fetchRequest : NSFetchRequest<HistoricalTransaction> = HistoricalTransaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "amount >= 0")
        return try! self.viewContext.fetch(fetchRequest)
    }
    var historicalTransactions : [HistoricalTransaction] {
        let request : NSFetchRequest<HistoricalTransaction> = HistoricalTransaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return try! viewContext.fetch(request)
    }
    var historicalTransactionsReverse: [HistoricalTransaction] {
        let request : NSFetchRequest<HistoricalTransaction> = HistoricalTransaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return try! viewContext.fetch(request)
    }
    var incomeTemplates: [TransactionTemplate] {
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        request.predicate = NSPredicate(format: "amount >= 0")
        return try! self.viewContext.fetch(request)
    }
    var nonRecurringExpenseTemplates: [TransactionTemplate] {
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "recurring = false && amount < 0")
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        return try! self.viewContext.fetch(request)
    }
    var nonRecurringIncomeTemplates: [TransactionTemplate] {
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "recurring = false && amount >= 0")
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        return try! self.viewContext.fetch(request)
    }
    var plannedExpenses: [TransactionTemplate] {
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "amount < 0")
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        return try! self.viewContext.fetch(request)
    }
    var recentExpenses : [AchievementTransaction] {
        let fetchRequest : NSFetchRequest<AchievementTransaction> = AchievementTransaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "amount < 0")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return try! self.viewContext.fetch(fetchRequest)
    }
    var recentIncomes : [AchievementTransaction] {
        let fetchRequest : NSFetchRequest<AchievementTransaction> = AchievementTransaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "amount >= 0")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return try! self.viewContext.fetch(fetchRequest)
    }
    var recurringExpenseTemplates: [TransactionTemplate] {
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "recurring = true && amount < 0")
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        return try! self.viewContext.fetch(request)
    }
    var recurringIncomeTemplates: [TransactionTemplate] {
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "recurring = true && amount >= 0")
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        return try! self.viewContext.fetch(request)
    }
    var totalHistoricalExpenses : Float {
        var result : Float = 0
        for expense in historicalExpenses {
            result += expense.amount
        }
        return result
    }
    var totalHistoricalIncomes : Float {
        var result : Float = 0
        for income in historicalIncomes {
            result += income.amount
        }
        return result
    }
    var totalRecentExpenses : Float {
        var result : Float = 0
        for expense in recentExpenses {
            result += expense.amount
        }
        return result
    }
    var totalRecentIncomes : Float {
        var result : Float = 0
        for income in recentIncomes {
            result += income.amount
        }
        return result
    }
    var transactionTemplates: [TransactionTemplate] {
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true)]
        return try! viewContext.fetch(request)
    }
    var viewContext : NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    // MARK: Initializers
    init() {
        self.persistentContainer = NSPersistentContainer(name: "AchievementsDataModel")
        self.persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error: \(error)")
            }
        }
    }
    
    // MARK: Public Functions
    public func createAchievementTransaction() -> AchievementTransaction {
        return NSEntityDescription.insertNewObject(forEntityName: AchievementTransaction.entityName, into: self.viewContext) as! AchievementTransaction
    }
    
    public func createAchievementTransactionWith(text: String, amount: Float, date: Date) -> AchievementTransaction {
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
    
    public func createHistoricalTransaction() -> HistoricalTransaction {
        return NSEntityDescription.insertNewObject(forEntityName: HistoricalTransaction.entityName, into: self.viewContext) as! HistoricalTransaction
    }
    
    public func createTransactionTemplate() -> TransactionTemplate {
        return NSEntityDescription.insertNewObject(forEntityName: TransactionTemplate.entityName, into: self.viewContext) as! TransactionTemplate
    }
    
    public func duplicateDatabase(to path: String)  {
        // Taken and adapted from https://oleb.net/blog/2018/03/core-data-sqlite-backup/
        do {
            let sourceStore = self.persistentContainer
                                 .persistentStoreCoordinator
                                 .persistentStores[0]
            let backupCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.persistentContainer.managedObjectModel)
            
            let intermediateStoreOptions = (sourceStore.options ?? [:]).merging([NSReadOnlyPersistentStoreOption: true], uniquingKeysWith: { $1 })
            let intermediateStore = try backupCoordinator.addPersistentStore(
                ofType: sourceStore.type,
                configurationName: sourceStore.configurationName,
                at: sourceStore.url,
                options: intermediateStoreOptions)
            
            let backupStoreOptions : [AnyHashable : Any] = [
                NSReadOnlyPersistentStoreOption: true,                  // Disable Write Ahead Logging -> Everything written to one file
                NSSQLitePragmasOption: ["journal_mode": "DELETE"],      // Minimize File Size
                NSSQLiteManualVacuumOption: true,
            ]
            
            
            _ = try backupCoordinator.migratePersistentStore(
                intermediateStore,
                to: NSURL(fileURLWithPath: path, isDirectory: false) as URL,
                options: backupStoreOptions,
                type: .sqlite)
        } catch let error {
            print("Duplicating Database failed due to error: \(error.localizedDescription)")
        }
    }
    
    public func rearrangeTransactionTemplates(template: TransactionTemplate, destinationIndex: Int) {
        reindexPlannedExpenses()
        reindexPlannedIncomes()
        
        // Push forward
        if template.amount < 0 {
            let expenses = plannedExpenses
            if destinationIndex < plannedExpenses.count {
                for i in destinationIndex...(expenses.count - 1) {
                    expenses[i].orderIndex += 1
                }
            }
        } else {
            let incomes = transactionTemplates
            if destinationIndex < transactionTemplates.count {
                for i in destinationIndex...(incomes.count - 1) {
                    incomes[i].orderIndex += 1
                }
            }
        }
        
        // Insert
        template.orderIndex = Int16(destinationIndex)
        save()
    }
    
    public func recalculateHistoricalBalances(from beginIndex: Int?) {
        var i = 0
        if beginIndex != nil {
            i = beginIndex!
        }
        
        var currentBalance : Float = 0
        if i > 0 {
            currentBalance = historicalTransactionsReverse[i - 1].balance
        }
        
        while i < historicalTransactions.count {
            currentBalance = historicalTransactionsReverse[i].calculateHistoricalBalance(balanceBefore: currentBalance)
            historicalTransactionsReverse[i].balance = currentBalance
            
            i += 1
        }
    }
    
    public func recalculateHistoricalBalances(from element: HistoricalTransaction?) {
        if element != nil {
            recalculateHistoricalBalances(from: historicalTransactionsReverse.firstIndex(of: element!))
        } else {
            recalculateHistoricalBalances(from: 0)
        }
    }
    
    public func reindexPlannedExpenses() {
        let expenses = plannedExpenses
        if expenses.count < 1 {
            return
        }
        
        for i in 0...expenses.count - 1 {
            expenses[i].orderIndex = Int16(i)
        }
        
        save()
    }
    
    public func reindexPlannedIncomes() {
        let incomes = incomeTemplates
        if incomes.count < 1 {
            return
        }
        
        for i in 0...incomes.count - 1 {
            incomes[i].orderIndex = Int16(i)
        }
        
        save()
    }
    
    public func replaceDatabase(from path: String) {
        do {
            let persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
            let originalStore = persistentStoreCoordinator.persistentStores[0]
            let originalUrl = originalStore.url!
            let backupStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: persistentStoreCoordinator.managedObjectModel)
            
            // Prepare Restore Database
            let restoreOptions = originalStore.options
            let intermediateStore = try backupStoreCoordinator.addPersistentStore(
                ofType: originalStore.type,
                configurationName: originalStore.configurationName,
                at: URL(string: "file://\(path)"),
                options: restoreOptions)
            
            // Destroy Original One
            try persistentStoreCoordinator.destroyPersistentStore(at: originalUrl,
                                                                 type: NSPersistentStore.StoreType(rawValue: NSSQLiteStoreType),
                                                                 options: nil)
            
            // Install Restored One
            _ = try backupStoreCoordinator.migratePersistentStore(
                intermediateStore,
                to: originalUrl,
                options: restoreOptions,
                type: .sqlite)
            
            // Refresh Data
            self.persistentContainer.loadPersistentStores { storeDescription, error in
                if let error = error {
                    print("Database cannot be loaded due to unresolved error: \(error)")
                }
            }
        } catch let error {
            print("Replacing Database was not possible due to error: \(error.localizedDescription)")
        }
    }
    
    public func save() {
        assert(Thread.isMainThread)
        do {
            try self.viewContext.save()
        } catch let error {
            NSLog("%@", "An error occured when saving: \(error)")
        }
    }
    
    public func sortPlannedExpenses(by sortDescriptors : [NSSortDescriptor]) {
        // Fetch
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.sortDescriptors = sortDescriptors
        request.predicate = NSPredicate(format: "amount < 0")
        let plannedExpenses = try! self.viewContext.fetch(request)
        
        // Check for emptiness
        if plannedExpenses.count == 0 {
            return
        }
        
        // Order
        for i in 0...plannedExpenses.count - 1 {
            plannedExpenses[i].orderIndex = Int16(i)
        }
        
        // Save
        self.save()
    }
    
    public func sortPlannedIncomes(by sortDescriptors : [NSSortDescriptor]) {
        // Fetch
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.sortDescriptors = sortDescriptors
        request.predicate = NSPredicate(format: "amount >= 0")
        let plannedIncomes = try! self.viewContext.fetch(request)
        
        // Check for emptiness
        if plannedIncomes.count == 0 {
            return
        }
        
        // Order
        for i in 0...plannedIncomes.count - 1 {
            plannedIncomes[i].orderIndex = Int16(i)
        }
        
        // Save
        self.save()
    }
    
    // MARK: Destructive Transactions
    public func clear() {
        guard let url = persistentContainer.persistentStoreDescriptions.first?.url else { return }
        
        let persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        
        do {
            try persistentStoreCoordinator.destroyPersistentStore(at: url,
                                                                 type: NSPersistentStore.StoreType(rawValue: NSSQLiteStoreType),
                                                                 options: nil)
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                             configurationName: nil,
                                                             at: url,
                                                             options: nil)
            
        } catch let error {
            print("Clearing database resulted in error: \(error.localizedDescription)")
        }
    }
    
    func purgeRecent() {
        let fetchRequest : NSFetchRequest<AchievementTransaction> = AchievementTransaction.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        fetchRequest.predicate = NSPredicate(format: "amount >= 0")
        var recentIncomes = try! self.viewContext.fetch(fetchRequest)
        var totalIncomes = totalRecentIncomes
        
        fetchRequest.predicate = NSPredicate(format: "amount < 0")
        var recentExpenses = try! self.viewContext.fetch(fetchRequest)
        
        while recentExpenses.count > 0 && -1 * recentExpenses[0].amount <= totalIncomes {
            var remainingAmount = -1 * recentExpenses[0].amount
            self.remove(achievementTransaction: recentExpenses[0])
            recentExpenses.remove(at: 0)
            
            while remainingAmount > 0 {
                totalIncomes -= recentIncomes[0].amount
                remainingAmount -= recentIncomes[0].amount
                
                if remainingAmount < 0 {
                    recentIncomes[0].amount = -1 * remainingAmount
                } else {
                    self.remove(achievementTransaction: recentIncomes[0])
                    recentIncomes.remove(at: 0)
                }
            }
        }
        
        self.save()
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
    
    func remove(transactionTemplate template: TransactionTemplate) {
        self.viewContext.delete(template)
    }
}
