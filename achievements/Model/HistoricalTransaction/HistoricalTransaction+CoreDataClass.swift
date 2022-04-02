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
public class HistoricalTransaction: NSManagedObject, Codable {
    // MARK: Properties
    static let entityName = "HistoricalTransaction"
    
    // MARK: Codable Conformity
    enum CodingKeys : CodingKey {
        case amount, balance, date, hasRecentTransaction, text
    }
    
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.MissingManagedObjectContext
        }
        
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.amount = try container.decode(Float.self, forKey: .amount)
        self.balance = try container.decode(Float.self, forKey: .balance)
        self.date = try container.decode(Date.self, forKey: .date)
        self.text = try container.decode(String.self, forKey: .text)
        let hasRecentTransaction = try container.decode(Bool.self, forKey: .hasRecentTransaction)
        
        if(hasRecentTransaction) {
            let recentTransaction = AchievementTransaction(context: context)
            recentTransaction.amount = self.amount
            recentTransaction.date = self.date
            recentTransaction.text = self.text
            recentTransaction.historicalTransaction = self
            
            self.recentTransaction = recentTransaction
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(amount, forKey: .amount)
        try container.encode(balance, forKey: .balance)
        try container.encode(date, forKey: .date)
        try container.encode((recentTransaction != nil), forKey: .hasRecentTransaction)
        try container.encode(text, forKey: .text)
    }
        
    // MARK: Public Functions
    @nonobjc public func calculateHistoricalBalance(balanceBefore: Float) -> Float {
        return balanceBefore + self.amount
    }
    
    @nonobjc public func toString() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let dateString = formatter.string(for: date)
        
        return "\(dateString!): \(NumberHelper.formattedString(for: amount)) \(text ?? "n/a")"
    }
}
