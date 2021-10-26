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
    
    // MARK: Public Functions
    public func takeOver(from initiator : UIViewController) {
        let viewController = storyboard.instantiateViewController(withIdentifier: "StatisticsTableViewController") as! StatisticsTableViewController
        viewController.achievementsDataModel = achievementsDataModel
        
        initiator.show(viewController, sender: self)
    }
}
