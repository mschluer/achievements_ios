//
//  TransactionTemplatesDragNDropTest.swift
//  achievementsUITests
//
//  Created by Maximilian Schluer on 24.10.21.
//

import XCTest

class TransactionTemplatesDragNDropTest: XCTestCase {
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
    
    func testReorder() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["expenseTemplates"].tap()
        
        // Transaction Templates List (Expenses)
        app.toolbars.buttons["Sort"].tap()
        app.collectionViews.buttons["Split Unique/Recurring"].tap()
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("1")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("1st")
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List (Expenses)
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("3")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("3rd")
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List (Expenses)
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("2")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("2nd")
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List (Expenses)
        app.tables.staticTexts["3rd"].press(forDuration: 1, thenDragTo: app.tables.staticTexts["2nd"], withVelocity: .slow, thenHoldForDuration: 1)
        _ = app.wait(for: .unknown, timeout: 1)
        app.navigationBars.buttons["Dashboard"].tap()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["expenseTemplates"].tap()
        
        // Transaction Templates List (Expenses)
        XCTAssert(app.tables.cells.element(boundBy: 0).staticTexts["3rd"].exists)
        XCTAssert(app.tables.cells.element(boundBy: 1).staticTexts["2nd"].exists)
        XCTAssert(app.tables.cells.element(boundBy: 2).staticTexts["1st"].exists)
    }
    
    func testDroppingRecurringTemplateIntoNonRecurring() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["expenseTemplates"].tap()
        
        // Transaction Templates List (Expenses)
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("1")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("nonrec")
        app.switches["recurringSwitch"].tap()
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List (Expenses)
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("2")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("rec")
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List (Expenses)
        app.tables.staticTexts["rec"].press(forDuration: 1, thenDragTo: app.tables.staticTexts["nonrec"])
        _ = app.wait(for: .unknown, timeout: 1)
        app.navigationBars.buttons["Dashboard"].tap()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["expenseTemplates"].tap()
        
        // Transaction Templates List (Expenses)
        app.tables.children(matching: .cell).element(boundBy: 0).staticTexts["rec"].tap()
        
        // Achievement Transaction Form (Book from Template)
        app.buttons["Submit"].tap()
        
        // Transaction Templates List (Expenses)
        XCTAssertFalse(app.staticTexts["rec"].exists)
    }
    
    func testDroppingNonRecurringTemplateInRecurring() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["expenseTemplates"].tap()
        
        // Transaction Templates List (Expenses)
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("1")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("nonrec")
        app.switches["recurringSwitch"].tap()
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List (Expenses)
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("2")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("rec")
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List (Expenses)
        app.tables.staticTexts["nonrec"].press(forDuration: 1, thenDragTo: app.tables.staticTexts["rec"])
        _ = app.wait(for: .unknown, timeout: 1)
        app.navigationBars.buttons["Dashboard"].tap()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["expenseTemplates"].tap()
        
        // Transaction Templates List (Expenses)
        app.tables.children(matching: .cell).element(boundBy: 1).staticTexts["rec"].tap()
        
        // Achievement Transaction Form (Book from Template)
        app.buttons["Submit"].tap()
        
        // Transaction Templates List (Expenses)
        XCTAssertTrue(app.staticTexts["nonrec"].exists)
    }
}
