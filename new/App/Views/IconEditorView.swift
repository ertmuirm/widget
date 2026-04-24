import SwiftUI

struct IconEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var icon: IconItem
    @State private var showingAppScanner = false
    @State private var showingShortcutPicker = false
    
    let onSave: (IconItem) -> Void
    
    init(icon: IconItem, onSave: @escaping (IconItem) -> Void) {
        _icon = State(initialValue: icon)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Preview
                        previewSection
                        
                        // Display Type
                        displayTypeSection
                        
                        // Icon Selection (if display type is icon)
                        if icon.displayType == .icon {
                            iconSelectionSection
                        }
                        
                        // Text Input (if display type is text)
                        if icon.displayType == .text {
                            textInputSection
                        }
                        
                        // Background & Styling
                        stylingSection
                        
                        // Action Configuration
                        actionSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Icon Settings")
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
                        onSave(icon)
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingAppScanner) {
                AppScannerView { app, intent in
                    icon.action = IconAction(
                        type: .appIntent,
                        value: intent.intentIdentifier,
                        appBundleId: app.bundleId,
                        intentName: intent.name
                    )
                }
            }
            .sheet(isPresented: $showingShortcutPicker) {
                ShortcutPickerView { shortcut in
                    icon.action = IconAction(
                        type: .shortcut,
                        value: shortcut.shortcutIdentifier,
                        intentName: shortcut.name
                    )
                }
            }
        }
    }
    
    private var previewSection: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(icon.backgroundColor.hexSwiftUIColor?.opacity(Double(icon.opacity)) ?? Color.black.opacity(Double(icon.opacity)))
                
                iconPreviewContent
            }
            .frame(width: 80, height: 80)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    @ViewBuilder
    private var iconPreviewContent: some View {
        switch icon.displayType {
        case .icon:
            if let name = icon.iconName, !name.isEmpty {
                Image(systemName: name)
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            } else {
                Image(systemName: "questionmark")
                    .font(.system(size: 36))
                    .foregroundColor(.gray)
            }
        case .text:
            if let text = icon.customText, !text.isEmpty {
                Text(text)
                    .font(.system(size: CGFloat(icon.fontSize)))
                    .foregroundColor(.white)
            } else {
                Text("Text")
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var displayTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DISPLAY")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                displayTypeButton(.icon, label: "Icon", icon: "app.fill")
                displayTypeButton(.text, label: "Text", icon: "textformat")
            }
        }
    }
    
    private func displayTypeButton(_ type: IconDisplayType, label: String, icon: String) -> some View {
        Button {
            icon.displayType = type
        } label: {
            HStack {
                Image(systemName: icon)
                Text(label)
            }
            .foregroundColor(icon.displayType == type ? .black : .white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(icon.displayType == type ? Color.white : Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var iconSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ICON")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Button {
                showingAppScanner = true
            } label: {
                HStack {
                    if let name = icon.iconName, !name.isEmpty {
                        Image(systemName: name)
                            .frame(width: 30)
                    }
                    Text(icon.iconName ?? "Select SF Symbol")
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
        }
    }
    
    private var textInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CUSTOM TEXT")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            TextField("Enter text", text: Binding(
                get: { icon.customText ?? "" },
                set: { icon.customText = $0 }
            ))
            .textFieldStyle(.plain)
            .foregroundColor(.white)
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            
            HStack {
                Text("Font Size")
                    .foregroundColor(.gray)
                Spacer()
                Stepper("\(icon.fontSize)", value: Binding(
                    get: { icon.fontSize },
                    set: { icon.fontSize = max(2, min(30, $0)) }
                ), in: 2...30)
                .foregroundColor(.white)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    private var stylingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("STYLE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            // Background Color
            VStack(alignment: .leading, spacing: 8) {
                Text("Background Color")
                    .foregroundColor(.gray)
                
                HStack(spacing: 8) {
                    ForEach(predefinedColors, id: \.self) { color in
                        colorButton(color)
                    }
                    
                    Button {
                        // TODO: Custom color picker
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 1)
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            
            // Opacity Slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Opacity")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(Int(icon.opacity * 100))%")
                        .foregroundColor(.white)
                }
                
                Slider(value: Binding(
                    get: { icon.opacity },
                    set: { icon.opacity = $0 }
                ), in: 0...1)
                .tint(.white)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    private func colorButton(_ hex: String) -> some View {
        Button {
            icon.backgroundColor = hex
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: hex) ?? .black)
                    .frame(width: 36, height: 36)
                
                if icon.backgroundColor == hex {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
            }
        }
    }
    
    private var predefinedColors: [String] {
        ["#000000", "#FF5733", "#33FF57", "#3357FF", "#FF33F5", "#F5FF33", "#FFFFFF", "#808080"]
    }
    
    private var actionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ACTION")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            // Action Type Selector
            VStack(spacing: 0) {
                actionTypeRow(.appIntent, action: icon.action, iconName: "bolt.fill", label: "App Intent", description: "Execute directly - no app opens")
                Divider().background(Color.gray.opacity(0.3))
                actionTypeRow(.shortcut, action: icon.action, iconName: "arrow.triangle.branch", label: "Shortcuts", description: "Run a Shortcuts workflow")
                Divider().background(Color.gray.opacity(0.3))
                actionTypeRow(.urlScheme, action: icon.action, iconName: "link", label: "URL Scheme", description: "Open via URL scheme")
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            
            // Action Configuration
            actionConfigSection
        }
    }
    
    private func actionTypeRow(_ type: ActionType, icon action: IconAction, iconName: String, label: String, description: String) -> some View {
        Button {
            action.type = type
        } label: {
            HStack {
                Image(systemName: iconName)
                    .frame(width: 24)
                    .foregroundColor(action.type == type ? .white : .gray)
                
                VStack(alignment: .leading) {
                    Text(label)
                        .foregroundColor(.white)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if action.type == type {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var actionConfigSection: some View {
        switch icon.action.type {
        case .appIntent:
            VStack(alignment: .leading, spacing: 8) {
                Text("App Intent")
                    .foregroundColor(.gray)
                
                Button {
                    showingAppScanner = true
                } label: {
                    HStack {
                        Image(systemName: "app.fill")
                        Text(icon.action.intentName ?? "Select App Intent")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
                
                Button {
                    // Manual input for app intent
                } label: {
                    Text("Enter Manually")
                        .foregroundColor(.blue)
                }
            }
            
        case .shortcut:
            VStack(alignment: .leading, spacing: 8) {
                Text("Shortcuts")
                    .foregroundColor(.gray)
                
                Button {
                    showingShortcutPicker = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.branch")
                        Text(icon.action.intentName ?? "Select Shortcut")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
            }
            
        case .urlScheme:
            VStack(alignment: .leading, spacing: 8) {
                Text("URL Scheme")
                    .foregroundColor(.gray)
                
                TextField("e.g., shortcuts://run-shortcut?name=...", text: Binding(
                    get: { icon.action.value },
                    set: { icon.action.value = $0 }
                ))
                .textFieldStyle(.plain)
                .foregroundColor(.white)
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .autocapitalization(.none)
                .autocorrectionDisabled()
            }
        }
    }
}

#Preview {
    IconEditorView(icon: IconItem(position: GridPosition(col: 0, row: 0))) { _ in }
}