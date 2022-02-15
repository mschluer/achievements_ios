//
//  StatisticsPresenter.swift
//  achievements
//
//  Created by Maximilian Schluer on 12.10.21.
//

import Foundation
import UIKit

class StatisticsPresenter {
    // MARK: Persistence Models
    let achievementsDataModel : AchievementsDataModel
    
    private let storyboard = UIStoryboard(name: "StatisticsPresenterStoryboard", bundle: nil)
    
    // MARK: Initializers
    init(achievementsDataModel : AchievementsDataModel) {
        self.achievementsDataModel = achievementsDataModel
    }
    
    // MARK: Take Over Functions
    public func takeOver(from initiator : UIViewController) {
        let viewController = storyboard.instantiateViewController(withIdentifier: "StatisticsTableViewController") as! StatisticsTableViewController
        
        // Set Data
        viewController.totalRecentIncomes = achievementsDataModel.totalRecentIncomes
        viewController.totalRecentExpenses = achievementsDataModel.totalRecentExpenses
        viewController.amountRecentIncomes = achievementsDataModel.recentIncomes.count
        viewController.amountRecentExpenses = achievementsDataModel.recentExpenses.count
        
        viewController.totalIncomes = achievementsDataModel.totalHistoricalIncomes
        viewController.totalExpenses = achievementsDataModel.totalHistoricalExpenses
        viewController.amountIncomes = achievementsDataModel.historicalIncomes.count
        viewController.amountExpenses = achievementsDataModel.historicalExpenses.count
        
        let groupedHistoricalTransactions = achievementsDataModel.groupedHistoricalTransactions
        
        DispatchQueue.global().async {
            let endOfDayBalances = self.calculateEndOfDayBalances(from: groupedHistoricalTransactions)
            
            viewController.endOfDayBalances = endOfDayBalances
            viewController.endOfDayBalanceDeltas = self.calculateEndOfDayBalanceDeltas(from: endOfDayBalances)
        }
        
        // Show
        initiator.show(viewController, sender: self)
    }
    
    // MARK: Public Functions
    public func calculateEndOfDayBalances(from dictionary: [Date: [HistoricalTransaction]]) -> [Date : Float] {
        var result : [Date : Float] = [:]
        if dictionary.isEmpty {
            return result
        }
        
        // Prepare Keys
        var groupedTransactionsKeys = Array(dictionary.keys)
        groupedTransactionsKeys.sort(by: >)
        
        let dateArray = DateHelper.createDayArray(
            from: groupedTransactionsKeys.first!,
            to: groupedTransactionsKeys.last!)
        
        var currentBalance : Float = 0.0
        
        for date in dateArray {
            if var currentGroup = dictionary[Calendar.current.date(from: date)!] {
                currentGroup.sort(by: {a, b in
                    a.date! > b.date!
                })
                
                currentBalance = currentGroup.last!.balance
            }
            result[Calendar.current.date(from: date)!] = currentBalance
        }
        
        return result
    }
    
    public func calculateEndOfDayBalanceDeltas(from endOfDayBalances: [Date : Float]) -> [Date : Float] {
        var result : [Date : Float] = [:]
        
        if endOfDayBalances.isEmpty {
            return result
        }
        
        var groupedTransactionsKeys = Array(endOfDayBalances.keys)
        groupedTransactionsKeys.sort(by: <)
        var dayBeforeBalance : Float = endOfDayBalances[groupedTransactionsKeys.first!]!
        
        for date in groupedTransactionsKeys {
            result[date] = endOfDayBalances[date]! - dayBeforeBalance
            dayBeforeBalance = endOfDayBalances[date]!
        }
        
        return result
    }
}
