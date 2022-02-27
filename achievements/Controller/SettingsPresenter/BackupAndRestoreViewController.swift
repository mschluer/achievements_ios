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
    var spinner : SpinnerViewController?
    
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

        let passwordAlert = UIAlertController(title: NSLocalizedString("Password", comment: "Dialogue Headline asking the user to enter an encryption / decryption Password"), message: NSLocalizedString("Please enter a Password to decrypt your Backup", comment: "Description of the dialogue asking the user to provide a passphrase to decrypt the backup"), preferredStyle: .alert)
        
        passwordAlert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = NSLocalizedString("Password", comment: "Dialogue Headline asking the user to enter an encryption / decryption Password")
        }
        
        passwordAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Abort Action."), style: .cancel, handler: nil))
        
        passwordAlert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: "Confirm that this is the password the user wants to use to encrypt / decrypt the backup."), style: .default, handler:  { [weak passwordAlert] _ in
            guard let password = passwordAlert?.textFields?.first?.text else {
                return
            }
            
            if password.count < 1 {
                self.toggleLoadingState()
                self.showPasswordMustNotBeEmptyAlert()
                return
            } else {
                self.restoreFrom(url: pickedURL, password: password)
            }
        }))
        
        self.present(passwordAlert, animated: true)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
        toggleLoadingState()
    }
    
    // MARK: Action Handlers
    @IBAction func backupDataButtonPressed(_ sender: Any) {
        toggleLoadingState()
        let passwordAlert = UIAlertController(title: NSLocalizedString("Password", comment: "Dialogue Headline asking the user to enter an encryption / decryption Password"), message: NSLocalizedString("Please enter a Password to encrypt your Backup.", comment: "Description of the dialogue asking the user to provide a passphrase to encrypt the backup"), preferredStyle: .alert)
        
        passwordAlert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = NSLocalizedString("Password", comment: "Placeholder for Password input field.")
        }
        
        passwordAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Abort Action."), style: .cancel, handler: { _ in
            self.toggleLoadingState() }))
        
        passwordAlert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: "Confirm that this is the password the user wants to use to encrypt / decrypt the backup."), style: .default, handler:  { [weak passwordAlert] _ in
            guard let password = passwordAlert?.textFields?.first?.text else {
                return
            }
            
            if password.count < 1 {
                self.toggleLoadingState()
                self.showPasswordMustNotBeEmptyAlert()
                return
            } else {
                self.exportDatabaseFileEncryptedWith(password: password)
            }
        }))
        
        self.present(passwordAlert, animated: true)
    }
    
    @IBAction func restoreDataButtonPressed(_ sender: Any) {
        toggleLoadingState()
        let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: [ UTType.data ], asCopy: true)
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true)
    }
    
    // MARK: Public Functions
    public func toggleLoadingState() {
        if let spinnerView = self.spinner {
            spinnerView.vanish()
            self.spinner = nil
        } else {
            let spinnerView = SpinnerViewController()
            spinnerView.showOn(self)
            
            self.spinner = spinnerView
        }
    }
    
    // MARK: Private Functions
    private func exportDatabaseFileEncryptedWith(password: String) {
        guard let backupFile = settingsPresenter.exportDatabaseBackupWith(password: password, initiator: self) else {
            toggleLoadingState()
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [ backupFile ], applicationActivities: nil)
        self.present(activityViewController, animated: true)
        
        toggleLoadingState()
    }
    
    private func restoreFrom(url: URL, password: String) {
        settingsPresenter.restoreFrom(backup: url, password: password, initiator: self)
        toggleLoadingState()
    }
    
    private func showPasswordMustNotBeEmptyAlert() {
        let emptyPasswordAlert = UIAlertController(
            title: NSLocalizedString("Password empty", comment: "Alert Headline for when user tries to encrypt or decrypt a backup with an empty password"),
            message: NSLocalizedString("Achievements Database Backups are encrypted by default, hence the password must not be empty.", comment: "Explanatory text why backup passwords must not be empty."),
            preferredStyle: .alert)
        
        emptyPasswordAlert.addAction(UIAlertAction(
            title: NSLocalizedString("Okay", comment: "Message of Approval"),
            style: .default,
            handler: nil))
        
        self.present(emptyPasswordAlert, animated: true)
    }
}
