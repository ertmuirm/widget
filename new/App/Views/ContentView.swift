import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingBackupOptions = false
    @State private var showingRestoreOptions = false
    @State private var showingAddWidget = false
    @State private var selectedWidget: WidgetItem?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Home Screen Widgets Section
                        if !homeScreenWidgets.isEmpty {
                            widgetSection(title: "HOME SCREEN WIDGETS") {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                    ForEach(homeScreenWidgets) { widget in
                                        WidgetPreviewCard(widget: widget)
                                            .onTapGesture {
                                                selectedWidget = widget
                                            }
                                    }
                                }
                            }
                        }
                        
                        // Lock Screen Widgets Section
                        if !lockScreenWidgets.isEmpty {
                            widgetSection(title: "LOCK SCREEN WIDGETS") {
                                HStack(spacing: 12) {
                                    ForEach(lockScreenWidgets) { widget in
                                        LockScreenWidgetPreview(widget: widget)
                                            .onTapGesture {
                                                selectedWidget = widget
                                            }
                                    }
                                }
                            }
                        }
                        
                        // Add Widget Button
                        addWidgetSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Widget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingBackupOptions = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showingRestoreOptions = true
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.white)
                        }
                        
                        Button {
                            showingAddWidget = true
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddWidget) {
                AddWidgetSheet { family in
                    appState.addWidget(family)
                }
            }
            .sheet(isPresented: $showingBackupOptions) {
                BackupSheet(configuration: appState.configuration)
            }
            .sheet(isPresented: $showingRestoreOptions) {
                RestoreSheet { config in
                    appState.configuration = config
                    appState.saveConfiguration()
                }
            }
            .sheet(item: $selectedWidget) { widget in
                WidgetEditorView(widget: widget) { updated in
                    appState.updateWidget(updated)
                }
            }
        }
    }
    
    private var homeScreenWidgets: [WidgetItem] {
        appState.configuration.widgets.filter { $0.family.isHomeScreen }
    }
    
    private var lockScreenWidgets: [WidgetItem] {
        appState.configuration.widgets.filter { !$0.family.isHomeScreen }
    }
    
    @ViewBuilder
    private func widgetSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            content()
        }
    }
    
    private var addWidgetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ADD WIDGET")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Button {
                showingAddWidget = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add New Widget")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Widget Preview Cards

struct WidgetPreviewCard: View {
    let widget: WidgetItem
    
    var body: some View {
        VStack(spacing: 8) {
            // Widget preview
            WidgetGridView(widget: widget, isPreview: true)
                .frame(height: 140)
                .background(Color(white: 0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            // Widget type label
            Text(widget.family.displayName)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

struct LockScreenWidgetPreview: View {
    let widget: WidgetItem
    
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(white: 0.15))
                .frame(width: 60, height: widget.family == .lockCircular ? 60 : 40)
                .overlay {
                    Image(systemName: "app.fill")
                        .foregroundColor(.white)
                }
            
            Text(widget.family.displayName)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Widget Grid View (Shared between App and Widget Extension)

struct WidgetGridView: View {
    let widget: WidgetItem
    let isPreview: Bool
    
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: widget.family.gridColumns)
        let rows = widget.family.gridRows
        
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<rows, id: \.self) { row in
                ForEach(0..<widget.family.gridColumns, id: \.self) { col in
                    if let icon = iconAt(row: row, col: col) {
                        IconView(icon: icon, size: iconSize)
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .padding(8)
    }
    
    private func iconAt(row: Int, col: Int) -> IconItem? {
        widget.iconGrid.icons.first { $0.gridPosition.row == row && $0.gridPosition.col == col }
    }
    
    private var iconSize: CGFloat {
        isPreview ? 32 : 44
    }
}

struct IconView: View {
    let icon: IconItem
    let size: CGFloat
    
    var body: some View {
        ZStack {
            if let color = icon.backgroundColor.hexSwiftUIColor {
                color.opacity(Double(icon.opacity))
            } else {
                Color.black.opacity(Double(icon.opacity))
            }
            
            switch icon.displayType {
            case .icon:
                if let name = icon.iconName, !name.isEmpty {
                    Image(systemName: name)
                        .font(.system(size: size * 0.5))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "questionmark")
                        .foregroundColor(.gray)
                }
            case .text:
                if let text = icon.customText, !text.isEmpty {
                    Text(text)
                        .font(.system(size: CGFloat(icon.fontSize)))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(6)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}