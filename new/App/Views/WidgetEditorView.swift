import SwiftUI

struct WidgetEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var widget: WidgetItem
    @State private var selectedIcon: IconItem?
    @State private var showingIconPicker = false
    @State private var showingColorPicker = false
    
    let onSave: (WidgetItem) -> Void
    
    init(widget: WidgetItem, onSave: @escaping (WidgetItem) -> Void) {
        _widget = State(initialValue: widget)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Widget Preview
                        previewSection
                        
                        // Icon Grid Editor
                        iconGridSection
                        
                        // Widget Settings
                        settingsSection
                    }
                    .padding()
                }
            }
            .navigationTitle(widget.family.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(widget)
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                }
            }
            .sheet(item: $selectedIcon) { icon in
                IconEditorView(icon: icon) { updatedIcon in
                    updateIcon(updatedIcon)
                }
            }
        }
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PREVIEW")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            WidgetGridView(widget: widget, isPreview: false)
                .frame(height: 280)
                .background(Color(white: 0.1))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    private var iconGridSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ICONS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: widget.family.gridColumns)
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(0..<widget.family.gridRows, id: \.self) { row in
                    ForEach(0..<widget.family.gridColumns, id: \.self) { col in
                        if let icon = iconAt(row: row, col: col) {
                            iconCell(icon: icon)
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        } else {
                            emptyIconCell
                                .onTapGesture {
                                    let newIcon = IconItem(position: GridPosition(col: col, row: row))
                                    widget.iconGrid.icons.append(newIcon)
                                    selectedIcon = newIcon
                                }
                        }
                    }
                }
            }
        }
    }
    
    private func iconCell(icon: IconItem) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(icon.backgroundColor.hexColor?.opacity(icon.opacity) ?? Color.black.opacity(icon.opacity))
            
            switch icon.displayType {
            case .icon:
                if let name = icon.iconName, !name.isEmpty {
                    Image(systemName: name)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "plus")
                        .foregroundColor(.gray)
                }
            case .text:
                if let text = icon.customText, !text.isEmpty {
                    Text(text)
                        .font(.system(size: CGFloat(icon.fontSize)))
                        .foregroundColor(.white)
                        .lineLimit(1)
                } else {
                    Text("+")
                        .foregroundColor(.gray)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var emptyIconCell: some View {
        RoundedRectangle(cornerRadius: 8)
            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
            .foregroundColor(.gray.opacity(0.5))
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                Image(systemName: "plus")
                    .foregroundColor(.gray)
            )
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SETTINGS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            VStack(spacing: 0) {
                settingsRow(icon: "square.grid.3x3", title: "Grid Size", value: "\(widget.family.gridColumns)×\(widget.family.gridRows)")
                Divider().background(Color.gray.opacity(0.3))
                settingsRow(icon: "app", title: "Max Icons", value: "\(widget.family.maxIcons)")
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    private func settingsRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.gray)
        }
        .padding()
    }
    
    private func iconAt(row: Int, col: Int) -> IconItem? {
        widget.iconGrid.icons.first { $0.gridPosition.row == row && $0.gridPosition.col == col }
    }
    
    private func updateIcon(_ updatedIcon: IconItem) {
        if let index = widget.iconGrid.icons.firstIndex(where: { $0.id == updatedIcon.id }) {
            widget.iconGrid.icons[index] = updatedIcon
        } else {
            widget.iconGrid.icons.append(updatedIcon)
        }
    }
}

#Preview {
    WidgetEditorView(widget: WidgetItem(
        family: .homeMedium,
        iconGrid: IconGrid(columns: 3, rows: 3)
    )) { _ in }
}