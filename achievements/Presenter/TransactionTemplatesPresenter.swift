//
//  TransactionTemplatesPresenter.swift
//  achievements
//
//  Created by Maximilian Schluer on 12.10.21.
//

import Foundation
import UIKit

/*
 
 TODO: Remove the additional form for Achievement Transactions from the Storyboard as soon as the corresponding Presenter is implemented.
 
 */

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
        let viewController = storyboard.instantiateViewController(withIdentifier: "PlannedExpensesViewController") as! PlannedExpensesViewController
        viewController.achievementsDataModel = achievementsDataModel
        
        initiator.show(viewController, sender: self)
    }
    
    public func showPlannedIncomes(from initiator : UIViewController) {
        let viewController = storyboard.instantiateViewController(withIdentifier: "PlannedIncomesViewController") as! PlannedIncomesViewController
        viewController.achievementsDataModel = achievementsDataModel
        
        initiator.show(viewController, sender: self)
    }
}
