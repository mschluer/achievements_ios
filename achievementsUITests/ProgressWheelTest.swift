//
//  ProgressWheelTest.swift
//  achievementsUITests
//
//  Created by Maximilian Schluer on 11.10.21.
//

import XCTest

class ProgressWheelTest: XCTestCase {
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
