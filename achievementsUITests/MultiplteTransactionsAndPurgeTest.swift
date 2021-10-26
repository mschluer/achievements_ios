//
//  MultiplteTransactionsAndPurgeTest.swift
//  achievementsUITests
//
//  Created by Maximilian Schluer on 30.09.21.
//

import XCTest

class MultiplteTransactionsAndPurgeTest: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false

        XCUIApplication().launch()
        
        // Reset App before each test
        let app = XCUIApplication()
        app.toolbars["Toolbar"].buttons["Menu"].tap()
        app.collectionViews.buttons["Reset"].tap()
        app.sheets["Sure?"].scrollViews.otherElements.buttons["Reset App"].tap()    }

    override func tearDownWithError() throws {
    }
    
    // MARK: Use Case
    func testMultipleBookingsAndPurge() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Form (Create)
        app.textFields["amountInputField"].typeText("3")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("alpha")
        app.buttons["submitButton"].tap()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Form (Create)
        app.textFields["amountInputField"].typeText("5")
        app.buttons["+ / -"].tap()
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("beta")
        app.buttons["submitButton"].tap()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Form (Create)
        app.textFields["amountInputField"].typeText("4")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("gamma")
        app.buttons["submitButton"].tap()
        
        // Dashboard
        XCTAssert(app.staticTexts["+2,00"].exists)
        app.toolbars["Toolbar"].buttons["Menu"].tap()
        app.collectionViews.buttons["Settle Transactions"].tap()
        XCTAssert(app.staticTexts["+2,00"].exists)
        app.toolbars["Toolbar"].buttons["Menu"].tap()
        app.collectionViews.buttons["Statistics"].tap()
        
        // Statistics
        XCTAssert(app.staticTexts["2,00"].exists)
        XCTAssert(app.staticTexts["0,00"].exists)
        XCTAssert(app.staticTexts["7,00"].exists)
        XCTAssert(app.staticTexts["-5,00"].exists)
        app.navigationBars.buttons["Dashboard"].tap()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Menu"].tap()
        app.collectionViews.buttons["History"].tap()
        
        // History
        XCTAssert(app.staticTexts["(3,00)"].exists)
        XCTAssert(app.staticTexts["(-2,00)"].exists)
        XCTAssert(app.staticTexts["(2,00)"].exists)
    }
}
