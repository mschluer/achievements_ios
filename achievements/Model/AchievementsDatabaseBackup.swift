//
//  AchievementsDatabaseBackup.swift
//  achievements
//
//  Created by Maximilian Schluer on 27.02.22.
//

import Foundation
import CoreData
import UIKit

struct AchievementsDatabaseBackup : Codable {
    var achievementsDatabaseBackupVersion = "1.0.0"
    var accounts : [Account]
}
