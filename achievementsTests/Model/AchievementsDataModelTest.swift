//
//  AchievementsDataModelTest.swift
//  achievementsTests
//
//  Created by Maximilian Schluer on 22.09.21.
//

import XCTest
@testable import achievements
import CoreData

class AchievementsDataModelTest: XCTestCase {
    private var subject : AchievementsDataModel!
    
    override func setUpWithError() throws {
        self.subject = AchievementsDataModel()
        
        subject.clear()
    }

    override func tearDownWithError() throws {
    }
    
    // MARK: Filtered Recent Transactions
    func testGetterForRecentIncomes() throws {
        _ = subject.createAchievementTransactionWith(text: "alpha", amount: 2.0, date: Date())
        _ = subject.createAchievementTransactionWith(text: "beta", amount: 3.0, date: Date())
        _ = subject.createAchievementTransactionWith(text: "gamma", amount: -5.0, date: Date())
        subject.save()
        
        XCTAssertEqual(subject.recentIncomes.count, 2)
    }
    
    func testGetterForRecentExpenses() throws {
        _ = subject.createAchievementTransactionWith(text: "alpha", amount: 2.0, date: Date())
        _ = subject.createAchievementTransactionWith(text: "beta", amount: 3.0, date: Date())
        _ = subject.createAchievementTransactionWith(text: "gamma", amount: -5.0, date: Date())
        subject.save()
        
        XCTAssertEqual(subject.recentExpenses.count, 1)
    }
    
    // MARK: Calculations
    func testRecentIncomesTotal() throws {
        _ = subject.createAchievementTransactionWith(text: "alpha", amount: 2.0, date: Date())
        _ = subject.createAchievementTransactionWith(text: "beta", amount: 3.0, date: Date())
        _ = subject.createAchievementTransactionWith(text: "gamma", amount: -5.0, date: Date())
        subject.save()
        
        XCTAssertEqual(subject.totalRecentIncomes, 5.0)
    }
    
    func testHistoricalIncomesTotal() throws {
        _ = subject.createAchievementTransactionWith(text: "alpha", amount: 2.0, date: Date())
        _ = subject.createAchievementTransactionWith(text: "beta", amount: 3.0, date: Date())
        _ = subject.createAchievementTransactionWith(text: "gamma", amount: -5.0, date: Date())
        subject.save()
        
        XCTAssertEqual(subject.totalHistoricalIncomes, 5.0)
    }
    
    func testRecentExpensesTotal() throws {
        _ = subject.createAchievementTransactionWith(text: "alpha", amount: 2.0, date: Date())
        _ = subject.createAchievementTransactionWith(text: "beta", amount: 3.0, date: Date())
        _ = subject.createAchievementTransactionWith(text: "gamma", amount: -5.0, date: Date())
        subject.save()
        
        XCTAssertEqual(subject.totalRecentExpenses, -5.0)
    }
    
    func testHistoricalExpensesTotal() throws {
        _ = subject.createAchievementTransactionWith(text: "alpha", amount: 2.0, date: Date())
        _ = subject.createAchievementTransactionWith(text: "beta", amount: 3.0, date: Date())
        _ = subject.createAchievementTransactionWith(text: "gamma", amount: -5.0, date: Date())
        subject.save()
        
        XCTAssertEqual(subject.totalHistoricalExpenses, -5.0)
    }
    
    // MARK: Filtered Historical Transactions
    func testGetterForHistoricalIncomes() throws {
        _ = subject.createAchievementTransactionWith(text: "alpha", amount: 2.0, date: Date())
        _ = subject.createAchievementTransactionWith(text: "beta", amount: 3.0, date: Date())
        _ = subject.createAchievementTransactionWith(text: "gamma", amount: -5.0, date: Date())
        subject.save()
        
        XCTAssertEqual(subject.historicalIncomes.count, 2)
    }
    
    func testGetterForHistoricalExpenses() throws {
        _ = subject.createAchievementTransactionWith(text: "alpha", amount: 2.0, date: Date())
        _ = subject.createAchievementTransactionWith(text: "beta", amount: 3.0, date: Date())
        _ = subject.createAchievementTransactionWith(text: "gamma", amount: -5.0, date: Date())
        subject.save()
        
        XCTAssertEqual(subject.historicalExpenses.count, 1)
    }
    
    // MARK: Historical Balance Recalculation
    func testBalanceRecalculationUponHistoryItemDeletion() throws {
        _ = subject.createAchievementTransactionWith(text: "alpha", amount: 2.0, date: Date() - 120)
        let second = subject.createAchievementTransactionWith(text: "beta", amount: 3.0, date: Date() - 60)
        _ = subject.createAchievementTransactionWith(text: "gamma", amount: -5.0, date: Date())
        
        subject.remove(historicalTransaction: second.historicalTransaction!)
        
        XCTAssertEqual(subject.historicalTransactions[1].balance, 2.0)
        XCTAssertEqual(subject.historicalTransactions[0].balance, -3.0)
    }

    // MARK: Destructive Operations
    func testPurgeRecent() throws {
        _ = subject.createAchievementTransactionWith(text: "alpha", amount: 2.0, date: Date())
        _ = subject.createAchievementTransactionWith(text: "beta", amount: 3.0, date: Date())
        _ = subject.createAchievementTransactionWith(text: "gamma", amount: -5.0, date: Date())
        _ = subject.createAchievementTransactionWith(text: "delta", amount: 3, date: Date())
        _ = subject.createAchievementTransactionWith(text: "epsilon", amount: -7.0, date: Date())
        
        subject.purgeRecent()
        
        // Test Amount of Items
        XCTAssertEqual(subject.achievementTransactions.count, 2)
        XCTAssertEqual(subject.historicalTransactions.count, 5)
        
        // Check, whether the correct items remained
        XCTAssertEqual(subject.recentIncomes.first?.text, "delta")
        XCTAssertEqual(subject.recentExpenses.first?.text, "epsilon")
    }
    
    func testClear() throws {
        // Create Achievement Transaction
        _ = subject.createAchievementTransactionWith(text: "transaction", amount: 1.0, date: Date())
        
        // Create Transaction Template
        let template = subject.createTransactionTemplate()
        template.text = "template"
        subject.save()
        
        // Check presence
        XCTAssertEqual(subject.achievementTransactions.count, 1)
        XCTAssertEqual(subject.historicalTransactions.count, 1)
        XCTAssertEqual(subject.transactionTemplates.count, 1)
        
        // Clear
        subject.clear()
        
        // Check for each Entity
        XCTAssertEqual(subject.achievementTransactions.count, 0)
        XCTAssertEqual(subject.historicalTransactions.count, 0)
        XCTAssertEqual(subject.transactionTemplates.count, 0)
    }
}
