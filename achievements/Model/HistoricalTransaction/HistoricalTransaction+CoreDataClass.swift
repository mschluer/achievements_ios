//
//  HistoricalTransaction+CoreDataClass.swift
//  achievements
//
//  Created by Maximilian Schluer on 02.09.21.
//
//

import Foundation
import CoreData

@objc(HistoricalTransaction)
public class HistoricalTransaction: NSManagedObject {
    static let entityName = "HistoricalTransaction"
    
    @nonobjc func calculateHistoricalBalance(balanceBefore: Float) -> Float {
        return balanceBefore + self.amount
    }
    
    @nonobjc func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        let dateString = formatter.string(for: date)
        
        return "\(dateString!): \(String (format: "%.2f", amount)) \(text ?? "n/a")"
    }
}
