//
//  DayHelperTest.swift
//  achievementsTests
//
//  Created by Maximilian Schluer on 19.12.21.
//

import XCTest
@testable import achievements

class DayHelperTest: XCTestCase {
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    // MARK: createDayArray(from beginDate: Date, to endDate: Date) -> [Date]
    func testCreateDateArray() throws {
        // Prepare Dates
        let yesterday = Calendar.current.dateComponents([.year, .month, .day], from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        let today     = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let tomorrow  = Calendar.current.dateComponents([.year, .month, .day], from: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        
        let dateArray = DateHelper.createDayArray(from: yesterday, to: tomorrow)
        
        XCTAssertEqual(dateArray.count, 3)
        
        // Check Entries
        XCTAssertEqual(dateArray[0], yesterday)
        XCTAssertEqual(dateArray[1], today)
        XCTAssertEqual(dateArray[2], tomorrow)
    }
    
    func testEqualDay() throws {
        let dateArray = DateHelper.createDayArray(from: Date(), to: Date())
        
        XCTAssertEqual(dateArray.count, 1)
        XCTAssertEqual(dateArray[0], Calendar.current.dateComponents([.year, .month, .day], from: Date()))
    }
    
    func testEndDayBeforeBeginDay() throws {
        // Prepare Dates
        let yesterday = Calendar.current.dateComponents([.year, .month, .day], from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        let today     = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let tomorrow  = Calendar.current.dateComponents([.year, .month, .day], from: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        
        let dateArray = DateHelper.createDayArray(from: tomorrow, to: yesterday)
        
        XCTAssertEqual(dateArray.count, 3)
        
        // Check Entries
        XCTAssertEqual(dateArray[0], yesterday)
        XCTAssertEqual(dateArray[1], today)
        XCTAssertEqual(dateArray[2], tomorrow)
    }
    
    func testStabilityForDayNotSet() throws {
        XCTAssertEqual(
            DateHelper.createDayArray(
                from: Calendar.current.dateComponents([ .year ], from: Date()),
                to: Calendar.current.dateComponents([ .year ], from: Date()))
                .count,
            1)
    }
}
