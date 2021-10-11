//
//  AutomaticPurgeTest.swift
//  achievementsUITests
//
//  Created by Maximilian Schluer on 11.10.21.
//

import XCTest

class AutomaticPurgeTest: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false

        XCUIApplication().launch()
        
        // Reset App before each test
        let app = XCUIApplication()
        app.toolbars["Toolbar"].buttons["Menu"].tap()
        app.collectionViews.buttons["Reset"].tap()
        app.sheets["Sicher?"].scrollViews.otherElements.buttons["App Zurücksetzen"].tap()
    }

    override func tearDownWithError() throws {
    }
    
    func testAutomaticPurge() throws {
        let app = XCUIApplication()
        
        // Dashboard
        bookExampleTransaction(with: 5.00, in: app)
        bookExampleTransaction(with: -3.00, in: app)
        
        XCTAssertEqual(app.tables.children(matching: .cell).count, 2)
        
        app.toolbars["Toolbar"].buttons["Menu"].tap()
        app.collectionViews.buttons["Transaktionen autom. Verrechnen"].tap()
        // automaticPurge == 1
        
        XCTAssertEqual(app.tables.children(matching: .cell).count, 1)
        
        bookExampleTransaction(with: -1.00, in: app)
        
        XCTAssertEqual(app.tables.children(matching: .cell).count, 1)
        
        app.toolbars["Toolbar"].buttons["Menu"].tap()
        app.collectionViews.buttons["Transaktionen autom. Verrechnen"].tap()
        // automaticPurge == 0
        
        bookExampleTransaction(with: -1.00, in: app)
        
        XCTAssertEqual(app.tables.children(matching: .cell).count, 2)
    }
    
    func bookExampleTransaction(with amount: Float, in app: XCUIApplication) {
        // Dashboard
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Form (Create)
        app.textFields["amountInputField"].typeText("\(String (format: "%.2f", amount))")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("t")
        app.buttons["submitButton"].tap()
    }
}
