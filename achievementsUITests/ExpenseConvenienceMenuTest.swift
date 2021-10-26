//
//  ExpenseConvenienceMenuTest.swift
//  achievementsUITests
//
//  Created by Maximilian Schluer on 25.10.21.
//

import XCTest

class ExpenseConvenienceMenuTest: XCTestCase {
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
    
    func testBookingUniqueExpenseFromExpensesMenu() throws {
        let app = XCUIApplication()
        
        /* Add Unique Expense Template */
        // Dashboard
        app.toolbars["Toolbar"].buttons["expenseTemplates"].tap()
        
        // Transaction Templates List (Incomes)
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("2")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("Convenience")
        app.switches["recurringSwitch"].tap()
        app.buttons["Submit"].tap()
        
        // Transaction Templates List (Incomes)
        app.navigationBars.buttons["Dashboard"].tap()
        
        // Dashboard
        XCTAssert(app.staticTexts["+/- 0,00"].exists)
        app.toolbars["Toolbar"].buttons["expenseTemplates"].press(forDuration: 1)
        app.collectionViews.buttons["Convenience (-2,00)"].tap()
        XCTAssert(app.staticTexts["-2,00"].exists)
        app.toolbars["Toolbar"].buttons["expenseTemplates"].press(forDuration: 1)
        
        //Transaction Templates List (Incomes)
        XCTAssertFalse(app.staticTexts["Convenience (-2,00)"].exists)
    }
    
    func testBookingRecurringExpenseFromExpensesMenu() throws {
        let app = XCUIApplication()
        
        /* Add Recurring Expense Template */
        // Dashboard
        app.toolbars["Toolbar"].buttons["expenseTemplates"].tap()
        
        // Transaction Templates List (Expenses)
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("3")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("Convenience")
        app.buttons["Submit"].tap()
        
        // Transaction Templates List (Incomes)
        app.navigationBars.buttons["Dashboard"].tap()
        
        // Dashboard
        XCTAssert(app.staticTexts["+/- 0,00"].exists)
        app.toolbars["Toolbar"].buttons["expenseTemplates"].press(forDuration: 1)
        app.collectionViews.buttons["Convenience (-3,00)"].tap()
        XCTAssert(app.staticTexts["-3,00"].exists)
        
        app.toolbars["Toolbar"].buttons["expenseTemplates"].press(forDuration: 1)
        XCTAssert(app.collectionViews.buttons["Convenience (-3,00)"].exists)
    }
}
