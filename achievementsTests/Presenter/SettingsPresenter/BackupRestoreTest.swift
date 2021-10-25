//
//  BackupRestoreTest.swift
//  achievementsTests
//
//  Created by Maximilian Schluer on 21.10.21.
//

import XCTest
@testable import achievements

class BackupRestoreTest: XCTestCase {
    private var achievementsDataModel : AchievementsDataModel!
    private var subject : SettingsPresenter!
    
    override func setUpWithError() throws {
        self.achievementsDataModel = AchievementsDataModel()
        
        achievementsDataModel.clear()
        
        subject = SettingsPresenter(achievementsDataModel: achievementsDataModel)
    }

    override func tearDownWithError() throws {
    }
    
    // MARK: Test for Entire Process
    func testBackupAndRestoreProcess() throws {
        // Create one of each
        _ = achievementsDataModel.createAchievementTransactionWith(text: "Transaction", amount: 1.0, date: Date())
        let template = achievementsDataModel.createTransactionTemplate()
        template.text = "Template"
        template.amount = 2.0
        template.recurring = false
        template.orderIndex = 0
        achievementsDataModel.save()
        
        // Create Backup
        let backup = subject.exportDatabaseBackupWith(password: ".test.", initiator: UIViewController())
        
        // Clear
        achievementsDataModel.clear()
        XCTAssertEqual(0, achievementsDataModel.achievementTransactions.count)
        XCTAssertEqual(0, achievementsDataModel.historicalTransactions.count)
        XCTAssertEqual(0, achievementsDataModel.transactionTemplates.count)
        
        // Restore
        subject.replaceDatabaseWith(url: backup! as URL, password: ".test.", initiator: UIViewController())
        XCTAssertEqual(1, achievementsDataModel.achievementTransactions.count)
        XCTAssertEqual(1, achievementsDataModel.historicalTransactions.count)
        XCTAssertEqual(1, achievementsDataModel.transactionTemplates.count)
        
        // Check Transaction
        XCTAssertEqual("Transaction", achievementsDataModel.achievementTransactions.first!.text)
        XCTAssertEqual(0, achievementsDataModel.transactionTemplates.first!.orderIndex)
        XCTAssertEqual(1.0, achievementsDataModel.historicalTransactions.first!.amount)
    }
}
