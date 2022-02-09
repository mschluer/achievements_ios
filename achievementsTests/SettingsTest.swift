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
    
    func testChangingDivideIncomeTemplatesByRecurrence() {
        XCTAssertTrue(Settings.applicationSettings.divideIncomeTemplatesByRecurrence)
        
        Settings.applicationSettings.divideIncomeTemplatesByRecurrence = false
        XCTAssertFalse(Settings.applicationSettings.divideIncomeTemplatesByRecurrence)
        
    }
    
    func testChangingDivideExpenseTempaltesByRecurrence() {
        XCTAssertTrue(Settings.applicationSettings.divideExpenseTemplatesByRecurrence)
        
        Settings.applicationSettings.divideExpenseTemplatesByRecurrence = false
        XCTAssertFalse(Settings.applicationSettings.divideExpenseTemplatesByRecurrence)
    }
    
    func testChangingLineChartMaxAmountRecords() {
        XCTAssertEqual(Settings.statisticsSettings.lineChartMaxAmountRecords, 100)
        
        Settings.statisticsSettings.lineChartMaxAmountRecords = 101
        XCTAssertEqual(Settings.statisticsSettings.lineChartMaxAmountRecords, 101)
    }
    
    func testChangingDayDeltaChartMaxAmountEntries() {
        XCTAssertEqual(Settings.statisticsSettings.lineChartMaxAmountRecords, 100)
        
        Settings.statisticsSettings.lineChartMaxAmountRecords = 20
        XCTAssertEqual(Settings.statisticsSettings.lineChartMaxAmountRecords, 20)
    }
}
