//
//  TransactionTemplatesSortingTest.swift
//  achievementsUITests
//
//  Created by Maximilian Schluer on 24.10.21.
//

import XCTest

class TransactionTemplatesSortingTest: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false

        XCUIApplication().launch()
        
        // Reset App before each test
        let app = XCUIApplication()
        app.toolbars["Toolbar"].buttons["Menu"].tap()
        app.collectionViews.buttons["Reset"].tap()
        app.sheets["Sure?"].scrollViews.otherElements.buttons["Reset App"].tap()
        
        // Create Three Templates
        app.toolbars["Toolbar"].buttons["expenseTemplates"].tap()
        
        // Transaction Templates List (Expenses)
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("2")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("a")
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List (Expenses)
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("1")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("c")
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List (Expenses)
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("3")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("b")
        
        app.buttons["submitButton"].tap()
    }

    override func tearDownWithError() throws {
    }
    
    func testOrderingFromAtoZ() throws {
        let app = XCUIApplication()
        
        // Transaction Templates List (Expenses)
        app.toolbars["Toolbar"].buttons["Sort"].tap()
        app.collectionViews.buttons["A-Z"].tap()
        
        XCTAssert(app.tables.cells.element(boundBy: 0).staticTexts["a"].exists)
        XCTAssert(app.tables.cells.element(boundBy: 1).staticTexts["b"].exists)
        XCTAssert(app.tables.cells.element(boundBy: 2).staticTexts["c"].exists)
    }
    
    func testOrderingFromZtoA() throws {
        let app = XCUIApplication()
        
        // Transaction Templates List (Expenses)
        app.toolbars["Toolbar"].buttons["Sort"].tap()
        app.collectionViews.buttons["Z-A"].tap()
        
        XCTAssert(app.tables.cells.element(boundBy: 0).staticTexts["c"].exists)
        XCTAssert(app.tables.cells.element(boundBy: 1).staticTexts["b"].exists)
        XCTAssert(app.tables.cells.element(boundBy: 2).staticTexts["a"].exists)
    }
    
    func testOrderingByAmount() throws {
        let app = XCUIApplication()
        
        // Transaction Templates List (Expenses)
        app.toolbars["Toolbar"].buttons["Sort"].tap()
        app.collectionViews.buttons["Amount Ascending"].tap()
        
        XCTAssert(app.tables.cells.element(boundBy: 0).staticTexts["c"].exists)
        XCTAssert(app.tables.cells.element(boundBy: 1).staticTexts["a"].exists)
        XCTAssert(app.tables.cells.element(boundBy: 2).staticTexts["b"].exists)
    }
    
    func testOrderingByAmountDescending() throws {
        let app = XCUIApplication()
        
        // Transaction Templates List (Expenses)
        app.toolbars["Toolbar"].buttons["Sort"].tap()
        app.collectionViews.buttons["Amount Descending"].tap()
        
        XCTAssert(app.tables.cells.element(boundBy: 0).staticTexts["b"].exists)
        XCTAssert(app.tables.cells.element(boundBy: 1).staticTexts["a"].exists)
        XCTAssert(app.tables.cells.element(boundBy: 2).staticTexts["c"].exists)
    }
}
