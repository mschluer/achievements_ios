//
//  NumberHelper.swift
//  achievements
//
//  Created by Maximilian Schluer on 26.10.21.
//

import Foundation

class NumberHelper {
    static func formattedString(for number: Float) -> String {
        let numberFormatter = NumberFormatter()
        
        numberFormatter.groupingSeparator = "."
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.decimalSeparator = ","
        
        return numberFormatter.string(for: number)!
    }
    
    static func formattedString(for number: Int) -> String {
        let numberFormatter = NumberFormatter()
        
        numberFormatter.groupingSeparator = "."
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter.string(for: number)!
    }
}
