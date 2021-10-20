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
    public func exportDatabaseBackupWith(password: String, initiator: UIViewController) {
        let unencryptedBackupFilePath = "\(NSTemporaryDirectory())backup.sqlite"
        
        do {
            // Create Backup File
            achievementsDataModel.duplicateDatabase(to: unencryptedBackupFilePath)
            
            // Encrypt Data
            let iv = "drowssapdrowssap".bytes
            let key = try PKCS5.PBKDF2(
                password: Array(password.utf8),
                salt: Array("nacllcan".utf8),
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
            // TODO: Reactivate
            print(temporaryLocation)
            // try FileManager.default.removeItem(atPath: unencryptedBackupFilePath)
            
            // Ask for Location to Store
            let activityViewController = UIActivityViewController(activityItems: [ NSURL(fileURLWithPath: temporaryLocation) ], applicationActivities: nil)
            initiator.present(activityViewController, animated: true)
        } catch let error {
            print("Export failed due to error: \(error.localizedDescription)")
            
            // Make sure that there is no unencrypted backup file left in case of a crash
            if FileManager().fileExists(atPath: unencryptedBackupFilePath) {
                try! FileManager.default.removeItem(atPath: unencryptedBackupFilePath)
            }
            
            // TODO: Show Alert telling the User that something went wrong
        }
    }
    
    public func replaceDatabaseWith(url: URL, password: String, initiator: UIViewController) {
        let unencryptedBackupFilePath = "\(NSTemporaryDirectory())restore.sqlite"
        
        do {
            // Decrypt
            let iv = "drowssapdrowssap".bytes
            let key = try PKCS5.PBKDF2(
                password: Array(password.utf8),
                salt: Array("nacllcan".utf8),
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
            // TODO: Reactivate!
            // try! FileManager.default.removeItem(atPath: unencryptedBackupFilePath)
        } catch let error {
            print("Import failed due to error: \(error.localizedDescription)")
            
            // Make sure that there is no unencrypted backup file left in case of a crash
            if FileManager().fileExists(atPath: unencryptedBackupFilePath) {
                try! FileManager.default.removeItem(atPath: unencryptedBackupFilePath)
            }
            
            // TODO: Show Alert telling the User that something went wrong
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
