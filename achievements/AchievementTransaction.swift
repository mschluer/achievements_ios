//
//  AchievementTransaction.swift
//  achievements
//
//  Created by Maximilian Schluer on 28.08.21.
//

import Foundation

class AchievementTransaction {
    let amount: Float
    let text: String
    let time: NSDate
    
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        let timeString = formatter.string(for: time)
        
        return "\(timeString!): \(String (format: "%.2f", amount)) \(text)"
        
    }
    
    init(amount: Float, text: String, time: NSDate) {
        self.amount = amount
        self.text = text
        self.time = time
    }
}
