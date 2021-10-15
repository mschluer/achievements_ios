//
//  SettingsPresenter.swift
//  achievements
//
//  Created by Maximilian Schluer on 15.10.21.
//

import Foundation
import UIKit

class SettingsPresenter {
    // MARK: Persistence Models
    private var achievementsDataModel : AchievementsDataModel
    
    // MARK: Variables
    private let storyboard = UIStoryboard(name: "SettingsPresenterStoryboard", bundle: nil)
    
    // MARK: Initializers
    init(achievementsDataModel : AchievementsDataModel) {
        self.achievementsDataModel = achievementsDataModel
    }
    
    
    // MARK: Presenting Functions
    public func showBackupAndRestoreScreen(from initiator: UIViewController) {
        let viewController = storyboard.instantiateViewController(withIdentifier: "BackupAndRestoreViewController") as! BackupAndRestoreViewController
        viewController.settingsPresenter = self
        
        initiator.show(viewController, sender: self)
    }
    
    public func showSettingsList(from initiator: UIViewController) {
        let viewController = storyboard.instantiateViewController(withIdentifier: "SettingsListTableViewController") as! SettingsListTableViewController
        viewController.settingsPresenter = self
        
        initiator.show(viewController, sender: self)
    }
    
    // MARK: Public Functions
    public func exportAchievementsDataModelFile() -> URL? {
        // TODO: Encrypt
        
        return achievementsDataModel.url()
    }
    
    public func importAchivementsDataModelFile() -> Bool {
        // TODO: Decrypt
        return false
    }
    
    // MARK: Destructive Actions
    public func resetApplication() {
        self.achievementsDataModel.clear()
        Settings.resetApplicationSettings()
    }
    
    public func resetSettings() {
        Settings.resetApplicationSettings()
    }
}
