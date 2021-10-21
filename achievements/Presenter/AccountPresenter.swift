//
//  AccountPresenter.swift
//  achievements
//
//  Created by Maximilian Schluer on 14.10.21.
//

import Foundation
import UIKit

class AccountPresenter {
    // MARK: Persistence Models
    let achievementsDataModel : AchievementsDataModel
    
    private let storyboard = UIStoryboard(name: "AccountPresenterStoryboard", bundle: nil)
    
    // MARK: Initializers
    init(accountIdentifier: String) {
        self.achievementsDataModel = AchievementsDataModel()
    }
    
    // MARK: Public Functions
    public func showAccountDashboard(from initiator: UIViewController) {
        let viewController = storyboard.instantiateViewController(withIdentifier: "DashboardController") as! DashboardController
        viewController.achievementsDataModel = achievementsDataModel
        
        initiator.show(viewController, sender: self)
    }
}
