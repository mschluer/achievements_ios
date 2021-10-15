//
//  SettingsListTableViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 15.10.21.
//

import UIKit

class SettingsListTableViewController: UITableViewController {
    // MARK: Persistence Models
    public var achievementsDataModel : AchievementsDataModel!
    
    // MARK: Variables
    var settingsPresenter : SettingsPresenter!
    var menuItems = [
        NSLocalizedString("Backup / Restore", comment: "Menu Item for the Backup and Restore View."), // 0
        NSLocalizedString("Reset Settings", comment: "Reset Settings to Default State."),             // 1
        NSLocalizedString("Reset App", comment: "Action to set all data back to standard values.")    // 2
    ]
    
    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        cell.textLabel?.text = menuItems[indexPath.item]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.item) {
        case 0: settingsPresenter.showBackupAndRestoreScreen(from: self)
        case 1: resetSettingsPressed(); self.tableView.deselectRow(at: indexPath, animated: true)
        default: resetApplicationPressed(); self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        default: return NSLocalizedString("Data", comment: "Settings Menu Header for Settings Regarding the Stored Data")
        }
    }
    
    // MARK: Action Handlers
    private func resetApplicationPressed() {
        let deletionAlert = UIAlertController(title: NSLocalizedString("Sure?", comment: "Ask approval from the user"), message: NSLocalizedString("This will reset / clear all data and cannot be undone!", comment: "Make entirely clear that this will reset the entire Application"), preferredStyle: .actionSheet)
        deletionAlert.addAction(UIAlertAction(title: NSLocalizedString("Reset App", comment: "Action to set all data back to standard values."), style: .destructive, handler: { _ in
            self.settingsPresenter.resetApplication()
        }))
        deletionAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Abort current action."), style: .cancel, handler: nil))
        
        self.present(deletionAlert, animated: true)
    }
    
    private func resetSettingsPressed() {
        let deletionAlert = UIAlertController(title: NSLocalizedString("Sure?", comment: "Ask approval from the user"), message: NSLocalizedString("This will reset / clear your settings and cannot be undone!", comment: "Make entirely clear that this will reset the Settings"), preferredStyle: .actionSheet)
        deletionAlert.addAction(UIAlertAction(title: NSLocalizedString("Reset Settings", comment: "Action to set all Settings back to standard values."), style: .destructive, handler: { _ in
            self.settingsPresenter.resetSettings()
        }))
        deletionAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Abort current action."), style: .cancel, handler: nil))
        
        self.present(deletionAlert, animated: true)
    }
}
