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
    }

    override func tearDownWithError() throws {
    }

    // MARK: Tests for the overall Data Model Class
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

    // MARK: Performance Tests
    func testPerformanceExample() throws {
        self.measure {
        }
    }

}
