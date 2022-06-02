//
//  OnboardingTest.swift
//  achievementsUITests
//
//  Created by Maximilian Schluer on 01.06.22.
//

import XCTest

class OnboardingTest: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false

        XCUIApplication().launch()
    }

    override func tearDownWithError() throws {
    }
    
    func testOnboardingForDashboard() throws {
        let app = XCUIApplication()
        let onboardingTextPredicate = NSPredicate(format: "label CONTAINS[c] %@", "Welcome to the Achievements App!")
        
        // Dashboard
        XCTAssert(app.navigationBars.buttons["onboardingButton"].exists)
        app.navigationBars.buttons["onboardingButton"].tap()
        
        XCTAssert(app.textViews.containing(onboardingTextPredicate).count > 0)
        app.tap()
        
        XCTAssert(app.textViews.containing(onboardingTextPredicate).count == 0)
    }
    
    func testOnboardingForExpenseTemplates() throws {
        let app = XCUIApplication()
        let onboardingTextPredicate = NSPredicate(format: "label CONTAINS[c] %@", "Planned Expenses")
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["expenseTemplates"].tap()

        // Expense Templates
        XCTAssert(app.navigationBars.buttons["onboardingButton"].exists)
        app.navigationBars.buttons["onboardingButton"].tap()
        
        XCTAssert(app.textViews.containing(onboardingTextPredicate).count > 0)
        app.tap()
        
        XCTAssert(app.textViews.containing(onboardingTextPredicate).count == 0)
    }
    
    func testOnboardingForIncomeTemplates() throws {
        let app = XCUIApplication()
        let onboardingTextPredicate = NSPredicate(format: "label CONTAINS[c] %@", "Planned Incomes")
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["incomeTemplates"].tap()

        // Expense Templates
        XCTAssert(app.navigationBars.buttons["onboardingButton"].exists)
        app.navigationBars.buttons["onboardingButton"].tap()
        
        XCTAssert(app.textViews.containing(onboardingTextPredicate).count > 0)
        app.tap()
        
        XCTAssert(app.textViews.containing(onboardingTextPredicate).count == 0)
    }
    
    func testOnboardingForAchievementTransactionForm() throws {
        let app = XCUIApplication()
        let onboardingTextPredicate = NSPredicate(format: "label CONTAINS[c] %@", "Achievement Transaction Form")
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Add"].tap()

        // Expense Templates
        XCTAssert(app.navigationBars.buttons["onboardingButton"].exists)
        app.navigationBars.buttons["onboardingButton"].tap()
        
        XCTAssert(app.textViews.containing(onboardingTextPredicate).count > 0)
        app.tap()
        
        XCTAssert(app.textViews.containing(onboardingTextPredicate).count == 0)
    }
}
