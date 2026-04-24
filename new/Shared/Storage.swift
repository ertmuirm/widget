import Foundation
import WidgetKit

/// Manages storage for widget configuration using App Groups
/// Also handles iCloud and Files backup/restore
final class Storage {
    
    static let shared = Storage()
    
    private let appGroupIdentifier = "group.com.iosmirror"
    private let fileManager = FileManager.default
    
    private init() {}
    
    // MARK: - App Group Storage (Shared with Widget Extension)
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }
    
    /// Save widget configuration to App Group
    func saveConfiguration(_ config: AppConfig) {
        guard let userDefaults = userDefaults else {
            print("Storage: Failed to access App Group UserDefaults")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(config)
            userDefaults.set(data, forKey: StorageKeys.widgetConfiguration)
            userDefaults.synchronize()
            
            // Notify widget to reload
            WidgetCenter.shared.reloadAllTimelines()
            
            print("Storage: Configuration saved successfully")
        } catch {
            print("Storage: Failed to encode configuration: \(error)")
        }
    }
    
    /// Load widget configuration from App Group
    func loadConfiguration() -> AppConfig? {
        guard let userDefaults = userDefaults,
              let data = userDefaults.data(forKey: StorageKeys.widgetConfiguration) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(AppConfig.self, from: data)
        } catch {
            print("Storage: Failed to decode configuration: \(error)")
            return nil
        }
    }
    
    // MARK: - User Preferences
    
    func savePreferences(_ prefs: UserPreferences) {
        guard let userDefaults = userDefaults else { return }
        
        do {
            let data = try JSONEncoder().encode(prefs)
            userDefaults.set(data, forKey: StorageKeys.userPreferences)
        } catch {
            print("Storage: Failed to save preferences: \(error)")
        }
    }
    
    func loadPreferences() -> UserPreferences {
        guard let userDefaults = userDefaults,
              let data = userDefaults.data(forKey: StorageKeys.userPreferences) else {
            return UserPreferences()
        }
        
        return (try? JSONDecoder().decode(UserPreferences.self, from: data)) ?? UserPreferences()
    }
    
    // MARK: - iCloud Backup
    
    private var iCloudContainerURL: URL? {
        fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }
    
    /// Save backup to iCloud
    func backupToiCloud(_ config: AppConfig) throws -> URL {
        guard let containerURL = iCloudContainerURL else {
            throw StorageError.iCloudNotAvailable
        }
        
        // Create backup directory if needed
        try fileManager.createDirectory(at: containerURL, withIntermediateDirectories: true)
        
        let backup = WidgetBackup.create(from: config)
        let fileName = "widget_backup_\(dateFormatter.string(from: Date())).json"
        let fileURL = containerURL.appendingPathComponent(fileName)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(backup)
        try data.write(to: fileURL)
        
        print("Storage: Backup saved to iCloud: \(fileURL.path)")
        return fileURL
    }
    
    /// List backups in iCloud
    func listBackups() -> [URL] {
        guard let containerURL = iCloudContainerURL else { return [] }
        
        do {
            let contents = try fileManager.contentsOfDirectory(
                at: containerURL,
                includingPropertiesForKeys: [.creationDateKey],
                options: [.skipsHiddenFiles]
            )
            return contents
                .filter { $0.pathExtension == "json" && $0.lastPathComponent.hasPrefix("widget_backup_") }
                .sorted { url1, url2 in
                    let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                    let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                    return date1 > date2
                }
        } catch {
            print("Storage: Failed to list iCloud backups: \(error)")
            return []
        }
    }
    
    /// Restore from iCloud backup
    func restoreFromiCloud(at url: URL) throws -> AppConfig {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let backup = try decoder.decode(WidgetBackup.self, from: data)
        
        guard backup.version == AppConfig.currentVersion else {
            throw StorageError.incompatibleVersion
        }
        
        var config = AppConfig()
        config.widgets = backup.widgets
        config.lastModified = Date()
        
        saveConfiguration(config)
        return config
    }
    
    // MARK: - Files App Backup
    
    /// Save backup to Files app (user-selected location via document picker)
    func saveToFiles(_ config: AppConfig, to url: URL) throws {
        let backup = WidgetBackup.create(from: config)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(backup)
        try data.write(to: url)
        
        print("Storage: Backup saved to Files: \(url.path)")
    }
    
    /// Load from Files backup
    func loadFromFiles(at url: URL) throws -> AppConfig {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let backup = try decoder.decode(WidgetBackup.self, from: data)
        
        guard backup.version == AppConfig.currentVersion else {
            throw StorageError.incompatibleVersion
        }
        
        var config = AppConfig()
        config.widgets = backup.widgets
        config.lastModified = Date()
        
        return config
    }
    
    // MARK: - Export/Import Helpers
    
    /// Generate backup JSON string for sharing
    func exportToJSON(_ config: AppConfig) throws -> String {
        let backup = WidgetBackup.create(from: config)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let data = try encoder.encode(backup)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    /// Import from JSON string
    func importFromJSON(_ json: String) throws -> AppConfig {
        guard let data = json.data(using: .utf8) else {
            throw StorageError.invalidData
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let backup = try decoder.decode(WidgetBackup.self, from: data)
        
        guard backup.version == AppConfig.currentVersion else {
            throw StorageError.incompatibleVersion
        }
        
        var config = AppConfig()
        config.widgets = backup.widgets
        config.lastModified = Date()
        
        return config
    }
    
    // MARK: - Date Formatter
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return formatter
    }
}

// MARK: - Storage Errors

enum StorageError: LocalizedError {
    case iCloudNotAvailable
    case incompatibleVersion
    case invalidData
    case fileNotFound
    
    var errorDescription: String? {
        switch self {
        case .iCloudNotAvailable:
            return "iCloud is not available. Please sign in to iCloud in Settings."
        case .incompatibleVersion:
            return "This backup was created with a different version of the app."
        case .invalidData:
            return "The backup file is corrupted or invalid."
        case .fileNotFound:
            return "The backup file could not be found."
        }
    }
}