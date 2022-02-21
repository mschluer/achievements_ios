//
//  HistoricalTransactionSerializationTest.swift
//  achievementsTests
//
//  Created by Maximilian Schluer on 20.02.22.
//

import XCTest
@testable import achievements
import CoreData

class HistoricalTransactionSerializationTest: XCTestCase {
    private var dataModel : AchievementsDataModel!
    private var exampleDateComponents : DateComponents!
    private var exampleDate : Date!

    override func setUpWithError() throws {
        dataModel = AchievementsDataModel()
        
        dataModel.clear()
        
        // Prepare Date
        exampleDateComponents = DateComponents()
        exampleDateComponents.year = 2022
        exampleDateComponents.month = 1
        exampleDateComponents.day = 1
        exampleDateComponents.hour = 5
        exampleDate = Calendar.current.date(from: exampleDateComponents)
    }

    override func tearDownWithError() throws {
    }
    
    // MARK: Tests for Historical without Recent Transaction
    func testJSONSerialization() throws {
        // Create Historical Transaction
        let historicalTransaction = dataModel.createHistoricalTransaction()
        historicalTransaction.amount = 1
        historicalTransaction.balance = -5.5
        historicalTransaction.date = exampleDate
        historicalTransaction.text = "alpha"
        
        // Serialize
        let jsonEncoder = JSONEncoder()
        let data = try! String(bytes: jsonEncoder.encode(historicalTransaction), encoding: .utf8)
        
        XCTAssertEqual(data!, "{\"amount\":1,\"hasRecentTransaction\":false,\"text\":\"alpha\",\"balance\":-5.5,\"date\":662702400}")
    }
    
    func testJSONDeserialization() throws {
        // Verify Environment
        XCTAssertEqual(dataModel.achievementTransactions.count, 0)
        XCTAssertEqual(dataModel.historicalTransactions.count, 0)
        
        // Decode JSON
        let data = "{\"amount\":12,\"balance\":-3.2,\"date\":662702400,\"text\":\"beta\",\"hasRecentTransaction\":false}".data(using: .utf8)
        let jsonDecoder = JSONDecoder()
        jsonDecoder.userInfo[CodingUserInfoKey.managedObjectContext] = dataModel.viewContext
        let historicalTransaction = try jsonDecoder.decode(HistoricalTransaction.self, from: data!)
        
        // Verify
        XCTAssertEqual(dataModel.achievementTransactions.count, 0)
        XCTAssertEqual(dataModel.historicalTransactions.count, 1)
        XCTAssertEqual(historicalTransaction.amount, 12.0)
        XCTAssertEqual(historicalTransaction.balance, -3.2)
        XCTAssertEqual(historicalTransaction.date, exampleDate)
        XCTAssertEqual(historicalTransaction.text, "beta")
        XCTAssertNil(historicalTransaction.recentTransaction)
    }
    
    // MARK: Tests for Historical with Recent Transaction
    func testJSONSerializationWithRecentTransaction() throws {
        // Create Historical Transaction
        let achievementTransaction = dataModel.createAchievementTransactionWith(text: "gamma", amount: 3, date: exampleDate)
        
        // Serialize
        let jsonEncoder = JSONEncoder()
        let data = try! String(bytes: jsonEncoder.encode(achievementTransaction.historicalTransaction), encoding: .utf8)
        
        XCTAssertEqual(data!, "{\"amount\":3,\"hasRecentTransaction\":true,\"text\":\"gamma\",\"balance\":3,\"date\":662702400}")
    }
    
    func testJSONDeSerializationWithRecentTransaction() throws {
        // Verify Environment
        XCTAssertEqual(dataModel.achievementTransactions.count, 0)
        XCTAssertEqual(dataModel.historicalTransactions.count, 0)
        
        // Decode JSON
        let data = "{\"amount\":12,\"balance\":-3.2,\"date\":662702400,\"text\":\"delta\",\"hasRecentTransaction\":true}".data(using: .utf8)
        let jsonDecoder = JSONDecoder()
        jsonDecoder.userInfo[CodingUserInfoKey.managedObjectContext] = dataModel.viewContext
        let historicalTransaction = try jsonDecoder.decode(HistoricalTransaction.self, from: data!)
        
        // Verify
        XCTAssertEqual(dataModel.achievementTransactions.count, 1)
        XCTAssertEqual(dataModel.historicalTransactions.count, 1)
        
        XCTAssertEqual(historicalTransaction.amount, 12.0)
        XCTAssertEqual(historicalTransaction.balance, -3.2)
        XCTAssertEqual(historicalTransaction.date, exampleDate)
        XCTAssertEqual(historicalTransaction.text, "delta")
        
        XCTAssertEqual(historicalTransaction.recentTransaction!.amount, 12.0)
        XCTAssertEqual(historicalTransaction.recentTransaction!.date, exampleDate)
        XCTAssertEqual(historicalTransaction.recentTransaction!.text, "delta")
    }
}
