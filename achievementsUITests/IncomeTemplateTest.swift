//
//  TransactionTemplateTest.swift
//  achievementsUITests
//
//  Created by Maximilian Schluer on 30.09.21.
//

import XCTest

class IncomeTemplateTest: XCTestCase {
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
        app.toolbars["Toolbar"].buttons["incomeTemplates"].tap()
        
        // Transaction Templates List
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("5")
        
        let titleTextField = app.textFields["textInputField"]
        titleTextField.tap()
        titleTextField.typeText("Test-Template")
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List
        XCTAssert(app.staticTexts["Test-Template"].exists)
        XCTAssert(app.staticTexts["5,00"].exists)
        
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Test-Template"]/*[[".cells.staticTexts[\"Test-Template\"]",".staticTexts[\"Test-Template\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeLeft()
        app.staticTexts["Edit"].tap()
        
        // Transaction Tempalte Form (Edit)
        for _ in 0...4 {
            app.textFields["amountInputField"].typeText(XCUIKeyboardKey.delete.rawValue)
        }
        app.textFields["amountInputField"].typeText("7,00")
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List
        XCTAssert(app.staticTexts["Test-Template"].exists)
        XCTAssert(app.staticTexts["7,00"].exists)
        
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Test-Template"]/*[[".cells.staticTexts[\"Test-Template\"]",".staticTexts[\"Test-Template\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeLeft()
        app.staticTexts["Delete"].tap()
        
        XCTAssertFalse(app.staticTexts["Test-Template"].exists)
        XCTAssertFalse(app.staticTexts["7,00"].exists)
    }
    
    // MARK: Use Cases
    func testBookingTemplates() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["incomeTemplates"].tap()
        
        // Transaction Templates List
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("5")
        
        let titleTextField = app.textFields["textInputField"]
        titleTextField.tap()
        titleTextField.typeText("Test-Template")
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List
        XCTAssert(app.staticTexts["Test-Template"].exists)
        XCTAssert(app.staticTexts["5,00"].exists)
        
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Test-Template"]/*[[".cells.staticTexts[\"Test-Template\"]",".staticTexts[\"Test-Template\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeRight()
        app.staticTexts["Book"].tap()
        app.navigationBars.buttons["Dashboard"].tap()
        
        // Dashboard
        XCTAssert(app.staticTexts["+5,00"].exists)
        app.tables.cells["transactionCell"].tap()
        
        // Transaction Detail View
        XCTAssert(app.staticTexts["+5,00"].exists)
        XCTAssert(app.staticTexts["( +5,00 )"].exists)
        XCTAssert(app.staticTexts["Test-Template"].exists)
    }
    
    func testQuickBook() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["incomeTemplates"].tap()
        
        // Transaction Templates List
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("5,00")
        
        let titleTextField = app.textFields["textInputField"]
        titleTextField.tap()
        titleTextField.typeText("Test Template")
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List
        XCTAssert(app.staticTexts["Test Template"].exists)
        XCTAssert(app.staticTexts["5,00"].exists)
        
        app.tables.staticTexts["Test Template"].swipeRight()
        app.staticTexts["Book"].tap()
        app.navigationBars.buttons["Dashboard"].tap()
        
        // Dashboard
        XCTAssert(app.staticTexts["+5,00"].exists)
        app.tables.cells["transactionCell"].tap()
        
        // Transaction Detail View
        XCTAssert(app.staticTexts["+5,00"].exists)
        XCTAssert(app.staticTexts["( +5,00 )"].exists)
        XCTAssert(app.staticTexts["Test Template"].exists)
    }
    
    func testNonRecurringTemplate() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["incomeTemplates"].tap()
        
        // Transaction Templates List
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form (Create)
        app.textFields["amountInputField"].typeText("6,75")
        
        let titleTextField = app.textFields["textInputField"]
        titleTextField.tap()
        titleTextField.typeText("Test-Template")
        
        app.switches["recurringSwitch"].tap()
        app.buttons["submitButton"].tap()
        
        // Transaction Templates List
        XCTAssert(app.staticTexts["Test-Template"].exists)
        XCTAssert(app.staticTexts["6,75"].exists)
        
        app.tables.staticTexts["Test-Template"].swipeRight()
        app.staticTexts["Book"].tap()
        
        XCTAssertFalse(app.staticTexts["6,75"].exists)
        
        app.navigationBars.buttons["Dashboard"].tap()
        
        // Dashboard
        XCTAssert(app.staticTexts["+6,75"].exists)
        app.tables.cells["transactionCell"].tap()
    }
}
