//
//  TransactionTemplate+CoreDataClass.swift
//  achievements
//
//  Created by Maximilian Schluer on 04.09.21.
//
//

import Foundation
import CoreData

@objc(TransactionTemplate)
public class TransactionTemplate: NSManagedObject {
    static let entityName = "TransactionTemplate"
    
    @nonobjc func isQuickBookable() -> Bool {
        let textSet = self.text != nil && self.text != ""
        let amountSet = self.amount != 0.0
        
        return textSet && amountSet
    }
}
