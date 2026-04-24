import WidgetKit
import SwiftUI

@main
struct WidgetBundle: WidgetBundle {
    var body: some Widget {
        HomeScreenWidget()
        LockScreenWidget()
    }
}

// MARK: - Home Screen Widget

struct HomeScreenWidget: Widget {
    let kind: String = "HomeScreenWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetTimelineProvider()) { entry in
            HomeWidgetEntryView(entry: entry)
                .containerBackground(.black.ignoresSafeArea(), for: .widget)
        }
        .configurationDisplayName("Widget")
        .description("Customizable icon grid widget")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

// MARK: - Lock Screen Widget

struct LockScreenWidget: Widget {
    let kind: String = "LockScreenWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetTimelineProvider()) { entry in
            LockScreenWidgetEntryView(entry: entry)
                .containerBackground(.black.ignoresSafeArea(), for: .widget)
        }
        .configurationDisplayName("Widget")
        .description("Customizable lock screen widget")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

// MARK: - Timeline Entry

struct WidgetEntry: TimelineEntry {
    let date: Date
    let widget: WidgetItem?
}

// MARK: - Timeline Provider

struct WidgetTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), widget: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        let entry = WidgetEntry(date: Date(), widget: nil)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        let config = Storage.shared.loadConfiguration()
        
        // Find the appropriate widget for this family
        let family: AppWidgetFamily
        switch context.family {
        case .systemSmall:
            family = .homeSmall
        case .systemMedium:
            family = .homeMedium
        case .systemLarge:
            family = .homeLarge
        case .systemExtraLarge:
            family = .homeExtraLarge
        case .accessoryCircular:
            family = .lockCircular
        case .accessoryRectangular:
            family = .lockRectangular
        case .accessoryInline:
            family = .lockInline
        default:
            family = .homeMedium
        }
        
        let widget = config?.widgets.first { $0.family == family }
        let entry = WidgetEntry(date: Date(), widget: widget)
        
        // Refresh every hour, but mostly we want immediate updates
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

// MARK: - Home Widget View

struct HomeWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: WidgetEntry
    
    var body: some View {
        if let widget = entry.widget {
            HomeWidgetGrid(widget: widget, family: family)
        } else {
            placeholderView
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            Color.black
            
            VStack(spacing: 8) {
                Image(systemName: "app.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.5))
                
                Text("Widget")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
}

struct HomeWidgetGrid: View {
    let widget: WidgetItem
    let family: AppWidgetFamily
    
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: widget.family.gridColumns)
        
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<widget.family.gridRows, id: \.self) { row in
                ForEach(0..<widget.family.gridColumns, id: \.self) { col in
                    if let icon = iconAt(row: row, col: col) {
                        HomeIconView(icon: icon, size: iconSize)
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .padding(6)
    }
    
    private func iconAt(row: Int, col: Int) -> IconItem? {
        widget.iconGrid.icons.first { $0.gridPosition.row == row && $0.gridPosition.col == col }
    }
    
    private var iconSize: CGFloat {
        switch family {
        case .systemSmall: return 24
        case .systemMedium: return 28
        case .systemLarge: return 22
        case .systemExtraLarge: return 20
        default: return 28
        }
    }
}

struct HomeIconView: View {
    let icon: IconItem
    let size: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(icon.backgroundColor.hexSwiftUIColor?.opacity(icon.opacity) ?? Color.black.opacity(icon.opacity))
            
            switch icon.displayType {
            case .icon:
                if let name = icon.iconName, !name.isEmpty {
                    Image(systemName: name)
                        .font(.system(size: size * 0.6))
                        .foregroundColor(.white)
                }
            case .text:
                if let text = icon.customText, !text.isEmpty {
                    Text(text)
                        .font(.system(size: CGFloat(icon.fontSize) * 0.6))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Lock Screen Widget View

struct LockScreenWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: WidgetEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            circularView
        case .accessoryRectangular:
            rectangularView
        case .accessoryInline:
            inlineView
        default:
            circularView
        }
    }
    
    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            
            if let icon = entry.widget?.iconGrid.icons.first {
                switch icon.displayType {
                case .icon:
                    if let name = icon.iconName {
                        Image(systemName: name)
                            .font(.title2)
                    } else {
                        Image(systemName: "questionmark")
                    }
                case .text:
                    if let text = icon.customText, !text.isEmpty {
                        Text(String(text.prefix(1)))
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
            } else {
                Image(systemName: "app")
            }
        }
    }
    
    private var rectangularView: some View {
        HStack(spacing: 8) {
            ForEach(Array((entry.widget?.iconGrid.icons ?? []).prefix(6).enumerated()), id: \.offset) { _, icon in
                VStack(spacing: 2) {
                    switch icon.displayType {
                    case .icon:
                        if let name = icon.iconName {
                            Image(systemName: name)
                                .font(.caption)
                        } else {
                            Image(systemName: "questionmark")
                                .font(.caption)
                        }
                    case .text:
                        if let text = icon.customText, !text.isEmpty {
                            Text(text)
                                .font(.system(size: 10))
                                .lineLimit(1)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var inlineView: some View {
        HStack(spacing: 4) {
            ForEach(Array((entry.widget?.iconGrid.icons ?? []).prefix(3).enumerated()), id: \.offset) { _, icon in
                switch icon.displayType {
                case .icon:
                    if let name = icon.iconName {
                        Image(systemName: name)
                    }
                case .text:
                    if let text = icon.customText, !text.isEmpty {
                        Text(text)
                    }
                }
            }
        }
    }
}

#Preview("Small", as: .systemSmall) {
    HomeScreenWidget()
} timeline: {
    WidgetEntry(date: Date(), widget: nil)
}

#Preview("Medium", as: .systemMedium) {
    HomeScreenWidget()
} timeline: {
    WidgetEntry(date: Date(), widget: nil)
}

#Preview("Circular Lock Screen", as: .accessoryCircular) {
    LockScreenWidget()
} timeline: {
    WidgetEntry(date: Date(), widget: nil)
}