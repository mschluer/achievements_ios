//
//  TransactionTemplatesPresenter.swift
//  achievements
//
//  Created by Maximilian Schluer on 12.10.21.
//

import Foundation
import UIKit

class TransactionTemplatesPresenter {
    // MARK: Persistence Models
    let achievementsDataModel : AchievementsDataModel
    
    private let storyboard = UIStoryboard(name: "TransactionTemplatesPresenterStoryboard", bundle: nil)
    
    // MARK: Initializers
    init(achievementsDataModel : AchievementsDataModel) {
        self.achievementsDataModel = achievementsDataModel
    }
    
    // MARK: Public Functions
    public func showPlannedExpenses(from initiator : UIViewController) {
        let viewController = storyboard.instantiateViewController(withIdentifier: "TransactionTemplatesListViewController") as! TransactionTemplatesListViewController
        viewController.achievementsDataModel = achievementsDataModel
        viewController.displayMode = .expenses
        
        initiator.show(viewController, sender: self)
    }
    
    public func showPlannedIncomes(from initiator : UIViewController) {
        let viewController = storyboard.instantiateViewController(withIdentifier: "TransactionTemplatesListViewController") as! TransactionTemplatesListViewController
        viewController.achievementsDataModel = achievementsDataModel
        viewController.displayMode = .incomes
        
        initiator.show(viewController, sender: self)
    }
}
