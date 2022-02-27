//
//  Account.swift
//  achievements
//
//  Created by Maximilian Schluer on 27.02.22.
//

import Foundation


/*
 
 This struct is the provisional solution for accounts which are to be implemented later.
 
 */
struct Account : Codable {
    var historicalTransactions : [HistoricalTransaction]
    var transactionTemplate : [TransactionTemplate]
}
