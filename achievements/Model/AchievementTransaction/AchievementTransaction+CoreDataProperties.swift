//
//  AchievementTransaction+CoreDataProperties.swift
//  achievements
//
//  Created by Maximilian Schluer on 29.08.21.
//
//

import Foundation
import CoreData


extension AchievementTransaction {
    // MARK: Properties
    @NSManaged public var date: Date?
    @NSManaged public var text: String?
    @NSManaged public var amount: Float
    @NSManaged public var historicalTransaction: HistoricalTransaction?

    // MARK: Public Functions
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AchievementTransaction> {
        return NSFetchRequest<AchievementTransaction>(entityName: "AchievementTransaction")
    }
}

extension AchievementTransaction : Identifiable {
}
