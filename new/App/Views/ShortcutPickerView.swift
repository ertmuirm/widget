import SwiftUI

struct ShortcutPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var shortcuts: [ShortcutItem] = []
    @State private var isLoading = true
    @State private var showingManualInput = false
    @State private var manualName = ""
    @State private var manualURL = ""
    
    let onSelect: (ShortcutItem) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isLoading {
                    loadingView
                } else {
                    shortcutListView
                }
            }
            .navigationTitle("Shortcuts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingManualInput = true
                    } label: {
                        Image(systemName: "keyboard")
                            .foregroundColor(.white)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search shortcuts")
            .sheet(isPresented: $showingManualInput) {
                ManualShortcutInputView { name, url in
                    let shortcut = ShortcutItem(name: name, identifier: url)
                    onSelect(shortcut)
                    dismiss()
                }
            }
            .onAppear {
                loadShortcuts()
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            
            Text("Loading shortcuts...")
                .foregroundColor(.gray)
        }
    }
    
    private var shortcutListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if shortcuts.isEmpty && searchText.isEmpty {
                    emptyStateView
                } else {
                    ForEach(filteredShortcuts) { shortcut in
                        shortcutRow(shortcut)
                    }
                }
            }
        }
    }
    
    private func shortcutRow(_ shortcut: ShortcutItem) -> some View {
        Button {
            onSelect(shortcut)
            dismiss()
        } label: {
            HStack {
                Image(systemName: "arrow.triangle.branch")
                    .foregroundColor(.green)
                    .frame(width: 40)
                
                VStack(alignment: .leading) {
                    Text(shortcut.name)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                    
                    Text(shortcut.shortcutIdentifier)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle")
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No Shortcuts Found")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("The app couldn't detect any shortcuts on this device. You can create shortcuts in the Shortcuts app, or manually enter URL details.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                showingManualInput = true
            } label: {
                Text("Enter URL Manually")
                    .foregroundColor(.blue)
            }
            .padding(.top)
        }
        .padding(.top, 60)
    }
    
    private var filteredShortcuts: [ShortcutItem] {
        if searchText.isEmpty {
            return shortcuts
        }
        return shortcuts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func loadShortcuts() {
        // In a real implementation, this would query the Shortcuts app
        // For now, we'll use the predefined shortcuts list
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            shortcuts = predefinedShortcuts
            isLoading = false
        }
    }
    
    // Predefined common shortcuts
    private var predefinedShortcuts: [ShortcutItem] {
        [
            ShortcutItem(name: "Run Any Shortcut", identifier: "shortcuts://run-shortcut?name="),
            ShortcutItem(name: "Toggle Dark Mode", identifier: "shortcuts://run-shortcut?name=Toggle+Dark+Mode"),
            ShortcutItem(name: "Flashlight", identifier: "shortcuts://run-shortcut?name=Flashlight"),
            ShortcutItem(name: "Airplane Mode", identifier: "shortcuts://run-shortcut?name=Airplane+Mode"),
            ShortcutItem(name: "Wi-Fi Toggle", identifier: "shortcuts://run-shortcut?name=Wi-Fi+Toggle"),
            ShortcutItem(name: "Bluetooth Toggle", identifier: "shortcuts://run-shortcut?name=Bluetooth+Toggle"),
            ShortcutItem(name: "Battery Status", identifier: "shortcuts://run-shortcut?name=Battery+Status"),
            ShortcutItem(name: "Timer", identifier: "shortcuts://run-shortcut?name=Timer"),
            ShortcutItem(name: "Stopwatch", identifier: "shortcuts://run-shortcut?name=Stopwatch"),
            ShortcutItem(name: "Alarm", identifier: "shortcuts://run-shortcut?name=Set+Alarm"),
            ShortcutItem(name: "Weather", identifier: "shortcuts://run-shortcut?name=Current+Weather"),
            ShortcutItem(name: "Calendar Today", identifier: "shortcuts://run-shortcut?name=Today's+Events"),
            ShortcutItem(name: "Contacts", identifier: "shortcuts://run-shortcut?name=Contacts"),
            ShortcutItem(name: "Notes", identifier: "shortcuts://run-shortcut?name=New+Note"),
            ShortcutItem(name: "Reminders", identifier: "shortcuts://run-shortcut?name=Add+Reminder"),
            ShortcutItem(name: "Music Play", identifier: "shortcuts://run-shortcut?name=Play+Music"),
            ShortcutItem(name: "Music Pause", identifier: "shortcuts://run-shortcut?name=Pause+Music"),
            ShortcutItem(name: "Take Photo", identifier: "shortcuts://run-shortcut?name=Take+Photo"),
            ShortcutItem(name: "Scan QR Code", identifier: "shortcuts://run-shortcut?name=Scan+QR+Code"),
            ShortcutItem(name: "Clipboard", identifier: "shortcuts://run-shortcut?name=Show+Clipboard")
        ]
    }
}

// MARK: - Manual Shortcut Input

struct ManualShortcutInputView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var shortcutName = ""
    @State private var shortcutURL = ""
    
    let onSave: (String, String) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Enter the shortcut details. Use the URL format: shortcuts://run-shortcut?name=YourShortcutName")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Shortcut Name")
                                .foregroundColor(.gray)
                            TextField("My Shortcut", text: $shortcutName)
                                .textFieldStyle(.plain)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Shortcuts URL")
                                .foregroundColor(.gray)
                            TextField("shortcuts://run-shortcut?name=...", text: $shortcutURL)
                                .textFieldStyle(.plain)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }
                        
                        Text("Note: Replace spaces in the shortcut name with '+' or URL-encoded spaces (%20)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
            }
            .navigationTitle("Manual Input")
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
                        let encodedName = shortcutName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? shortcutName
                        let url = shortcutURL.isEmpty ? "shortcuts://run-shortcut?name=\(encodedName)" : shortcutURL
                        onSave(shortcutName, url)
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .disabled(shortcutName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ShortcutPickerView { _ in }
}