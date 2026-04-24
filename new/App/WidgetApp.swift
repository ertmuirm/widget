import SwiftUI
import WidgetKit

@main
struct WidgetApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}

/// Main application state
final class AppState: ObservableObject {
    @Published var configuration: AppConfig
    @Published var preferences: UserPreferences
    
    private let storage = Storage.shared
    
    init() {
        self.configuration = storage.loadConfiguration() ?? AppConfig()
        self.preferences = storage.loadPreferences()
    }
    
    func saveConfiguration() {
        storage.saveConfiguration(configuration)
    }
    
    func savePreferences() {
        storage.savePreferences(preferences)
    }
    
    func addWidget(_ family: AppWidgetFamily) {
        let grid = IconGrid(columns: family.gridColumns, rows: family.gridRows)
        var widget = WidgetItem(family: family, iconGrid: grid)
        
        // Initialize with empty icons based on max capacity
        var icons: [IconItem] = []
        for row in 0..<family.gridRows {
            for col in 0..<family.gridColumns {
                icons.append(IconItem(position: GridPosition(col: col, row: row)))
            }
        }
        widget.iconGrid = IconGrid(columns: family.gridColumns, rows: family.gridRows, icons: icons)
        
        configuration.widgets.append(widget)
        saveConfiguration()
    }
    
    func deleteWidget(_ widget: WidgetItem) {
        configuration.widgets.removeAll { $0.id == widget.id }
        saveConfiguration()
    }
    
    func updateWidget(_ widget: WidgetItem) {
        if let index = configuration.widgets.firstIndex(where: { $0.id == widget.id }) {
            var updated = widget
            updated.modifiedAt = Date()
            configuration.widgets[index] = updated
            saveConfiguration()
        }
    }
    
    func refreshWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}