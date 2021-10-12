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
    // MARK: Properties
    static let entityName = "HistoricalTransaction"
    
    // MARK: Public Functions
    @nonobjc public func calculateHistoricalBalance(balanceBefore: Float) -> Float {
        return balanceBefore + self.amount
    }
    
    @nonobjc public func toString() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let dateString = formatter.string(for: date)
        
        return "\(dateString!): \(String (format: "%.2f", amount)) \(text ?? "n/a")"
    }
}
