//
//  Settings.swift
//  achievements
//
//  Created by Maximilian Schluer on 11.10.21.
//

import Foundation

public class Settings {
    // MARK: Variables
    static private var plistURL : URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("settings.plist")
    }
    
    private static var settingsObject = SettingsObject() {
        didSet {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            
            do {
                let data = try encoder.encode(settingsObject)
                try data.write(to: plistURL)
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: Properties
    static var applicationSettings : ApplicationSettings {
        get {
            self.settingsObject.applicationSettings
        }
        set(new) {
            self.settingsObject.applicationSettings = new
        }
    }
    static var statisticsSettings : StatisticsSettings {
        get {
            self.settingsObject.statisticsSettings
        }
        set(new) {
            self.settingsObject.statisticsSettings = new
        }
    }
    
    // MARK: Public Functions
    public static func loadAndSetSettings() {
        guard let data = try? Data.init(contentsOf: plistURL)
        else { return }
        
        let decoder = PropertyListDecoder()
        self.settingsObject = (try? decoder.decode(SettingsObject.self, from: data)) ?? SettingsObject()
    }
    
    // MARK: Destructive Actions
    public static func resetApplicationSettings() {
        self.settingsObject = SettingsObject()
    }
}

// MARK: Data Structs with Defaults
struct ApplicationSettings : Codable {
    var automaticPurge : Bool = false
    var divideIncomeTemplatesByRecurrence : Bool = true
    var divideExpenseTemplatesByRecurrence : Bool = true
}

struct SettingsObject : Codable {
    var applicationSettings : ApplicationSettings = ApplicationSettings()
    var statisticsSettings : StatisticsSettings = StatisticsSettings()
}

struct StatisticsSettings : Codable {
    var lineChartMaxAmountRecords : Int = 100
}
