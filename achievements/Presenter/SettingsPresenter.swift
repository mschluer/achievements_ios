//
//  SettingsPresenter.swift
//  achievements
//
//  Created by Maximilian Schluer on 15.10.21.
//

import CryptoSwift
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
    public func exportDatabaseBackupWith(password: String, initiator: UIViewController) -> NSURL? {
        let unencryptedBackupFilePath = "\(NSTemporaryDirectory())backup.sqlite"
        
        do {
            // Create Backup File
            achievementsDataModel.duplicateDatabase(to: unencryptedBackupFilePath)
            
            // Encrypt Data
            let iv = "achievementsdmiv".bytes
            let key = try PKCS5.PBKDF2(
                password: Array(password.utf8),
                salt: Array("saltsalt".utf8),
                iterations: 4096,
                keyLength: 32,
                variant: .sha2(.sha512)
            ).calculate()
            
            let plaintext = try Data(contentsOf: URL(string: "file://\(unencryptedBackupFilePath)")!)
            let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)
            let ciphertext = try aes.encrypt(Array(plaintext))
            
            // Save temporarily
            let temporaryLocation = ("\(NSTemporaryDirectory())backup.adbackup")
            let pointer = UnsafeBufferPointer(start: ciphertext, count: ciphertext.count)
            try Data(buffer: pointer).write(to: URL(string: "file://\(temporaryLocation)")!)
            
            // Remove Unencrypted File
            try FileManager.default.removeItem(atPath: unencryptedBackupFilePath)
            
            // Ask for Location to Store
            return NSURL(fileURLWithPath: temporaryLocation)
        } catch let error {
            print("Export failed due to error: \(error.localizedDescription)")
            
            // Make sure that there is no unencrypted backup file left in case of a crash
            if FileManager().fileExists(atPath: unencryptedBackupFilePath) {
                try! FileManager.default.removeItem(atPath: unencryptedBackupFilePath)
            }
            
            // Notify User that creating the Backup failed
            let failAlert = UIAlertController(title: NSLocalizedString("Error", comment: "Headline of an Error Message."), message: NSLocalizedString("Creating backup failed.", comment: "Error message to notify that creating a Backup failed."), preferredStyle: .alert)
            failAlert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: "Message of approval."), style: .default, handler: nil))
            initiator.present(failAlert, animated: true)
            
            return nil
        }
    }
    
    public func replaceDatabaseWith(url: URL, password: String, initiator: UIViewController) {
        let unencryptedBackupFilePath = "\(NSTemporaryDirectory())restore.sqlite"
        
        do {
            // Decrypt
            let iv = "achievementsdmiv".bytes
            let key = try PKCS5.PBKDF2(
                password: Array(password.utf8),
                salt: Array("saltsalt".utf8),
                iterations: 4096,
                keyLength: 32,
                variant: .sha2(.sha512)
            ).calculate()
            
            let ciphertext = try Data(contentsOf: url)

            let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)
            let plaintext = Data(try aes.decrypt(ciphertext.bytes))
            
            // Save Temporarily
            try plaintext.write(to: URL(string: "file://\(unencryptedBackupFilePath)")!)

            // Restore in Model
            achievementsDataModel.replaceDatabase(from: unencryptedBackupFilePath)
            
            // Delete unencrypted File
            try! FileManager.default.removeItem(atPath: unencryptedBackupFilePath)
            
            // Show Success Message
            let successAlert = UIAlertController(title: NSLocalizedString("Success", comment: "Headline to tell the user that restoring to a backup was completed."), message: NSLocalizedString("Successfully restored from Backup.", comment: "Success Message for when user successfully restored to a backup."), preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: "Message of approval."), style: .default, handler: nil))
            initiator.present(successAlert, animated: true)
        } catch let error {
            print("Import failed due to error: \(error.localizedDescription)")
            
            // Make sure that there is no unencrypted backup file left in case of a crash
            if FileManager().fileExists(atPath: unencryptedBackupFilePath) {
                try! FileManager.default.removeItem(atPath: unencryptedBackupFilePath)
            }
            
            // Notify User that creating the Backup failed
            let failAlert = UIAlertController(title: NSLocalizedString("Error", comment: "Headline of an Error Message."), message: NSLocalizedString("Restoring to backup failed.", comment: "Error message for restoring to a Backup failed."), preferredStyle: .alert)
            failAlert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: "Message of approval."), style: .default, handler: nil))
            initiator.present(failAlert, animated: true)
        }
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
