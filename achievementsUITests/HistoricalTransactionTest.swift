//
//  HistoricalTransactionTest.swift
//  achievementsUITests
//
//  Created by Maximilian Schluer on 30.09.21.
//

import XCTest

class HistoricalTransactionTest: XCTestCase {
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

    func testAccessDetailView() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Form (Create)
        app.textFields["amountInputField"].typeText("5")
        
        let titleTextField = app.textFields["textInputField"]
        titleTextField.tap()
        titleTextField.typeText("Test-Text")
        
        app.buttons["submitButton"].tap()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Menu"].tap()
        app.collectionViews.buttons["History"].tap()
        
        // History
        app.staticTexts["(5,00)"].tap()
        
        // Historical Transaction Detail View
        XCTAssert(app.staticTexts["+5,00"].exists)
        XCTAssert(app.staticTexts["( +5,00 )"].exists)
        XCTAssert(app.staticTexts["Test-Text"].exists)
    }

}
