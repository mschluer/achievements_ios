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
        
        XCTAssert(app.staticTexts.containing(onboardingTextPredicate).count > 0)
        app.tap()
        
        XCTAssert(app.staticTexts.containing(onboardingTextPredicate).count == 0)
    }
}
