//
//  TransactionTemplateTest.swift
//  achievementsTests
//
//  Created by Maximilian Schluer on 22.09.21.
//

import XCTest
@testable import achievements
import CoreData

class TransactionTemplateTest: XCTestCase {
    private var subject : TransactionTemplate!
    private var dataModel : AchievementsDataModel!
    
    override func setUpWithError() throws {
        self.subject = TransactionTemplate()
        self.dataModel = AchievementsDataModel()
        
        dataModel.clear()
    }

    override func tearDownWithError() throws {
    }
    
    // MARK: Tests for the EntityClass
    func testEntityNameCorrect() throws {
        XCTAssertEqual(TransactionTemplate.entityName, "TransactionTemplate")
    }
    
    func testFetchRequest() throws {
        XCTAssertEqual(
            TransactionTemplate.fetchRequest(),
            NSFetchRequest<TransactionTemplate>(entityName: "TransactionTemplate"))
    }
    
    // MARK: Test for the DataModel
    func testFetchForAllTemplates() throws {
        // Create Templates
        let texts = [ "alpha", "beta", "gamma" ]
        let amounts : [Float] = [ 3.0, 2.0, 1.0 ]
        let recurring = [ true, true, true ]
        
        for i in 0...2 {
            let template = dataModel.createTransactionTemplate()
            
            template.text = texts[i]
            template.amount = amounts[i]
            template.recurring = recurring[i]
            
            dataModel.save()
        }
        
        // Check whether there is an array of three
        XCTAssertEqual(dataModel.transactionTemplates.count, 3)
    }
    
    func testFetchForRecurringTemplates() throws {
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
        
        XCTAssertEqual(dataModel.recurringTransactionTemplates.count, 2)
        XCTAssertEqual(dataModel.recurringTransactionTemplates[0].text, "alpha")
        XCTAssertEqual(dataModel.recurringTransactionTemplates[1].text, "gamma")
    }
    
    func testFetchForNonRecurringTemplates() throws {
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
        
        XCTAssertEqual(dataModel.nonRecurringTransactionTemplates.count, 2)
        XCTAssertEqual(dataModel.nonRecurringTransactionTemplates[0].text, "beta")
        XCTAssertEqual(dataModel.nonRecurringTransactionTemplates[1].text, "gamma")
    }
    
    func testWhetherTemplatesAreSortedAlphabetically() throws {
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
        
        // Check alphabetical order
        let storedTemplates = dataModel.transactionTemplates
        
        XCTAssertEqual(storedTemplates[0].text, "alpha")
        XCTAssertEqual(storedTemplates[1].text, "beta")
        XCTAssertEqual(storedTemplates[2].text, "delta")
    }
    
    func testDeletion() throws {
        XCTAssertEqual(dataModel.transactionTemplates.count, 0)
        
        // Create Templates
        let firstTemplate = dataModel.createTransactionTemplate()
        firstTemplate.text = "alpha"
        firstTemplate.amount = 2.0
        firstTemplate.recurring = true
        
        let secondTemplate = dataModel.createTransactionTemplate()
        secondTemplate.text = "beta"
        secondTemplate.amount = 4.0
        secondTemplate.recurring = true
        
        let thirdTemplate = dataModel.createTransactionTemplate()
        thirdTemplate.text = "delta"
        thirdTemplate.amount = 6.0
        thirdTemplate.recurring = true
        dataModel.save()
        
        XCTAssertEqual(dataModel.transactionTemplates.count, 3)
        
        dataModel.remove(transactionTemplate: secondTemplate)
        
        XCTAssertEqual(dataModel.transactionTemplates.count, 2)
        XCTAssertEqual(dataModel.transactionTemplates[0].text, "alpha")
        XCTAssertEqual(dataModel.transactionTemplates[1].text, "delta")
    }
}
