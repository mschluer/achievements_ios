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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoricalTransaction> {
        return NSFetchRequest<HistoricalTransaction>(entityName: "HistoricalTransaction")
    }

    @NSManaged public var text: String?
    @NSManaged public var date: Date?
    @NSManaged public var amount: Float
    @NSManaged public var balance: Float
    @NSManaged public var recentTransaction: AchievementTransaction?

}

extension HistoricalTransaction : Identifiable {

}
