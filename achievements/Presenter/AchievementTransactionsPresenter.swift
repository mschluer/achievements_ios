//
//  AchievementTransactionsPresenter.swift
//  achievements
//
//  Created by Maximilian Schluer on 14.10.21.
//

import Foundation
import UIKit

class AchievementTransactionsPresenter {
    // MARK: Persistence Models
    let achievementsDataModel : AchievementsDataModel
    
    private let storyboard = UIStoryboard(name: "AchievementTransactionsPresenterStoryboard", bundle: nil)
    
    // MARK: Initializers
    init(achievevementsDataModel : AchievementsDataModel) {
        self.achievementsDataModel = achievevementsDataModel
    }
    
    // MARK: Public Functions
    public func bookAchievementTransaction(from initiator: UIViewController) {
        let viewController = storyboard.instantiateViewController(withIdentifier: "AchievementTransactionFormController") as! AchievementTransactionFormController
        viewController.achievementsDataModel = achievementsDataModel
        
        initiator.show(viewController, sender: self)
    }
    
    public func bookAchievementTransaction(from initiator: UIViewController, template: TransactionTemplate) {
        let viewController = storyboard.instantiateViewController(withIdentifier: "AchievementTransactionFormController") as! AchievementTransactionFormController
        viewController.achievementsDataModel = achievementsDataModel
        viewController.transactionTemplate = template
        
        initiator.show(viewController, sender: self)
    }
    
    public func editTransaction(from initiator: UIViewController, transaction: AchievementTransaction) {
        let viewController = storyboard.instantiateViewController(withIdentifier: "AchievementTransactionFormController") as! AchievementTransactionFormController
        viewController.achievementsDataModel = achievementsDataModel
        viewController.achievementTransaction = transaction
        
        initiator.show(viewController, sender: self)
    }
    
    public func showTransactionDetails(from initiator: UIViewController, transaction achievementTransaction: AchievementTransaction) {
        let viewController = storyboard.instantiateViewController(withIdentifier: "TransactionDetailViewController") as! TransactionDetailViewController
        viewController.transaction = achievementTransaction.historicalTransaction
        
        initiator.show(viewController, sender: self)
    }
    
    public func showTransactionDetails(from initiator: UIViewController, transaction historicalTransaction: HistoricalTransaction) {
        let viewController = storyboard.instantiateViewController(withIdentifier: "TransactionDetailViewController") as! TransactionDetailViewController
        viewController.transaction = historicalTransaction
        
        initiator.show(viewController, sender: self)
    }
}
