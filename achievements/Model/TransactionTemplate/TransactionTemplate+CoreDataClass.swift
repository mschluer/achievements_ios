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
public class TransactionTemplate: NSManagedObject, Codable {
    // MARK: Properties
    static let entityName = "TransactionTemplate"
    
    // MARK: Codable Conformity
    enum CodingKeys : CodingKey {
        case amount, orderIndex, recurring, text
    }
    
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.MissingManagedObjectContext
        }
        
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.amount = try container.decode(Float.self, forKey: .amount)
        self.orderIndex = try container.decode(Int16.self, forKey: .orderIndex)
        self.recurring = try container.decode(Bool.self, forKey: .recurring)
        self.text = try container.decode(String.self, forKey: .text)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(amount, forKey: .amount)
        try container.encode(orderIndex, forKey: .orderIndex)
        try container.encode(recurring, forKey: .recurring)
        try container.encode(text, forKey: .text)
    }
    
    // MARK: Public Functions
    @nonobjc func isQuickBookable() -> Bool {
        let textSet = self.text != nil && self.text != ""
        let amountSet = self.amount != 0.0
        
        return textSet && amountSet
    }
}
