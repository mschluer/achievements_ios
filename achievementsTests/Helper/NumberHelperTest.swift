//
//  NumberHelperTest.swift
//  achievementsTests
//
//  Created by Maximilian Schluer on 26.10.21.
//

import XCTest
@testable import achievements

class NumberHelperTest: XCTestCase {
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    // MARK: formattedString(for number: Float) -> String
    func testNegativeNumber() throws {
        XCTAssertEqual("-123,45", NumberHelper.formattedString(for: -123.45))
    }
    
    func testNegativeNumberAboveThousand() throws {
        XCTAssertEqual("-1.234,56", NumberHelper.formattedString(for: -1234.56))
    }
    
    func testNegativeNumberWithoutDecimals() throws {
        XCTAssertEqual("-100,00", NumberHelper.formattedString(for: -100.0))
    }
    
    func testPositiveNumber() throws {
        XCTAssertEqual("123,45", NumberHelper.formattedString(for: 123.45))
    }
    
    func testPositiveNumberAboveThousand() throws {
        XCTAssertEqual("1.234,56", NumberHelper.formattedString(for: 1234.56))
    }
    
    func testPositiveNumberWithoutDecimals() throws {
        XCTAssertEqual("100,00", NumberHelper.formattedString(for: 100.0))
    }
    
    func testZero() throws {
        XCTAssertEqual("0,00", NumberHelper.formattedString(for: 0.0))
    }
    
    func testMinusZero() throws {
        XCTAssertEqual("-0,00", NumberHelper.formattedString(for: -0.0))
    }
    
    // MARK: formattedString(for number: Int) -> String
    func testNegativeInt() throws {
        XCTAssertEqual("-1", NumberHelper.formattedString(for: -1))
    }
    
    func testNegativeIntAboveThousand() throws {
        XCTAssertEqual("-1.000", NumberHelper.formattedString(for: -1000))
    }
    
    func testPositiveInt() throws {
        XCTAssertEqual("1", NumberHelper.formattedString(for: 1))
    }
    
    func testPositiveIntAboveThousand() throws {
        XCTAssertEqual("1.000", NumberHelper.formattedString(for: 1000))
    }
    
    func testZeroInt() throws {
        XCTAssertEqual("0", NumberHelper.formattedString(for: 0))
    }
    
    func testMinusZeroInt() throws {
        XCTAssertEqual("0", NumberHelper.formattedString(for: -0))
    }
}
