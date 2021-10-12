//
//  SettingsTest.swift
//  achievementsTests
//
//  Created by Maximilian Schluer on 11.10.21.
//

import XCTest
@testable import achievements

class SettingsTest: XCTestCase {
    override func setUpWithError() throws {
        Settings.resetApplicationSettings()
    }

    override func tearDownWithError() throws {
    }
    
    func testChangingAutomaticPurge() {
        XCTAssertFalse(Settings.applicationSettings.automaticPurge)
        
        Settings.applicationSettings.automaticPurge = true
        XCTAssertTrue(Settings.applicationSettings.automaticPurge)
    }
}
