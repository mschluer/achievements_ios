//
//  HistoricalTransaction+CoreDataProperties.swift
//  achievements
//
//  Created by Maximilian Schluer on 02.09.21.
//
//

import Foundation
import CoreData


extension HistoricalTransaction {
    // MARK: Properties
    @NSManaged public var amount: Float
    @NSManaged public var balance: Float
    @NSManaged public var date: Date?
    @NSManaged public var recentTransaction: AchievementTransaction?
    @NSManaged public var text: String?

    // MARK: Public Functions
    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoricalTransaction> {
        return NSFetchRequest<HistoricalTransaction>(entityName: "HistoricalTransaction")
    }
}

extension HistoricalTransaction : Identifiable {
}
