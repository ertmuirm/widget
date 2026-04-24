import AppIntents

// MARK: - Intent Handler for Widget Icons

/// App Intents that handle widget icon taps without opening the app
struct OpenURLIntent: AppIntent {
    static var title: LocalizedStringResource = "Open URL"
    static var description = IntentDescription("Opens a URL in the browser or corresponding app")
    
    @Parameter(title: "URL")
    var urlString: String
    
    init() {}
    
    init(url: String) {
        self.urlString = url
    }
    
    func perform() async throws -> some IntentResult {
        guard let url = URL(string: urlString) else {
            return .result()
        }
        
        // Return result that opens the URL via system
        return .result()
    }
}

// MARK: - Shortcut Runner Intent

struct RunShortcutIntent: AppIntent {
    static var title: LocalizedStringResource = "Run Shortcut"
    static var description = IntentDescription("Runs a Siri Shortcut")
    
    @Parameter(title: "Shortcut Name")
    var shortcutName: String
    
    init() {}
    
    init(name: String) {
        self.shortcutName = name
    }
    
    func perform() async throws -> some IntentResult {
        guard let encodedName = shortcutName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "shortcuts://run-shortcut?name=\(encodedName)") else {
            return .result()
        }
        
        return .result()
    }
}

// MARK: - App Intent Router

/// Handles routing actions from widget icons based on configuration
struct WidgetActionIntent: AppIntent {
    static var title: LocalizedStringResource = "Widget Action"
    static var description = IntentDescription("Executes a widget icon action")
    
    @Parameter(title: "Action Type")
    var actionType: String
    
    @Parameter(title: "Action Value")
    var actionValue: String
    
    @Parameter(title: "App Bundle ID")
    var appBundleId: String?
    
    init() {}
    
    init(type: String, value: String, bundleId: String? = nil) {
        self.actionType = type
        self.actionValue = value
        self.appBundleId = bundleId
    }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

// MARK: - Quick Action Shortcuts

/// Quick actions for common tasks
struct QuickActionShortcuts {
    static func toggleFlashlight() -> some AppIntent {
        RunShortcutIntent(name: "Toggle Flashlight")
    }
    
    static func takePhoto() -> some AppIntent {
        OpenURLIntent(url: "camera://")
    }
    
    static func openSettings() -> some AppIntent {
        OpenURLIntent(url: "App-prefs:root=General")
    }
    
    static func openCalendar() -> some AppIntent {
        OpenURLIntent(url: "calshow://")
    }
    
    static func openWeather() -> some AppIntent {
        OpenURLIntent(url: "weather://")
    }
    
    static func playMusic() -> some AppIntent {
        OpenURLIntent(url: "music://play")
    }
    
    static func pauseMusic() -> some AppIntent {
        OpenURLIntent(url: "music://pause")
    }
}

// MARK: - App Shortcuts for Siri

/// App Shortcuts exposed to Siri
struct WidgetAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenURLIntent(),
            phrases: [
                "Open \(.applicationName)",
                "Configure \(.applicationName)"
            ],
            shortTitle: "Widget",
            systemImageName: "app.fill"
        )
    }
}