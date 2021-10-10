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
        app.sheets["Sicher?"].scrollViews.otherElements.buttons["App Zurücksetzen"].tap()
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
        app.textFields["amountInputField"].typeText("5.00")
        
        let titleTextField = app.textFields["textInputField"]
        titleTextField.tap()
        titleTextField.typeText("Test Expense Template")
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List
        XCTAssert(app.staticTexts["Test Expense Template"].exists)
        XCTAssert(app.staticTexts["-5.00"].exists)
        
        app.tables.staticTexts["Test Expense Template"].swipeLeft()
        app.staticTexts["Bearbeiten"].tap()
        
        // Transaction Tempalte Form (Edit)
        for _ in 0...3 {
            app.textFields["amountInputField"].typeText(XCUIKeyboardKey.delete.rawValue)
        }
        app.textFields["amountInputField"].typeText("7.00")
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List
        XCTAssert(app.staticTexts["Test Expense Template"].exists)
        XCTAssert(app.staticTexts["-7.00"].exists)
        
        app.tables.staticTexts["Test Expense Template"].swipeLeft()
        app.staticTexts["Löschen"].tap()
        
        XCTAssertFalse(app.staticTexts["Test Expense Template"].exists)
        XCTAssertFalse(app.staticTexts["-7.00"].exists)
    }

    // MARK: Use Cases
    func testQuickBook() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["expenseTemplates"].tap()
        
        // Transaction Templates List
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("5.00")
        
        let titleTextField = app.textFields["textInputField"]
        titleTextField.tap()
        titleTextField.typeText("Test Template")
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List
        XCTAssert(app.staticTexts["Test Template"].exists)
        XCTAssert(app.staticTexts["-5.00"].exists)
        
        app.tables.staticTexts["Test Template"].swipeRight()
        app.staticTexts["Buchen"].tap()
        app.navigationBars.buttons["Dashboard"].tap()
        
        // Dashboard
        XCTAssert(app.staticTexts["-5.00"].exists)
        app.tables.cells["transactionCell"].tap()
        
        // Transaction Detail View
        XCTAssert(app.staticTexts["-5.00"].exists)
        XCTAssert(app.staticTexts["( -5.00 )"].exists)
        XCTAssert(app.staticTexts["Test Template"].exists)
    }
    
    func testFormBookProcess() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["expenseTemplates"].tap()
        
        // Transaction Templates List
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("9.00")
        
        let titleTextField = app.textFields["textInputField"]
        titleTextField.tap()
        titleTextField.typeText("Extended Test Template")
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List
        XCTAssert(app.staticTexts["Extended Test Template"].exists)
        XCTAssert(app.staticTexts["-9.00"].exists)
        app.tables.staticTexts["Extended Test Template"].tap()
        
        // Achievement Transaction Form
        app.buttons["Speichern"].tap()
        
        // Transaction Templates List
        app.navigationBars.buttons["Dashboard"].tap()
        
        // Dashboard
        XCTAssert(app.staticTexts["-9.00"].exists)
        app.tables.cells["transactionCell"].tap()
        
        // Transaction Detail View
        XCTAssert(app.staticTexts["-9.00"].exists)
        XCTAssert(app.staticTexts["( -9.00 )"].exists)
        XCTAssert(app.staticTexts["Extended Test Template"].exists)
    }
    
    func testNonRecurringTemplate() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["expenseTemplates"].tap()
        
        // Transaction Templates List
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("10.00")
        
        let titleTextField = app.textFields["textInputField"]
        titleTextField.tap()
        titleTextField.typeText("Non Recurring Test Template")
        
        app.switches["recurringSwitch"].tap()
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List
        XCTAssert(app.staticTexts["Non Recurring Test Template"].exists)
        XCTAssert(app.staticTexts["-10.00"].exists)
        
        app.tables.staticTexts["Non Recurring Test Template"].swipeRight()
        app.staticTexts["Buchen"].tap()
        app.navigationBars.buttons["Dashboard"].tap()
        
        // Dashboard
        XCTAssert(app.staticTexts["-10.00"].exists)
        app.tables.cells["transactionCell"].tap()
        
        // Transaction Detail View
        XCTAssert(app.staticTexts["-10.00"].exists)
        XCTAssert(app.staticTexts["( -10.00 )"].exists)
        XCTAssert(app.staticTexts["Non Recurring Test Template"].exists)
    }
    
    func testProgressWheelForPlannedExpense() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["expenseTemplates"].tap()
        
        // Transaction Templates List
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("100.00")
        
        let titleTextField = app.textFields["textInputField"]
        titleTextField.tap()
        titleTextField.typeText("Progress Wheel Test Expense")
        
        app.switches["recurringSwitch"].tap()
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List
        app.navigationBars.buttons["Dashboard"].tap()
        
        // Dashboard
        XCTAssertTrue(app.staticTexts["+/- 0.00"].exists)
        app.otherElements["progressWheel"].tap()
        XCTAssertTrue(app.staticTexts["(+0.00)"].exists)
        app.otherElements["progressWheel"].tap()
        XCTAssertTrue(app.staticTexts["(-100.00)"].exists)
        app.otherElements["progressWheel"].tap()
        XCTAssertTrue(app.staticTexts["0.00 %"].exists)
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Achievement Transaction Form (Create)
        app.textFields["amountInputField"].typeText("55.20")
        
        titleTextField.tap()
        titleTextField.typeText("Progress Wheel Test Income")
        
        app.buttons["submitButton"].tap()
        
        // Dashboard
        XCTAssertTrue(app.staticTexts["+55.20"].exists)
        app.otherElements["progressWheel"].tap()
        XCTAssertTrue(app.staticTexts["(+55.20)"].exists)
        app.otherElements["progressWheel"].tap()
        XCTAssertTrue(app.staticTexts["(-44.80)"].exists)
        app.otherElements["progressWheel"].tap()
        XCTAssertTrue(app.staticTexts["55.20 %"].exists)
    }
}
