//
//  TransactionTemplateTest.swift
//  achievementsTests
//
//  Created by Maximilian Schluer on 08.10.21.
//

import XCTest
@testable import achievements
import CoreData

class TransactionTemplateTest: XCTestCase {
    private var dataModel : AchievementsDataModel!
    
    override func setUpWithError() throws {
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
    
    func testQuickBookable() throws {
        let subject = dataModel.createTransactionTemplate()
        
        XCTAssertFalse(subject.isQuickBookable())
        
        subject.text = "Test"
        
        XCTAssertFalse(subject.isQuickBookable())
        
        subject.amount = 2.0
        
        XCTAssertTrue(subject.isQuickBookable())
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
    
    // MARK: Test for JSON (de)serialization
    func testJSONSerialization() throws {
        // Create Template
        let transactionTemplate = dataModel.createTransactionTemplate()
        transactionTemplate.text = "alpha"
        transactionTemplate.amount = 6
        transactionTemplate.recurring = false
        transactionTemplate.orderIndex = 15
        
        // Serialize
        let jsonEncoder = JSONEncoder()
        let data = try! String(bytes: jsonEncoder.encode(transactionTemplate), encoding: .utf8)
        
        XCTAssertEqual(data!, "{\"amount\":6,\"recurring\":false,\"orderIndex\":15,\"text\":\"alpha\"}")
    }
    
    func testJSONDeserialization() throws {
        // Verify Environment
        XCTAssertEqual(dataModel.transactionTemplates.count, 0)
        
        // Decode JSON
        let data = "{\"amount\":12,\"recurring\":true,\"orderIndex\":12,\"text\":\"beta\"}".data(using: .utf8)
        let jsonDecoder = JSONDecoder()
        jsonDecoder.userInfo[CodingUserInfoKey.managedObjectContext] = dataModel.viewContext
        let transactionTemplate = try jsonDecoder.decode(TransactionTemplate.self, from: data!)
        
        // Verify
        XCTAssertEqual(dataModel.transactionTemplates.count, 1)
        XCTAssertEqual(transactionTemplate.amount, 12.0)
        XCTAssertEqual(transactionTemplate.recurring, true)
        XCTAssertEqual(transactionTemplate.orderIndex, 12)
        XCTAssertEqual(transactionTemplate.text, "beta")
    }
}
