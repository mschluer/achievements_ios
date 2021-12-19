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
    var databaseMenuItems = [
        NSLocalizedString("Backup / Restore", comment: "Menu Item for the Backup and Restore View."),           // 0
        NSLocalizedString("Reset Settings", comment: "Reset Settings to Default State."),                       // 1
        NSLocalizedString("Reset Application", comment: "Action to set all data back to standard values.")      // 2
    ]
    
    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell
        
        switch(indexPath.section) {
        case 0:
            switch(indexPath.item) {
            default:
                // Amount Records in Balance Line Chart
                cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellWithData", for: indexPath)
                cell.textLabel?.text = NSLocalizedString("Amount Records in Balance-Chart", comment: "Settings Item for the Amount of Records to be Displayed in the Balance-Line-Chart")
                cell.detailTextLabel?.text = NumberHelper.formattedString(for: Settings.statisticsSettings.lineChartMaxAmountRecords)
            }
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
            cell.textLabel?.text = databaseMenuItems[indexPath.item]
            return cell
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.section) {
        case 0 :    switch(indexPath.item) {
                    // Amount of Datapoints to display
                    default: statisticsAmountDataPointsPressed(); self.tableView.deselectRow(at: indexPath, animated: true)
        }
        default :   switch(indexPath.item) {
                    // Backup and Restore
                    case 0: settingsPresenter.showBackupAndRestoreScreen(from: self)
                    // Reset Settings
                    case 1: resetSettingsPressed(); self.tableView.deselectRow(at: indexPath, animated: true)
                    // Reset Application
                    default: resetApplicationPressed(); self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0: return 1
        default: return databaseMenuItems.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 0 :    return NSLocalizedString("Statistics", comment: "Settings Menu Header for Settings Regarding Statistics")
        default :   return NSLocalizedString("Data", comment: "Settings Menu Header for Settings Regarding the Stored Data")
        }
    }
    
    // MARK: Action Handlers
    private func resetApplicationPressed() {
        let deletionAlert = UIAlertController(title: NSLocalizedString("Sure?", comment: "Ask approval from the user"), message: NSLocalizedString("This will reset / clear all data and cannot be undone!", comment: "Make entirely clear that this will reset the entire Application"), preferredStyle: .actionSheet)
        deletionAlert.addAction(UIAlertAction(title: NSLocalizedString("Reset Application", comment: "Action to set all data back to standard values."), style: .destructive, handler: { _ in
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
    
    private func statisticsAmountDataPointsPressed() {
        let updateIntValueAlert = UIAlertController(
            title: NSLocalizedString("Amount Records in Balance-Chart", comment: "Settings Item for the Amount of Records to be Displayed in the Balance-Line-Chart"),
            message: NSLocalizedString("Please enter a new (numeric) value.", comment: "As for a new nummeric Value"),
            preferredStyle: .alert)
        
        updateIntValueAlert.addTextField { textField in
            textField.text = String(Settings.statisticsSettings.lineChartMaxAmountRecords)
        }
        
        updateIntValueAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Abort current action."), style: .cancel, handler: nil))
        updateIntValueAlert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: "Confirm Action"), style: .default, handler: { [weak updateIntValueAlert] _ in
            guard let text = updateIntValueAlert?.textFields?.first?.text else {
                return
            }
            
            let intValue = (text as NSString).integerValue
            
            if intValue < 5 {
                Settings.statisticsSettings.lineChartMaxAmountRecords = 5
            } else if intValue > 1000 {
                Settings.statisticsSettings.lineChartMaxAmountRecords = 1000
            } else {
                Settings.statisticsSettings.lineChartMaxAmountRecords = intValue
            }
            
            self.updateViewFromModel()
        }))
        
        self.present(updateIntValueAlert, animated: true, completion: nil)
    }
    
    // Private Functions
    private func updateViewFromModel() {
        self.tableView.reloadData()
    }
}
