//
//  SettingsTest.swift
//  achievementsUITests
//
//  Created by Maximilian Schluer on 21.10.21.
//

import XCTest

class SettingsTest: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false

        XCUIApplication().launch()
        
        // Reset App before each test
        let app = XCUIApplication()
        app.toolbars["Toolbar"].buttons["Menu"].tap()
        app.collectionViews.buttons["Reset"].tap()
        app.sheets["Sure?"].scrollViews.otherElements.buttons["Reset App"].tap()
    }

    override func tearDownWithError() throws {
    }
    
    func testResettingSettings() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Menu"].tap()
        app.collectionViews.buttons["Settle automatically"].tap()
        
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Form (Create)
        app.textFields["amountInputField"].typeText("5,00")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("Test Income")
        app.buttons["submitButton"].tap()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Form (Create)
        app.textFields["amountInputField"].typeText("1,00")
        app.buttons["+ / -"].tap()
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("Test Expense")
        app.buttons["submitButton"].tap()
        
        // Dashboard
        XCTAssertFalse(app.staticTexts["Test Expense"].exists)

        app.toolbars["Toolbar"].buttons["Menu"].tap()
        app.collectionViews.buttons["Settings"].tap()
        
        // Settings-Screen
        app.staticTexts["Reset Settings"].tap()
        app.sheets["Sure?"].buttons["Reset Settings"].tap()
        
        app.navigationBars.buttons["Dashboard"].tap()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Form (Create)
        app.textFields["amountInputField"].typeText("4,00")
        app.buttons["+ / -"].tap()
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("Test Expense")
        app.buttons["submitButton"].tap()
        
        // Dashboard
        XCTAssertTrue(app.tables.cells["transactionCell"].exists)
    }
    
    func testResettingApplication() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Form (Create)
        app.textFields["amountInputField"].typeText("5,00")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("Test Income")
        app.buttons["submitButton"].tap()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Menu"].tap()
        app.collectionViews.buttons["Settings"].tap()
        
        // Settings-Screen
        app.staticTexts["Reset Application"].tap()
        app.sheets["Sure?"].buttons["Reset Application"].tap()
        app.navigationBars.buttons["Dashboard"].tap()
        
        // Dashboard
        XCTAssertFalse(app.staticTexts["Test Income"].exists)
    }
    
    func testAccessingBackupRestoreScreen() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Menu"].tap()
        app.collectionViews.buttons["Settings"].tap()
        
        // Settings-Screen
        app.staticTexts["Backup / Restore"].tap()
        
        // Backup and Restore Screen
        XCTAssertTrue(app.buttons["Backup Data"].exists)
        XCTAssertTrue(app.buttons["Restore Data"].exists)
        
        /*
         The use case is covered by a separate unit test. Hence the screen is not likely to change,
         a UITest which fulfills the process will be added upon need.
         */
    }
}
