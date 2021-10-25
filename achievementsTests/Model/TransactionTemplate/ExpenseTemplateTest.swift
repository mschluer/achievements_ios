//
//  ExpenseTemplateTest.swift
//  achievementsTests
//
//  Created by Maximilian Schluer on 10.10.21.
//

import XCTest
@testable import achievements
import CoreData

class ExpenseTemplateTest: XCTestCase {
    private var subject : TransactionTemplate!
    private var dataModel : AchievementsDataModel!
    
    override func setUpWithError() throws {
        self.subject = TransactionTemplate()
        self.dataModel = AchievementsDataModel()
        
        dataModel.clear()
    }

    override func tearDownWithError() throws {
    }

    // MARK: Test Rearranging Expenses
    func testAddingToTop() throws {
        // Create Templates
        let texts = [ "alpha", "beta", "gamma" ]
        let amounts : [Float] = [ -3.0, -2.0, -1.0 ]
        let recurring = [ true, true, true ]
        let indices : [Int16] = [ 1, 2, 3 ]
        
        for i in 0...2 {
            let template = dataModel.createTransactionTemplate()
            
            template.text = texts[i]
            template.amount = amounts[i]
            template.recurring = recurring[i]
            template.orderIndex = indices[i]
            
            dataModel.save()
        }
        
        // Check Appending
        let appendedTemplate = dataModel.createTransactionTemplate()
        appendedTemplate.text = "delta"
        appendedTemplate.amount = -5.0
        appendedTemplate.recurring = false
        dataModel.save()
        
        dataModel.rearrangeTransactionTemplates(template: appendedTemplate, destinationIndex: 0)
        XCTAssertEqual(dataModel.expenseTemplates[0].text, "delta")
        XCTAssertEqual(dataModel.expenseTemplates[1].text, "alpha")
        XCTAssertEqual(dataModel.expenseTemplates[2].text, "beta")
        XCTAssertEqual(dataModel.expenseTemplates[3].text, "gamma")
    }
    
    func testAddingIntoTheMiddle() throws {
        // Create Templates
        let texts = [ "alpha", "beta", "gamma" ]
        let amounts : [Float] = [ -3.0, -2.0, -1.0 ]
        let recurring = [ true, true, true ]
        let indices : [Int16] = [ 1, 2, 3 ]
        
        for i in 0...2 {
            let template = dataModel.createTransactionTemplate()
            
            template.text = texts[i]
            template.amount = amounts[i]
            template.recurring = recurring[i]
            template.orderIndex = indices[i]
            
            dataModel.save()
        }
        
        // Check Appending
        let appendedTemplate = dataModel.createTransactionTemplate()
        appendedTemplate.text = "delta"
        appendedTemplate.amount = -5.0
        appendedTemplate.recurring = false
        dataModel.save()
        
        dataModel.rearrangeTransactionTemplates(template: appendedTemplate, destinationIndex: 2)
        XCTAssertEqual(dataModel.expenseTemplates[0].text, "alpha")
        XCTAssertEqual(dataModel.expenseTemplates[1].text, "delta")
        XCTAssertEqual(dataModel.expenseTemplates[2].text, "beta")
        XCTAssertEqual(dataModel.expenseTemplates[3].text, "gamma")
    }
    
    func testAddingToEnd() throws {
        // Create Templates
        let texts = [ "alpha", "beta", "gamma" ]
        let amounts : [Float] = [ -3.0, -2.0, -1.0 ]
        let recurring = [ true, true, true ]
        let indices : [Int16] = [ 1, 2, 3 ]
        
        for i in 0...2 {
            let template = dataModel.createTransactionTemplate()
            
            template.text = texts[i]
            template.amount = amounts[i]
            template.recurring = recurring[i]
            template.orderIndex = indices[i]
            
            dataModel.save()
        }
        
        // Check Appending
        let appendedTemplate = dataModel.createTransactionTemplate()
        appendedTemplate.text = "delta"
        appendedTemplate.amount = -5.0
        appendedTemplate.recurring = false
        dataModel.save()
        
        dataModel.rearrangeTransactionTemplates(template: appendedTemplate, destinationIndex: 4)
        XCTAssertEqual(dataModel.expenseTemplates[0].text, "alpha")
        XCTAssertEqual(dataModel.expenseTemplates[1].text, "beta")
        XCTAssertEqual(dataModel.expenseTemplates[2].text, "gamma")
        XCTAssertEqual(dataModel.expenseTemplates[3].text, "delta")
    }
}
