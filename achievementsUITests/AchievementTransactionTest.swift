//
//  AchievementTransactionTest.swift
//  achievementsUITests
//
//  Created by Maximilian Schluer on 29.09.21.
//

import XCTest

class AchievementTransactionTest: XCTestCase {
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

    // MARK: CRUD
    func testCRUDtransaction() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Form (Create)
        app.textFields["amountInputField"].typeText("5,50")
        
        let titleTextField = app.textFields["textInputField"]
        titleTextField.tap()
        titleTextField.typeText("Test-Text")
        
        app.buttons["submitButton"].tap()
        
        // Dashboard
        XCTAssert(app.staticTexts["+5,50"].exists)
        app.tables.cells["transactionCell"].tap()
        
        // Transaction Detail View
        XCTAssert(app.staticTexts["+5,50"].exists)
        XCTAssert(app.staticTexts["( +5,50 )"].exists)
        XCTAssert(app.staticTexts["Test-Text"].exists)
        app.navigationBars["Details"].buttons["Dashboard"].tap()
        
        // Dashboard
        app.tables.cells["transactionCell"].swipeLeft()
        app.tables.buttons["Edit"].tap()
    
        // Transaction Form (Edit)
        app.buttons["+ / -"].tap()
        app.buttons["submitButton"].tap()
        
        // Dashboard
        XCTAssert(app.staticTexts["-5,50"].exists)
        app.tables.cells["transactionCell"].swipeLeft()
        app.tables/*@START_MENU_TOKEN@*/.buttons["Delete"]/*[[".cells[\"transactionCell\"].buttons[\"Delete\"]",".buttons[\"Delete\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        XCTAssert(app.staticTexts["+/- 0,00"].exists)
    }
    
    // MARK: Swipe Right Test
    func testSwipeRightDuplication() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Form (Create)
        app.textFields["amountInputField"].typeText("5,50")
        
        let titleTextField = app.textFields["textInputField"]
        titleTextField.tap()
        titleTextField.typeText("dup")
        
        app.buttons["submitButton"].tap()
        
        // Dashboard
        XCTAssert(app.staticTexts["+5,50"].exists)
        app.tables.cells["transactionCell"].swipeRight()
        app.tables.buttons["Duplicate"].tap()
        XCTAssert(app.staticTexts["+11,00"].exists)
    }
    
    // MARK: Detail View Test
    func testEditFromDetailView() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Form (Create)
        app.textFields["amountInputField"].typeText("1")
        
        let titleTextField = app.textFields["textInputField"]
        titleTextField.tap()
        titleTextField.typeText("t0")
        
        app.buttons["submitButton"].tap()
        
        // Dashboard
        app.tables.cells["transactionCell"].tap()
        
        // Transaction Detail View
        XCTAssert(app.buttons["editButton"].exists)
        app.buttons["editButton"].tap()
        
        // Achievements Transaction Form (Edit)
        app.textFields["amountInputField"].buttons["Clear text"].tap()
        app.textFields["amountInputField"].typeText("2")
        app.buttons["submitButton"].tap()
        
        // Transaction Detail View
        XCTAssert(app.staticTexts["+2,00"].exists)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // Dashboard
        XCTAssert(app.staticTexts["+2,00"].exists)
    }
    
    func testCancelEditFromDetailView() throws {
        let app = XCUIApplication()
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Form (Create)
        app.textFields["amountInputField"].typeText("1")
        
        let titleTextField = app.textFields["textInputField"]
        titleTextField.tap()
        titleTextField.typeText("t0")
        
        app.buttons["submitButton"].tap()
        
        // Dashboard
        app.tables.cells["transactionCell"].tap()
        
        // Transaction Detail View
        XCTAssert(app.buttons["editButton"].exists)
        app.buttons["editButton"].tap()
        
        // Achievements Transaction Form (Edit)
        app.textFields["amountInputField"].buttons["Clear text"].tap()
        app.textFields["amountInputField"].typeText("2")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // Transaction Detail View
        XCTAssert(app.staticTexts["+1,00"].exists)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // Dashboard
        XCTAssert(app.staticTexts["+1,00"].exists)
    }
}
