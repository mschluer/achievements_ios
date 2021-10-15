//
//  BackupAndRestoreViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 15.10.21.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class BackupAndRestoreViewController: UIViewController, UIDocumentPickerDelegate {
    // MARK: Variables
    var settingsPresenter : SettingsPresenter!
    
    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Document Picker Delegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let pickedURL = urls.first else {
            return
        }
        
        guard let targetURL = settingsPresenter.exportAchievementsDataModelFile() else {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Headline of an Error Message."), message: NSLocalizedString("Path to Restore Data cannot be determined.", comment: "Error message for when a Backup cannot be created."), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: "Message of approval."), style: .default, handler: nil))
            self.present(alert, animated: true)
            
            return
        }
        
        do {
        try FileManager().copyItem(at: pickedURL, to: targetURL)
        } catch let error {
            print ("Restoring failed due to error: \(error.localizedDescription)")
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Action Handlers
    @IBAction func backupDataButtonPressed(_ sender: Any) {
        guard let url = settingsPresenter.exportAchievementsDataModelFile() else {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Headline of an Error Message."), message: NSLocalizedString("Backup cannot be created.", comment: "Error message for when a Backup cannot be created."), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: "Message of approval."), style: .default, handler: nil))
            self.present(alert, animated: true)
            
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [ url ], applicationActivities: nil)
        self.present(activityViewController, animated: true)
    }
    
    @IBAction func restoreDataButtonPressed(_ sender: Any) {
        print("Implementation Pending.")
    }
}
