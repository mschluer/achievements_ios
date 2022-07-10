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
    
    // MARK: Predicates
    let negativePredicate = NSPredicate(format: "amount < 0")
    let positivePredicate = NSPredicate(format: "amount >= 0")
    
    // MARK: Variables
    var achievementTransactions : [AchievementTransaction] {
        if(Settings.applicationSettings.automaticPurge) {
            purgeRecent()
        }
        
        let request : NSFetchRequest<AchievementTransaction> = AchievementTransaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("ERROR: Retrieving AchievementTransactions failed!")
            return []
        }
    }
    var expenseTemplates: [TransactionTemplate] {
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.predicate = negativePredicate
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        
        do {
            return try self.viewContext.fetch(request)
        } catch {
            print("ERROR: Retrieving Expense Templates Failed.")
            return []
        }
    }
    var groupedAchievementTransactions : [DateComponents: [AchievementTransaction]] {
        let transactions = achievementTransactions
        
        var result = [DateComponents: [AchievementTransaction]]()
        
        for transaction in transactions {
            let dateComponents = DateHelper.dateComponentsForDay(from: transaction.date!)
            
            var dateEntry = result[dateComponents] ?? []
            dateEntry.append(transaction)
            result[dateComponents] = dateEntry
        }
        
        return result
    }
    var groupedHistoricalTransactions : [DateComponents: [HistoricalTransaction]] {
        let transactions = historicalTransactions
        
        var result = [DateComponents: [HistoricalTransaction]]()
        
        for transaction in transactions {
            let dateComponents = DateHelper.dateComponentsForDay(from: transaction.date!)
            
            var dateEntry = result[dateComponents] ?? []
            dateEntry.append(transaction)
            result[dateComponents] = dateEntry
        }
        
        return result
    }
    var historicalExpenses : [HistoricalTransaction] {
        let fetchRequest : NSFetchRequest<HistoricalTransaction> = HistoricalTransaction.fetchRequest()
        fetchRequest.predicate = negativePredicate
        
        do {
            return try self.viewContext.fetch(fetchRequest)
        } catch {
            print("ERROR: Retrieving Historical Expenses Failed.")
            return []
        }
    }
    var historicalIncomes : [HistoricalTransaction] {
        let fetchRequest : NSFetchRequest<HistoricalTransaction> = HistoricalTransaction.fetchRequest()
        fetchRequest.predicate = positivePredicate
        
        do {
            return try self.viewContext.fetch(fetchRequest)
        } catch {
            print("ERROR: Retrieving Historical Incomes Failed.")
            return []
        }
    }
    var historicalTransactions : [HistoricalTransaction] {
        let request : NSFetchRequest<HistoricalTransaction> = HistoricalTransaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("ERROR: Retrieving Historical Transactions Failed.")
            return []
        }
    }
    var historicalTransactionsReverse: [HistoricalTransaction] {
        let request : NSFetchRequest<HistoricalTransaction> = HistoricalTransaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("ERROR: Retrieving Reversed Historical Transactions Failed.")
            return []
        }
    }
    var incomeTemplates: [TransactionTemplate] {
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        request.predicate = positivePredicate
        
        do {
            return try self.viewContext.fetch(request)
        } catch {
            print("ERROR: Retrieving Income Templates Failed.")
            return []
        }
    }
    var nonRecurringExpenseTemplates: [TransactionTemplate] {
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "recurring = false && amount < 0")
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        
        do {
            return try self.viewContext.fetch(request)
        } catch {
            print("ERROR: Retrieving Non Recurring Expense Templates Failed.")
            return []
        }
    }
    var nonRecurringIncomeTemplates: [TransactionTemplate] {
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "recurring = false && amount >= 0")
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        
        do {
            return try self.viewContext.fetch(request)
        } catch {
            print("ERROR: Retrieving Non Recurring Income Templates Failed.")
            return []
        }
    }
    var recentExpenses : [AchievementTransaction] {
        let fetchRequest : NSFetchRequest<AchievementTransaction> = AchievementTransaction.fetchRequest()
        fetchRequest.predicate = negativePredicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            return try self.viewContext.fetch(fetchRequest)
        } catch {
            print("ERROR: Retrieving Recent Expenses Failed.")
            return []
        }
    }
    var recentIncomes : [AchievementTransaction] {
        let fetchRequest : NSFetchRequest<AchievementTransaction> = AchievementTransaction.fetchRequest()
        fetchRequest.predicate = positivePredicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            return try self.viewContext.fetch(fetchRequest)
        } catch {
            print("ERROR: Retrieving Recent Incomes Failed.")
            return []
        }
    }
    var recurringExpenseTemplates: [TransactionTemplate] {
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "recurring = true && amount < 0")
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        
        do {
            return try self.viewContext.fetch(request)
        } catch {
            print("ERROR: Retreiving Recurring Expense Templates Failed.")
            return []
        }
    }
    var recurringIncomeTemplates: [TransactionTemplate] {
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "recurring = true && amount >= 0")
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        
        do {
            return try self.viewContext.fetch(request)
        } catch {
            print("ERROR: Retrieving Recurring Income Templates Failed.")
            return []
        }
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
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("ERROR: Retrieving Transaction Templates Failed.")
            return []
        }
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
        let insertIndex = insertIndex(historicalTransaction)
        
        // Establish Link
        transaction.historicalTransaction = historicalTransaction
        historicalTransaction.recentTransaction = transaction
        
        self.recalculateHistoricalBalances(from: insertIndex)
        
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
            let expenses = expenseTemplates
            if destinationIndex < expenseTemplates.count {
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
        var i = beginIndex ?? 0
        let transactions = historicalTransactionsReverse
        
        var currentBalance : Float = 0
        if i > 0 {
            currentBalance = transactions[i - 1].balance
        }
        
        while i < transactions.count {
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
        let expenses = expenseTemplates
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
    
    public func replaceDatabase(from path: String) throws {
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
    }
    
    public func save() {
        assert(Thread.isMainThread)
        do {
            try self.viewContext.save()
        } catch let error {
            NSLog("%@", "An error occured when saving: \(error)")
        }
    }
    
    public func sortExpenseTemplates(by sortDescriptors : [NSSortDescriptor]) {
        // Fetch
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.sortDescriptors = sortDescriptors
        request.predicate = negativePredicate
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
    
    public func sortIncomeTemplates(by sortDescriptors : [NSSortDescriptor]) {
        // Fetch
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.sortDescriptors = sortDescriptors
        request.predicate = positivePredicate
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
    
    // MARK: Private Functions
    private func insertIndex(_ historicalTransaction: HistoricalTransaction) -> Int {
        let transactions = self.historicalTransactionsReverse
        var index = transactions.count - 1
        
        while(index > 0) {
            if(historicalTransaction.date! > transactions[index].date!) {
                return index
            } else {
                index -= 1
            }
        }
        
        return 0
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
            
            self.viewContext.refreshAllObjects()
        } catch let error {
            print("Clearing database resulted in error: \(error.localizedDescription)")
        }
    }
    
    func purgeRecent() {
        do {
            let fetchRequest : NSFetchRequest<AchievementTransaction> = AchievementTransaction.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            
            fetchRequest.predicate = positivePredicate
            var incomes = try self.viewContext.fetch(fetchRequest)
            var totalIncomes = totalRecentIncomes
            
            fetchRequest.predicate = negativePredicate
            var expenses = try self.viewContext.fetch(fetchRequest)
            
            while expenses.count > 0 && -1 * expenses[0].amount <= totalIncomes {
                var remainingAmount = -1 * expenses[0].amount
                self.remove(achievementTransaction: expenses[0])
                expenses.remove(at: 0)
                
                while remainingAmount > 0 {
                    totalIncomes -= incomes[0].amount
                    remainingAmount -= incomes[0].amount
                    
                    if remainingAmount < 0 {
                        // Recalculate Amount of last Recent Income
                        let amountOfLastIncome = incomes[0].amount
                        let newAmount = -1 * remainingAmount
                        incomes[0].amount = newAmount
                        incomes[0].historicalTransaction?.amount = newAmount
                        
                        if remainingAmount != 0 {
                            // Add Split
                            let splitTransaction     = self.createHistoricalTransaction()
                            splitTransaction.text    = "\(incomes[0].text ?? "") (Split)"
                            splitTransaction.amount  = amountOfLastIncome + remainingAmount
                            splitTransaction.date    = incomes[0].date
                            splitTransaction.balance = 0.0
                            
                            // Make sure to have the history consistent
                            self.recalculateHistoricalBalances(from: splitTransaction)
                        }
                    } else {
                        self.remove(achievementTransaction: incomes[0])
                        incomes.remove(at: 0)
                    }
                }
            }
            
            self.save()
            
        } catch let error {
            print("ERROR: Purging failed due to error: \(error.localizedDescription)")
        }
    }
    
    func remove(achievementTransaction transaction: AchievementTransaction) {
        self.viewContext.delete(transaction)
    }
    
    func remove(historicalTransaction transaction: HistoricalTransaction) {
        // Remove Recent Item to prevent Items without history
        if let recentTransaction = transaction.recentTransaction {
            self.viewContext.delete(recentTransaction)
        }
        
        let index = historicalTransactionsReverse.firstIndex(of: transaction)
        
        self.viewContext.delete(transaction)
        
        recalculateHistoricalBalances(from: index)
        
        self.save()
    }
    
    func remove(transactionTemplate template: TransactionTemplate) {
        self.viewContext.delete(template)
    }
}

// https://www.donnywals.com/using-codable-with-core-data-and-nsmanagedobject/
extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

enum DecoderConfigurationError : Error {
    case MissingManagedObjectContext
}
