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
    
    func testWhetherTemplatesAreSortedAlphabetically() throws {
        // Create Templates
        let texts = [ "delta", "beta", "alpha" ]
        let amounts : [Float] = [ 3.0, 2.0, 1.0 ]
        let recurring = [ true, true, true ]
        
        for i in 0...2 {
            print("creating item \(i)")
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
    
    // MARK: Performance Tests

    func testPerformanceExample() throws {
        self.measure {
        }
    }

}
