//
//  TransactionTemplateTest.swift
//  achievementsTests
//
//  Created by Maximilian Schluer on 22.09.21.
//

import XCTest
@testable import achievements
import CoreData

class IncomeTemplateTest: XCTestCase {
    private var subject : TransactionTemplate!
    private var dataModel : AchievementsDataModel!
    
    override func setUpWithError() throws {
        self.subject = TransactionTemplate()
        self.dataModel = AchievementsDataModel()
        
        dataModel.clear()
    }

    override func tearDownWithError() throws {
    }
    
    // MARK: Test for the DataModel
    func testFetchForRecurringIncomes() throws {
        // Create Templates
        let texts = [ "alpha", "beta", "gamma" ]
        let amounts : [Float] = [ 3.0, 2.0, 1.0 ]
        let recurring = [ true, false, true ]
        
        for i in 0...2 {
            let template = dataModel.createTransactionTemplate()
            
            template.text = texts[i]
            template.amount = amounts[i]
            template.recurring = recurring[i]
            
            dataModel.save()
        }
        
        XCTAssertEqual(dataModel.recurringIncomeTemplates.count, 2)
        XCTAssertEqual(dataModel.recurringIncomeTemplates[0].text, "alpha")
        XCTAssertEqual(dataModel.recurringIncomeTemplates[1].text, "gamma")
    }
    
    func testFetchForNonRecurringIncomes() throws {
        // Create Templates
        let texts = [ "alpha", "beta", "gamma" ]
        let amounts : [Float] = [ 3.0, 2.0, 1.0 ]
        let recurring = [ true, false, false ]
        
        for i in 0...2 {
            let template = dataModel.createTransactionTemplate()
            
            template.text = texts[i]
            template.amount = amounts[i]
            template.recurring = recurring[i]
            
            dataModel.save()
        }
        
        XCTAssertEqual(dataModel.nonRecurringIncomeTemplates.count, 2)
        XCTAssertEqual(dataModel.nonRecurringIncomeTemplates[0].text, "beta")
        XCTAssertEqual(dataModel.nonRecurringIncomeTemplates[1].text, "gamma")
    }
    
    func testWhetherTemplatesCanBeSortedAlphabetically() throws {
        // Create Templates
        let texts = [ "delta", "beta", "alpha" ]
        let amounts : [Float] = [ 3.0, 2.0, 1.0 ]
        let recurring = [ true, true, true ]
        
        for i in 0...2 {
            let template = dataModel.createTransactionTemplate()
            
            template.text = texts[i]
            template.amount = amounts[i]
            template.recurring = recurring[i]
            
            dataModel.save()
        }
        
        // Sort
        dataModel.sortIncomeTemplates(by: [ NSSortDescriptor(key: "text", ascending: true) ])
        
        // Check alphabetical order
        let storedTemplates = dataModel.incomeTemplates
        
        XCTAssertEqual(storedTemplates[0].text, "alpha")
        XCTAssertEqual(storedTemplates[1].text, "beta")
        XCTAssertEqual(storedTemplates[2].text, "delta")
    }
    
    func testWhetherExpensesAreFiltered() throws {
        // Create Templates
        let texts = [ "delta", "beta", "alpha" ]
        let amounts : [Float] = [ 3.0, -2.0, 1.0 ]
        let recurring = [ true, true, true ]
        
        for i in 0...2 {
            let template = dataModel.createTransactionTemplate()
            
            template.text = texts[i]
            template.amount = amounts[i]
            template.recurring = recurring[i]
            
            dataModel.save()
        }
        
        // Sort
        dataModel.sortIncomeTemplates(by: [ NSSortDescriptor(key: "text", ascending: true) ])
        
        // Check alphabetical order
        let storedTemplates = dataModel.incomeTemplates
        
        XCTAssertEqual(storedTemplates[0].text, "alpha")
        XCTAssertEqual(storedTemplates[1].text, "delta")
    }
}
