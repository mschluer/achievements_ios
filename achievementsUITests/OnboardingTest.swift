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
    
    func testOnboardingForStatistics() throws {
        let app = XCUIApplication()
        let onboardingTextPredicate = NSPredicate(format: "label CONTAINS[c] %@", "Statistics")
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Menu"].tap()
        app.collectionViews.buttons["Statistics"].tap()
        
        // Statistics Screen
        XCTAssert(app.navigationBars.buttons["onboardingButton"].exists)
        app.navigationBars.buttons["onboardingButton"].tap()
        
        XCTAssert(app.textViews.containing(onboardingTextPredicate).count > 0)
        app.tap()
        
        XCTAssert(app.textViews.containing(onboardingTextPredicate).count == 0)
    }
    
    func testOnboardingForHistory() throws {
        let app = XCUIApplication()
        let onboardingTextPredicate = NSPredicate(format: "label CONTAINS[c] %@", "History")
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Menu"].tap()
        app.collectionViews.buttons["History"].tap()
        
        // Histoy
        XCTAssert(app.navigationBars.buttons["onboardingButton"].exists)
        app.navigationBars.buttons["onboardingButton"].tap()
        
        XCTAssert(app.textViews.containing(onboardingTextPredicate).count > 0)
        app.tap()
        
        XCTAssert(app.textViews.containing(onboardingTextPredicate).count == 0)
    }
    
    func testOnboardingForTransactionTemplateForm() throws {
        let app = XCUIApplication()
        let onboardingTextPredicate = NSPredicate(format: "label CONTAINS[c] %@", "Transaction Template Form")
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["expenseTemplates"].tap()

        // Expense Templates
        app.toolbars["Toolbar"].buttons["Add"].tap()
        
        // Transaction Template Form
        XCTAssert(app.navigationBars.buttons["onboardingButton"].exists)
        app.navigationBars.buttons["onboardingButton"].tap()
        
        XCTAssert(app.textViews.containing(onboardingTextPredicate).count > 0)
        app.tap()
        
        XCTAssert(app.textViews.containing(onboardingTextPredicate).count == 0)
    }
    
    func testOnboardingForBackupRestoreScreen() throws {
        let app = XCUIApplication()
        let onboardingTextPredicate = NSPredicate(format: "label CONTAINS[c] %@", "Backup / Restore")
        
        // Dashboard
        app.toolbars["Toolbar"].buttons["Menu"].tap()
        app.collectionViews.buttons["Settings"].tap()

        // Settings
        app.staticTexts["Backup / Restore"].tap()
        
        // Backup & Restore
        XCTAssert(app.navigationBars.buttons["onboardingButton"].exists)
        app.navigationBars.buttons["onboardingButton"].tap()
        
        XCTAssert(app.textViews.containing(onboardingTextPredicate).count > 0)
        app.tap()
        
        XCTAssert(app.textViews.containing(onboardingTextPredicate).count == 0)
    }
}
