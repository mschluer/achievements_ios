//
//  TransactionTemplate+CoreDataProperties.swift
//  achievements
//
//  Created by Maximilian Schluer on 04.09.21.
//
//

import Foundation
import CoreData


extension TransactionTemplate {
    // MARK: Properties
    @NSManaged public var amount: Float
    @NSManaged public var orderIndex: Int16
    @NSManaged public var recurring: Bool
    @NSManaged public var text: String?

    // MARK: Public Functions
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionTemplate> {
        return NSFetchRequest<TransactionTemplate>(entityName: "TransactionTemplate")
    }
}

extension TransactionTemplate : Identifiable {
}
