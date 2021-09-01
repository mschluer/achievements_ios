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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AchievementTransaction> {
        return NSFetchRequest<AchievementTransaction>(entityName: "AchievementTransaction")
    }

    @NSManaged public var date: Date?
    @NSManaged public var text: String?
    @NSManaged public var amount: Float

}

extension AchievementTransaction : Identifiable {

}
