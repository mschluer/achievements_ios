//
//  BackupAndRestoreViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 15.10.21.
//

import CryptoSwift
import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class BackupAndRestoreViewController: UIViewController, UIDocumentPickerDelegate {
    // MARK: Variables
    var settingsPresenter : SettingsPresenter!
    var encryptedDatabaseFile : Data?
    
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
        
        // Check, whether there's a file to save
        guard let encryptedDatabaseFile = encryptedDatabaseFile else {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Headline of an Error Message."), message: NSLocalizedString("Backup Data cannot be encrypted.", comment: "Error message for when a Backup cannot be created due to crypto-failure."), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: "Message of approval."), style: .default, handler: nil))
            self.present(alert, animated: true)
            
            return
        }

        do {
            let fileManager = FileManager()
            print(pickedURL)
            
            fileManager.isWritableFile(atPath: pickedURL.description)
        } catch let error {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Headline of an Error Message."), message: NSLocalizedString("Saving Backup Data failed.", comment: "Error message for when Backup Data cannot be saved to disk."), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: "Message of approval."), style: .default, handler: nil))
            self.present(alert, animated: true)
            
            print("Data backup cannot be saved due to error: \(error)")
        }
        
        /*
        
        do {
        try FileManager().copyItem(at: pickedURL, to: targetURL)
        } catch let error {
            print ("Restoring failed due to error: \(error.localizedDescription)")
        } */
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Action Handlers
    @IBAction func backupDataButtonPressed(_ sender: Any) {
        let passwordAlert = UIAlertController(title: NSLocalizedString("Key", comment: "Dialogue Headline asking the user to enter an encryption / decryption key for the Backup-Passphrase"), message: NSLocalizedString("Please enter a key to encrypt your Backup", comment: "Description of the dialogue asking the user to provide a passphrase to encrypt the backup"), preferredStyle: .alert)
        
        passwordAlert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
        }
        
        passwordAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Abort Action."), style: .cancel, handler: nil))
        
        passwordAlert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: "Confirm that this is the password the user wants to use to encrypt the backup."), style: .default, handler:  { [weak passwordAlert] _ in
            guard let password = passwordAlert?.textFields?.first?.text else {
                return
            }
            self.exportDatabaseFileEncryptedWith(password: password)
        }))
        
        self.present(passwordAlert, animated: true)
    }
    
    @IBAction func restoreDataButtonPressed(_ sender: Any) {
        print("Implementation Pending.")
    }
    
    // MARK: Private Functions
    private func exportDatabaseFileEncryptedWith(password: String) {
        do {
            // Encrypt Data
            let iv = AES.randomIV(AES.blockSize)
            let key = try PKCS5.PBKDF2(
                password: Array(password.utf8),
                salt: Array("nacllcan".utf8),
                iterations: 4096,
                keyLength: 32,
                variant: .sha2(.sha512)
            ).calculate()
            
            let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)
            
            let ciphertext = try aes.encrypt(Array(settingsPresenter.exportAchievementsDataModelFile()))
            self.encryptedDatabaseFile = Data(ciphertext)
            
            // Save temporarily
            let temporaryLocation = ("\(NSTemporaryDirectory())backup.adbackup")
            try ciphertext.description.write(toFile: temporaryLocation, atomically: true, encoding: String.Encoding.utf8)
            
            // Ask for location to store
            let activityViewController = UIActivityViewController(activityItems: [ NSURL(fileURLWithPath: temporaryLocation) ], applicationActivities: nil)
            self.present(activityViewController, animated: true)
        } catch let error {
            print("Encryption not possible due to error: \(error)")
        }
    }
}
