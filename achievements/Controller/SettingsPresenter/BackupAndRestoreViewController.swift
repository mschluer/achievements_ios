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
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [ URL ]) {
        // Check, whether Path is valid
        guard let pickedURL = urls.first else {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Headline of an Error Message."), message: NSLocalizedString("Path to Restore Data cannot be determined.", comment: "Error message for when a Backup cannot be created."), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: "Message of approval."), style: .default, handler: nil))
            self.present(alert, animated: true)
            
            return
        }

        do {
            let passwordAlert = UIAlertController(title: NSLocalizedString("Password", comment: "Dialogue Headline asking the user to enter an encryption / decryption Password"), message: NSLocalizedString("Please enter a Password to decrypt your Backup", comment: "Description of the dialogue asking the user to provide a passphrase to decrypt the backup"), preferredStyle: .alert)
            
            passwordAlert.addTextField { (textField) in
                textField.isSecureTextEntry = true
                textField.placeholder = "Password"
            }
            
            passwordAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Abort Action."), style: .cancel, handler: nil))
            
            passwordAlert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: "Confirm that this is the password the user wants to use to encrypt / decrypt the backup."), style: .default, handler:  { [weak passwordAlert] _ in
                guard let password = passwordAlert?.textFields?.first?.text else {
                    return
                }
                self.replaceDatabaseWith(url: pickedURL, password: password)
            }))
            
            self.present(passwordAlert, animated: true)
        } catch let error {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Headline of an Error Message."), message: NSLocalizedString("Saving Backup Data failed.", comment: "Error message for when Backup Data cannot be saved to disk."), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: "Message of approval."), style: .default, handler: nil))
            self.present(alert, animated: true)
            
            print("Data backup cannot be saved due to error: \(error)")
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Action Handlers
    @IBAction func backupDataButtonPressed(_ sender: Any) {
        let passwordAlert = UIAlertController(title: NSLocalizedString("Password", comment: "Dialogue Headline asking the user to enter an encryption / decryption Password"), message: NSLocalizedString("Please enter a key to encrypt your Backup", comment: "Description of the dialogue asking the user to provide a passphrase to encrypt the backup"), preferredStyle: .alert)
        
        passwordAlert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = NSLocalizedString("Password", comment: "Placeholder for Password input field.")
        }
        
        passwordAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Abort Action."), style: .cancel, handler: nil))
        
        passwordAlert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: "Confirm that this is the password the user wants to use to encrypt /decrypt the backup."), style: .default, handler:  { [weak passwordAlert] _ in
            guard let password = passwordAlert?.textFields?.first?.text else {
                return
            }
            self.exportDatabaseFileEncryptedWith(password: password)
        }))
        
        self.present(passwordAlert, animated: true)
    }
    
    @IBAction func restoreDataButtonPressed(_ sender: Any) {
        print("Implementation Pending.")
        
        let documentPickerController = UIDocumentPickerViewController(documentTypes: [ "public.data" ], in: .import )
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true)
    }
    
    // MARK: Private Functions
    private func exportDatabaseFileEncryptedWith(password: String) {
        settingsPresenter.exportDatabaseBackupWith(password: password, initiator: self)
    }
    
    private func replaceDatabaseWith(url: URL, password: String) {
        settingsPresenter.replaceDatabaseWith(url: url, password: password, initiator: self)
    }
}
