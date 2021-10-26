//
//  ExpenseTemplateTest.swift
//  achievementsUITests
//
//  Created by Maximilian Schluer on 08.10.21.
//

import XCTest

class ExpenseTemplateTest: XCTestCase {
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

    // MARK: CUD
    func testCUDtemplate() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["expenseTemplates"].tap()
        
        // Transaction Templates List
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("5")
        
        let titleTextField = app.textFields["textInputField"]
        titleTextField.tap()
        titleTextField.typeText("Test Expense Template")
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List
        XCTAssert(app.staticTexts["Test Expense Template"].exists)
        XCTAssert(app.staticTexts["-5,00"].exists)
        
        app.tables.staticTexts["Test Expense Template"].swipeLeft()
        app.staticTexts["Edit"].tap()
        
        // Transaction Tempalte Form (Edit)
        for _ in 0...3 {
            app.textFields["amountInputField"].typeText(XCUIKeyboardKey.delete.rawValue)
        }
        app.textFields["amountInputField"].typeText("7")
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List
        XCTAssert(app.staticTexts["Test Expense Template"].exists)
        XCTAssert(app.staticTexts["-7,00"].exists)
        
        app.tables.staticTexts["Test Expense Template"].swipeLeft()
        app.staticTexts["Delete"].tap()
        
        XCTAssertFalse(app.staticTexts["Test Expense Template"].exists)
        XCTAssertFalse(app.staticTexts["-7,00"].exists)
    }

    // MARK: Use Cases
    
    func testQuickBookNotPossible() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["expenseTemplates"].tap()
        
        // Transaction Templates List
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("5")
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List
        XCTAssert(app.staticTexts["-5,00"].exists)
        
        app.tables.staticTexts["-5,00"].swipeRight()
        XCTAssertFalse(app.staticTexts["Book"].exists)
    }
    
    func testFormBookProcess() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["expenseTemplates"].tap()
        
        // Transaction Templates List
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("9")
        
        let titleTextField = app.textFields["textInputField"]
        titleTextField.tap()
        titleTextField.typeText("Extended Test Template")
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List
        XCTAssert(app.staticTexts["Extended Test Template"].exists)
        XCTAssert(app.staticTexts["-9,00"].exists)
        app.tables.staticTexts["Extended Test Template"].tap()
        
        // Achievement Transaction Form
        app.buttons["Submit"].tap()
        
        // Transaction Templates List
        app.navigationBars.buttons["Dashboard"].tap()
        
        // Dashboard
        XCTAssert(app.staticTexts["-9,00"].exists)
        app.tables.cells["transactionCell"].tap()
        
        // Transaction Detail View
        XCTAssert(app.staticTexts["-9,00"].exists)
        XCTAssert(app.staticTexts["( -9,00 )"].exists)
        XCTAssert(app.staticTexts["Extended Test Template"].exists)
    }
    
    func testNonRecurringTemplate() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["expenseTemplates"].tap()
        
        // Transaction Templates List
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("10")
        
        let titleTextField = app.textFields["textInputField"]
        titleTextField.tap()
        titleTextField.typeText("Non Recurring Test Template")
        
        app.switches["recurringSwitch"].tap()
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List
        XCTAssert(app.staticTexts["Non Recurring Test Template"].exists)
        XCTAssert(app.staticTexts["-10,00"].exists)
        
        app.tables.staticTexts["Non Recurring Test Template"].swipeRight()
        app.staticTexts["Book"].tap()
        app.navigationBars.buttons["Dashboard"].tap()
        
        // Dashboard
        XCTAssert(app.staticTexts["-10,00"].exists)
        app.tables.cells["transactionCell"].tap()
        
        // Transaction Detail View
        XCTAssert(app.staticTexts["-10,00"].exists)
        XCTAssert(app.staticTexts["( -10,00 )"].exists)
        XCTAssert(app.staticTexts["Non Recurring Test Template"].exists)
    }
}
