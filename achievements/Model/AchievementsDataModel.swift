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
    
    // MARK: Initializers
    init() {
        self.persistentContainer = NSPersistentContainer(name: "AchievementsDataModel")
        self.persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error: \(error)")
            }
        }
    }
    
    // MARK: Variables
    var viewContext : NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
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
    
    var historicalTransactions : [HistoricalTransaction] {
        let request : NSFetchRequest<HistoricalTransaction> = HistoricalTransaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return try! viewContext.fetch(request)
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
    
    var historicalTransactionsReverse: [HistoricalTransaction] {
        let request : NSFetchRequest<HistoricalTransaction> = HistoricalTransaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return try! viewContext.fetch(request)
    }
    
    var transactionTemplates: [TransactionTemplate] {
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true)]
        return try! viewContext.fetch(request)
    }
    
    var incomeTemplates: [TransactionTemplate] {
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true)]
        request.predicate = NSPredicate(format: "amount >= 0")
        return try! self.viewContext.fetch(request)
    }
    
    var recurringIncomeTemplates: [TransactionTemplate] {
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "recurring = true && amount >= 0")
        request.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true)]
        return try! self.viewContext.fetch(request)
    }
    
    var nonRecurringIncomeTemplates: [TransactionTemplate] {
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "recurring = false && amount >= 0")
        request.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true)]
        return try! self.viewContext.fetch(request)
    }
    
    var plannedExpenses: [TransactionTemplate] {
        let request : NSFetchRequest<TransactionTemplate> = TransactionTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "amount < 0")
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        return try! self.viewContext.fetch(request)
    }
    
    var recentIncomes : [AchievementTransaction] {
        let fetchRequest : NSFetchRequest<AchievementTransaction> = AchievementTransaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "amount >= 0")
        return try! self.viewContext.fetch(fetchRequest)
    }
    
    var totalRecentIncomes : Float {
        var result : Float = 0
        for income in recentIncomes {
            result += income.amount
        }
        return result
    }
    
    var recentExpenses : [AchievementTransaction] {
        let fetchRequest : NSFetchRequest<AchievementTransaction> = AchievementTransaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "amount < 0")
        return try! self.viewContext.fetch(fetchRequest)
    }
    
    var totalRecentExpenses : Float {
        var result : Float = 0
        for expense in recentExpenses {
            result += expense.amount
        }
        return result
    }
    
    var historicalIncomes : [HistoricalTransaction] {
        let fetchRequest : NSFetchRequest<HistoricalTransaction> = HistoricalTransaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "amount >= 0")
        return try! self.viewContext.fetch(fetchRequest)
    }
    
    var totalHistoricalIncomes : Float {
        var result : Float = 0
        for income in historicalIncomes {
            result += income.amount
        }
        return result
    }
    
    var historicalExpenses : [HistoricalTransaction] {
        let fetchRequest : NSFetchRequest<HistoricalTransaction> = HistoricalTransaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "amount < 0")
        return try! self.viewContext.fetch(fetchRequest)
    }
    
    var totalHistoricalExpenses : Float {
        var result : Float = 0
        for expense in historicalExpenses {
            result += expense.amount
        }
        return result
    }
    
    // MARK: Insertions
    func createAchievementTransaction() -> AchievementTransaction {
        return NSEntityDescription.insertNewObject(forEntityName: AchievementTransaction.entityName, into: self.viewContext) as! AchievementTransaction
    }
    
    func createHistoricalTransaction() -> HistoricalTransaction {
        return NSEntityDescription.insertNewObject(forEntityName: HistoricalTransaction.entityName, into: self.viewContext) as! HistoricalTransaction
    }
    
    func createTransactionTemplate() -> TransactionTemplate {
        return NSEntityDescription.insertNewObject(forEntityName: TransactionTemplate.entityName, into: self.viewContext) as! TransactionTemplate
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
    
    // MARK: Destructive Transactions
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
    
    func clear() {
        guard let url = persistentContainer.persistentStoreDescriptions.first?.url else { return }
        
        let persistenStoreCoordinator = persistentContainer.persistentStoreCoordinator
        
        do {
            try persistenStoreCoordinator.destroyPersistentStore(at: url,
                                                                 type: NSPersistentStore.StoreType(rawValue: NSSQLiteStoreType),
                                                                 options: nil)
            try persistenStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                             configurationName: nil,
                                                             at: url,
                                                             options: nil)
            
        } catch let error {
            print("Clearing database resulted in error: \(error.localizedDescription)")
        }
    }
    
    // MARK: Save
    func save() {
        assert(Thread.isMainThread)
        do {
            try self.viewContext.save()
        } catch let error {
            NSLog("%@", "An error occured when saving: \(error)")
        }
    }
    
    // MARK: Recalculation of Historical Balances
    func recalculateHistoricalBalances(from element: HistoricalTransaction?) {
        if element != nil {
            recalculateHistoricalBalances(from: historicalTransactionsReverse.firstIndex(of: element!))
        } else {
            recalculateHistoricalBalances(from: 0)
        }
    }
    
    func recalculateHistoricalBalances(from beginIndex: Int?) {
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
    
    func reindexPlannedExpenses() {
        let expenses = plannedExpenses
        
        print(plannedExpenses.count)
        
        for i in 0...(expenses.count - 1) {
            expenses[i].orderIndex = Int16(i)
        }
        
        save()
    }
    
    func rearrangeTransactionTemplates(template: TransactionTemplate, destinationIndex: Int) {
        reindexPlannedExpenses()
        
        // Push forward
        let expenses = plannedExpenses
        if destinationIndex < plannedExpenses.count {
            for i in destinationIndex...(expenses.count - 1) {
                expenses[i].orderIndex += 1
            }
        }
        
        // Insert
        template.orderIndex = Int16(destinationIndex)
        save()
    }
}
