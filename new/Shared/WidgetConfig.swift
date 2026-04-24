import Foundation

// MARK: - Widget Configuration Models

/// Represents the overall configuration for all widgets
struct WidgetConfiguration: Codable, Identifiable {
    var id: UUID = UUID()
    var widgets: [WidgetItem] = []
    var lastModified: Date = Date()
    
    static let currentVersion = 1
    var version: Int { Self.currentVersion }
}

/// Individual widget item
struct WidgetItem: Codable, Identifiable {
    var id: UUID = UUID()
    var family: WidgetFamily
    var iconGrid: IconGrid
    var createdAt: Date = Date()
    var modifiedAt: Date = Date()
}

/// Widget families supported by the app
enum WidgetFamily: String, Codable, CaseIterable {
    // Home Screen Widgets
    case homeSmall = "homeSmall"          // 1x1 (1 icon)
    case homeMedium = "homeMedium"        // 3x3 (9 icons)
    case homeLarge = "homeLarge"           // 6x3 (18 icons)
    case homeExtraLarge = "homeExtraLarge" // 6x6 (36 icons)
    
    // Lock Screen Widgets
    case lockCircular = "lockCircular"     // Circular accessory
    case lockRectangular = "lockRectangular" // Up to 6 items
    case lockInline = "lockInline"        // Single line text
    
    var displayName: String {
        switch self {
        case .homeSmall: return "Small (1×1)"
        case .homeMedium: return "Medium (3×3)"
        case .homeLarge: return "Large (6×3)"
        case .homeExtraLarge: return "Extra Large (6×6)"
        case .lockCircular: return "Circular"
        case .lockRectangular: return "Rectangular"
        case .lockInline: return "Inline"
        }
    }
    
    var isHomeScreen: Bool {
        switch self {
        case .homeSmall, .homeMedium, .homeLarge, .homeExtraLarge:
            return true
        case .lockCircular, .lockRectangular, .lockInline:
            return false
        }
    }
    
    var maxIcons: Int {
        switch self {
        case .homeSmall: return 1
        case .homeMedium: return 9
        case .homeLarge: return 18
        case .homeExtraLarge: return 36
        case .lockCircular: return 1
        case .lockRectangular: return 6
        case .lockInline: return 1
        }
    }
    
    var gridColumns: Int {
        switch self {
        case .homeSmall: return 1
        case .homeMedium: return 3
        case .homeLarge, .homeExtraLarge: return 6
        case .lockCircular, .lockInline: return 1
        case .lockRectangular: return 1
        }
    }
    
    var gridRows: Int {
        switch self {
        case .homeSmall, .homeMedium, .homeLarge, .homeExtraLarge:
            return self == .homeLarge ? 3 : (self == .homeExtraLarge ? 6 : (self == .homeMedium ? 3 : 1))
        case .lockCircular, .lockRectangular, .lockInline: return 1
        }
    }
}

/// Grid layout for icons in a widget
struct IconGrid: Codable {
    var columns: Int
    var rows: Int
    var icons: [IconItem]
    
    init(columns: Int, rows: Int, icons: [IconItem] = []) {
        self.columns = columns
        self.rows = rows
        self.icons = icons
    }
}

/// Individual icon item in the grid
struct IconItem: Codable, Identifiable {
    var id: UUID = UUID()
    var gridPosition: GridPosition
    var displayType: IconDisplayType
    var iconName: String?
    var customText: String?
    var fontSize: Int
    var backgroundColor: String // Hex color
    var opacity: Double        // 0.0 - 1.0
    var action: IconAction
    
    init(position: GridPosition,
         displayType: IconDisplayType = .icon,
         iconName: String? = nil,
         customText: String? = nil,
         fontSize: Int = 14,
         backgroundColor: String = "#000000",
         opacity: Double = 0.5,
         action: IconAction = IconAction(type: .urlScheme, value: "")) {
        self.gridPosition = position
        self.displayType = displayType
        self.iconName = iconName
        self.customText = customText
        self.fontSize = fontSize
        self.backgroundColor = backgroundColor
        self.opacity = opacity
        self.action = action
    }
}

/// Grid position for an icon
struct GridPosition: Codable, Equatable {
    var col: Int
    var row: Int
}

/// How an icon is displayed
enum IconDisplayType: String, Codable, CaseIterable {
    case icon
    case text
}

/// Action triggered when icon is tapped
struct IconAction: Codable, Identifiable {
    var id: UUID = UUID()
    var type: ActionType
    var value: String
    var appBundleId: String?
    var intentName: String?
    
    init(type: ActionType, value: String, appBundleId: String? = nil, intentName: String? = nil) {
        self.type = type
        self.value = value
        self.appBundleId = appBundleId
        self.intentName = intentName
    }
}

/// Types of actions an icon can perform
enum ActionType: String, Codable, CaseIterable {
    case appIntent = "appIntent"
    case urlScheme = "urlScheme"
    case shortcut = "shortcut"
    
    var displayName: String {
        switch self {
        case .appIntent: return "App Intent (Zero Flash)"
        case .urlScheme: return "URL Scheme"
        case .shortcut: return "Shortcuts"
        }
    }
    
    var description: String {
        switch self {
        case .appIntent: return "Execute directly - no app opens"
        case .urlScheme: return "Open app via URL scheme"
        case .shortcut: return "Run a Shortcuts workflow"
        }
    }
}

/// Shortcut definition
struct ShortcutItem: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var shortcutIdentifier: String
    
    init(name: String, identifier: String) {
        self.name = name
        self.shortcutIdentifier = identifier
    }
}

// MARK: - App Intent Detection

/// Represents a detected app with available intents
struct DetectedApp: Codable, Identifiable {
    var id: UUID = UUID()
    var bundleId: String
    var appName: String
    var iconName: String? // SF Symbol or app icon
    var availableIntents: [AppIntentInfo]
}

/// Information about a specific app intent
struct AppIntentInfo: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var intentIdentifier: String
    var parameters: [IntentParameter]
}

/// Parameter for an app intent
struct IntentParameter: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var type: String
    var isRequired: Bool
}

// MARK: - Backup/Export

/// Export format for backup
struct WidgetBackup: Codable {
    var version: Int
    var appName: String
    var exportedAt: Date
    var widgets: [WidgetItem]
    
    static func create(from config: WidgetConfiguration) -> WidgetBackup {
        WidgetBackup(
            version: WidgetConfiguration.currentVersion,
            appName: "Widget",
            exportedAt: Date(),
            widgets: config.widgets
        )
    }
}

// MARK: - Storage Keys

enum StorageKeys {
    static let widgetConfiguration = "widgetConfiguration"
    static let lastBackupDate = "lastBackupDate"
    static let userPreferences = "userPreferences"
}

/// User preferences
struct UserPreferences: Codable {
    var backupLocation: BackupLocation
    var showGridLines: Bool
    var hapticFeedback: Bool
    
    init(backupLocation: BackupLocation = .iCloud,
         showGridLines: Bool = false,
         hapticFeedback: Bool = true) {
        self.backupLocation = backupLocation
        self.showGridLines = showGridLines
        self.hapticFeedback = hapticFeedback
    }
}

/// Backup location options
enum BackupLocation: String, Codable, CaseIterable {
    case iCloud = "iCloud"
    case files = "Files"
    
    var displayName: String { rawValue }
}

// MARK: - Color Extension

extension String {
    var hexColor: UIColor? {
        var hex = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }
        
        guard hex.count == 6 || hex.count == 8 else { return nil }
        
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        
        let length = hex.count
        let r, g, b, a: Double
        
        if length == 8 {
            r = Double((rgb >> 24) & 0xFF) / 255.0
            g = Double((rgb >> 16) & 0xFF) / 255.0
            b = Double((rgb >> 8) & 0xFF) / 255.0
            a = Double(rgb & 0xFF) / 255.0
        } else {
            r = Double((rgb >> 16) & 0xFF) / 255.0
            g = Double((rgb >> 8) & 0xFF) / 255.0
            b = Double(rgb & 0xFF) / 255.0
            a = 1.0
        }
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

import UIKit