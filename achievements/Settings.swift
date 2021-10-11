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
    
    // MARK: Properties
    static var applicationSettings = ApplicationSettings() {
        didSet {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            
            do {
                let data = try encoder.encode(applicationSettings)
                try data.write(to: plistURL)
            } catch {
                print(error)
            }
        }
    }
    
    static func loadAndSetSettings() {
        guard let data = try? Data.init(contentsOf: plistURL)
        else { return }
        
        let decoder = PropertyListDecoder()
        let loadedApplicationSettings = try? decoder.decode(ApplicationSettings.self, from: data)
        
        self.applicationSettings = loadedApplicationSettings ?? ApplicationSettings()
    }
}

// MARK: Data Structs with Defaults
struct ApplicationSettings : Codable {
    var automaticPurge: Bool = true
}
