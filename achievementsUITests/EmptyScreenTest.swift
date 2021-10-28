//
//  EmptyScreenTest.swift
//  achievementsUITests
//
//  Created by Maximilian Schluer on 28.10.21.
//

import XCTest

class EmptyScreenTest: XCTestCase {
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
    
    func testEmptyScreenForDashboard() throws {
        let app = XCUIApplication()
        let emptyScreenTextPredicate = NSPredicate(format: "label CONTAINS[c] %@", "Nothing to show.")
        
        // Dashboard
        XCTAssert(app.staticTexts.containing(emptyScreenTextPredicate).count > 0)
        app.buttons["Add"].tap()
        
        // Achievement Transaction Form (Create)
        app.textFields["amountInputField"].typeText("1")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("Test")
        
        app.buttons["submitButton"].tap()
        
        // Dashboard
        XCTAssertFalse(app.staticTexts.containing(emptyScreenTextPredicate).count > 0)
        app.tables.cells["transactionCell"].swipeLeft()
        app.staticTexts["Delete"].tap()
        XCTAssert(app.staticTexts.containing(emptyScreenTextPredicate).count > 0)
    }
    
    func testEmptyScreenForIncomeTemplates() throws {
        let app = XCUIApplication()
        let emptyScreenTextPredicate = NSPredicate(format: "label CONTAINS[c] %@", "There are no Templates yet.")
        
        // Dashboard
        app.buttons["incomeTemplates"].tap()
        
        // Transaction Templates (Incomes)
        XCTAssert(app.staticTexts.containing(emptyScreenTextPredicate).count > 0)
        app.buttons["Add"].tap()
        
        // Transaction Templates Form (Create)
        app.textFields["amountInputField"].typeText("1")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("t")
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates (Incomes)
        XCTAssertFalse(app.staticTexts.containing(emptyScreenTextPredicate).count > 0)
        app.tables.cells["templateCell"].swipeLeft()
        app.staticTexts["Delete"].tap()
        XCTAssert(app.staticTexts.containing(emptyScreenTextPredicate).count > 0)
    }
    
    func testEmptyScreenForExpenseTemplates() throws {
        let app = XCUIApplication()
        let emptyScreenTextPredicate = NSPredicate(format: "label CONTAINS[c] %@", "There are no Templates yet.")
        
        // Dashboard
        app.buttons["expenseTemplates"].tap()
        
        // Transaction Templates (Expenses)
        XCTAssert(app.staticTexts.containing(emptyScreenTextPredicate).count > 0)
        app.buttons["Add"].tap()
        
        // Transaction Templates Form (Create)
        app.textFields["amountInputField"].typeText("1")
        app.textFields["textInputField"].tap()
        app.textFields["textInputField"].typeText("t")
        
        app.buttons["submitButton"].tap()
        
        // Transaction Templates (Expenses)
        XCTAssertFalse(app.staticTexts.containing(emptyScreenTextPredicate).count > 0)
        app.tables.cells["templateCell"].swipeLeft()
        app.staticTexts["Delete"].tap()
        XCTAssert(app.staticTexts.containing(emptyScreenTextPredicate).count > 0)
    }
}
