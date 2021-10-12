//
//  AchievementTransaction+CoreDataClass.swift
//  achievements
//
//  Created by Maximilian Schluer on 29.08.21.
//
//

import Foundation
import CoreData

@objc(AchievementTransaction)
public class AchievementTransaction: NSManagedObject {
    // MARK: Properties
    static let entityName = "AchievementTransaction"
    
    // MARK: Public Functions
    @nonobjc public func toString() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let dateString = formatter.string(for: date)
        
        return "\(dateString!): \(String (format: "%.2f", amount)) \(text ?? "n/a")"
    }
}
