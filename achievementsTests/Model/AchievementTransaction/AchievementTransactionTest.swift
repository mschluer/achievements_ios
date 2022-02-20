//
//  AchievementTransactionTest.swift
//  achievementsTests
//
//  Created by Maximilian Schluer on 29.09.21.
//

import XCTest
@testable import achievements
import CoreData

class AchievementTransactionTest: XCTestCase {
    private var dataModel : AchievementsDataModel!
    
    override func setUpWithError() throws {
        self.dataModel = AchievementsDataModel()
        
        dataModel.clear()
    }

    override func tearDownWithError() throws {
    }
    
    // MARK: Tests for the EntityClass
    func testEntityNameCorrect() throws {
        XCTAssertEqual(AchievementTransaction.entityName, "AchievementTransaction")
    }
    
    func testFetchRequest() throws {
        XCTAssertEqual(
            AchievementTransaction.fetchRequest(),
            NSFetchRequest<AchievementTransaction>(entityName: "AchievementTransaction"))
    }
    
    func testToString() throws {
        // Prepare Date
        let date = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let expectedDateString = formatter.string(for: date)
        
        // Create Transaction
        let subject = dataModel.createAchievementTransactionWith(text: "Test", amount: 2.00, date: date)
        
        XCTAssertEqual(
            subject.toString(),
            "\(expectedDateString ?? ""): 2,00 Test")
    }
    
    // MARK: Tests for the DataModel
    func testManualCreation() throws {
        XCTAssertEqual(dataModel.achievementTransactions.count, 0)
        
        let subject = dataModel.createAchievementTransaction()
        subject.text = "alpha"
        subject.date = Date()
        subject.amount = 1.0
        dataModel.save()
        
        XCTAssertEqual(dataModel.achievementTransactions.count, 1)
        XCTAssertEqual(dataModel.achievementTransactions.first?.text, "alpha")
    }
    
    func testFetchForAllTransactions() throws {
        // Create Transactions
        let texts = [ "alpha", "beta", "gamma" ]
        let amounts : [Float] = [ 3.0, 2.0, 1.0 ]
        
        for i in 0...2 {
            _ = dataModel.createAchievementTransactionWith(
                text: texts[i],
                amount: amounts[i],
                date: Date())
            
            dataModel.save()
        }
        
        // Check whether the correct amount of items is stored
        XCTAssertEqual(dataModel.achievementTransactions.count, 3)
    }
    
    func testWhetherTransactionsAreSortedByDate() throws {
        // Create Transactions
        let date = Date()
        let texts = [ "delta", "beta", "alpha" ]
        let amounts : [Float] = [ 3.0, 2.0, 1.0 ]
        let dates = [ date - 120, date - 60, date ]
        
        for i in 0...2 {
            _ = dataModel.createAchievementTransactionWith(text: texts[i], amount: amounts[i], date: dates[i])
            
            dataModel.save()
        }
        
        // Check order
        let storedTransactions = dataModel.achievementTransactions
        
        XCTAssertEqual(storedTransactions[0].text, "alpha")
        XCTAssertEqual(storedTransactions[1].text, "beta")
        XCTAssertEqual(storedTransactions[2].text, "delta")
    }
    
    func testGroupedAchievementTransactions() throws {
        // Prepare Dates
        let today = Date()
        var oneDay = DateComponents()
        oneDay.day = 1
        let tomorrow = Calendar.current.date(byAdding: oneDay, to: today)!
        
        // Create Transactions
        let texts = [ "delta", "beta", "alpha" ]
        let amounts : [Float] = [ 3.0, 2.0, 1.0 ]
        let dates = [ today, tomorrow, today ]
        
        for i in 0...2 {
            _ = dataModel.createAchievementTransactionWith(text: texts[i], amount: amounts[i], date: dates[i])
            
            dataModel.save()
        }
        
        // Check Grouping
        let groupedTransactions = dataModel.groupedAchievementTransactions
        var keys = Array(groupedTransactions.keys)
        keys.sort(by: { Calendar.current.date(from: $0)! < Calendar.current.date(from: $1)! })
        
        XCTAssertEqual(groupedTransactions.count, 2)
        XCTAssertEqual(groupedTransactions[keys[0]]!.count, 2)
        XCTAssertEqual(groupedTransactions[keys[1]]?.first?.text, "beta")
        XCTAssertEqual(groupedTransactions[keys[1]]!.count, 1)
    }
    
    func testDeletion() throws {
        XCTAssertEqual(dataModel.achievementTransactions.count, 0)
        
        // Create Templates
        _ = dataModel.createAchievementTransactionWith(text: "alpha", amount: 2.0, date: Date())
        let second = dataModel.createAchievementTransactionWith(text: "beta", amount: 4.0, date: Date())
        _ = dataModel.createAchievementTransactionWith(text: "delta", amount: 6.0, date: Date())
        dataModel.save()
        
        XCTAssertEqual(dataModel.achievementTransactions.count, 3)
        
        dataModel.remove(achievementTransaction: second)
        
        XCTAssertEqual(dataModel.achievementTransactions.count, 2)
        XCTAssertEqual(dataModel.achievementTransactions[0].text, "delta")
        XCTAssertEqual(dataModel.achievementTransactions[1].text, "alpha")
    }
}
