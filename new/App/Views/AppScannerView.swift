import SwiftUI
import AppIntents

struct AppScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var installedApps: [DetectedApp] = []
    @State private var isScanning = true
    @State private var manualBundleId = ""
    @State private var showingManualInput = false
    
    let onSelect: (DetectedApp, AppIntentInfo) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isScanning {
                    scanningView
                } else {
                    appListView
                }
            }
            .navigationTitle("App Intents")
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
            .searchable(text: $searchText, prompt: "Search apps")
            .sheet(isPresented: $showingManualInput) {
                ManualIntentInputView { bundleId, intentId, intentName in
                    // Create a manual app entry
                    let manualApp = DetectedApp(
                        bundleId: bundleId,
                        appName: "Manual Input",
                        iconName: "app.fill",
                        availableIntents: [
                            AppIntentInfo(
                                name: intentName,
                                intentIdentifier: intentId,
                                parameters: []
                            )
                        ]
                    )
                    if let intent = manualApp.availableIntents.first {
                        onSelect(manualApp, intent)
                    }
                    dismiss()
                }
            }
            .onAppear {
                scanForApps()
            }
        }
    }
    
    private var scanningView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            
            Text("Scanning for installed apps...")
                .foregroundColor(.gray)
        }
    }
    
    private var appListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Predefined apps with known intents
                if !searchText.isEmpty || !predefinedApps.isEmpty {
                    ForEach(filteredApps) { app in
                        appRow(app)
                    }
                }
                
                // Instructions
                if installedApps.isEmpty && searchText.isEmpty {
                    instructionsView
                }
            }
        }
    }
    
    private func appRow(_ app: DetectedApp) -> some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: app.iconName ?? "app.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading) {
                    Text(app.appName)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                    
                    Text("\(app.availableIntents.count) intents")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            
            // Intents
            ForEach(app.availableIntents) { intent in
                intentRow(app: app, intent: intent)
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
        }
    }
    
    private func intentRow(app: DetectedApp, intent: AppIntentInfo) -> some View {
        Button {
            onSelect(app, intent)
            dismiss()
        } label: {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.yellow)
                
                Text(intent.name)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "plus.circle")
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.05))
        }
    }
    
    private var instructionsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "info.circle")
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text("App Intent Detection")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("The app scans for commonly used apps with known intents. Select an app below, or use the keyboard icon to manually enter intent details.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 40)
    }
    
    private var filteredApps: [DetectedApp] {
        let allApps = predefinedApps
        
        if searchText.isEmpty {
            return allApps
        }
        
        return allApps.filter { app in
            app.appName.localizedCaseInsensitiveContains(searchText) ||
            app.bundleId.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func scanForApps() {
        // Simulated scanning - in production, would use URL scheme detection
        // or other APIs to verify apps are installed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isScanning = false
        }
    }
    
    // Predefined list of apps with known App Intents
    private var predefinedApps: [DetectedApp] {
        [
            DetectedApp(
                bundleId: "com.apple.mobilesafari",
                appName: "Safari",
                iconName: "safari.fill",
                availableIntents: [
                    AppIntentInfo(name: "Open URL", intentIdentifier: "OpenURLIntent", parameters: [])
                ]
            ),
            DetectedApp(
                bundleId: "com.apple.mobilephone",
                appName: "Phone",
                iconName: "phone.fill",
                availableIntents: [
                    AppIntentInfo(name: "Call", intentIdentifier: "CallIntent", parameters: [])
                ]
            ),
            DetectedApp(
                bundleId: "com.apple.Maps",
                appName: "Maps",
                iconName: "map.fill",
                availableIntents: [
                    AppIntentInfo(name: "Show Location", intentIdentifier: "ShowLocationIntent", parameters: [])
                ]
            ),
            DetectedApp(
                bundleId: "com.apple.mobilenotes",
                appName: "Notes",
                iconName: "note.text",
                availableIntents: [
                    AppIntentInfo(name: "Create Note", intentIdentifier: "CreateNoteIntent", parameters: [])
                ]
            ),
            DetectedApp(
                bundleId: "com.apple.music",
                appName: "Music",
                iconName: "music.note",
                availableIntents: [
                    AppIntentInfo(name: "Play/Pause", intentIdentifier: "PlayPauseIntent", parameters: [])
                ]
            ),
            DetectedApp(
                bundleId: "com.apple.camera",
                appName: "Camera",
                iconName: "camera.fill",
                availableIntents: [
                    AppIntentInfo(name: "Take Photo", intentIdentifier: "TakePhotoIntent", parameters: [])
                ]
            ),
            DetectedApp(
                bundleId: "com.apple.Home",
                appName: "Home",
                iconName: "house.fill",
                availableIntents: [
                    AppIntentInfo(name: "Scene", intentIdentifier: "HomeSceneIntent", parameters: [])
                ]
            ),
            DetectedApp(
                bundleId: "com.apple.AppStore",
                appName: "App Store",
                iconName: "appstore.fill",
                availableIntents: [
                    AppIntentInfo(name: "Search", intentIdentifier: "SearchIntent", parameters: [])
                ]
            ),
            DetectedApp(
                bundleId: "com.apple.MobileSMS",
                appName: "Messages",
                iconName: "message.fill",
                availableIntents: [
                    AppIntentInfo(name: "Send Message", intentIdentifier: "SendMessageIntent", parameters: [])
                ]
            ),
            DetectedApp(
                bundleId: "com.apple.Clock",
                appName: "Clock",
                iconName: "clock.fill",
                availableIntents: [
                    AppIntentInfo(name: "Stopwatch", intentIdentifier: "StopwatchIntent", parameters: [])
                ]
            ),
            DetectedApp(
                bundleId: "com.apple.Weather",
                appName: "Weather",
                iconName: "cloud.sun.fill",
                availableIntents: [
                    AppIntentInfo(name: "Show Weather", intentIdentifier: "WeatherIntent", parameters: [])
                ]
            ),
            DetectedApp(
                bundleId: "com.apple.Passbook",
                appName: "Wallet",
                iconName: "wallet.pass.fill",
                availableIntents: [
                    AppIntentInfo(name: "Show Card", intentIdentifier: "ShowCardIntent", parameters: [])
                ]
            ),
            DetectedApp(
                bundleId: "com.apple.facetime",
                appName: "FaceTime",
                iconName: "video.fill",
                availableIntents: [
                    AppIntentInfo(name: "Call", intentIdentifier: "FaceTimeIntent", parameters: [])
                ]
            ),
            DetectedApp(
                bundleId: "com.apple.compact.proximity",
                appName: "AirDrop",
                iconName: "airplayaudio",
                availableIntents: [
                    AppIntentInfo(name: "Receive", intentIdentifier: "ReceiveIntent", parameters: [])
                ]
            ),
            DetectedApp(
                bundleId: "com.apple.alarm",
                appName: "Alarms",
                iconName: "alarm.fill",
                availableIntents: [
                    AppIntentInfo(name: "Add Alarm", intentIdentifier: "AddAlarmIntent", parameters: [])
                ]
            )
        ]
    }
}

// MARK: - Manual Intent Input

struct ManualIntentInputView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var bundleId = ""
    @State private var intentIdentifier = ""
    @State private var intentName = ""
    
    let onSave: (String, String, String) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Enter the app intent details manually. You can find this information from app documentation or intent discovery tools.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("App Bundle ID")
                                .foregroundColor(.gray)
                            TextField("com.example.app", text: $bundleId)
                                .textFieldStyle(.plain)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .autocapitalization(.none)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Intent Identifier")
                                .foregroundColor(.gray)
                            TextField("com.example.app.IntentName", text: $intentIdentifier)
                                .textFieldStyle(.plain)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .autocapitalization(.none)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Intent Name (for display)")
                                .foregroundColor(.gray)
                            TextField("My Custom Intent", text: $intentName)
                                .textFieldStyle(.plain)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                        }
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
                        onSave(bundleId, intentIdentifier, intentName)
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .disabled(bundleId.isEmpty || intentIdentifier.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AppScannerView { _, _ in }
}