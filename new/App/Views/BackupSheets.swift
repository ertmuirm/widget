import SwiftUI
import UniformTypeIdentifiers

struct BackupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @State private var isExporting = false
    @State private var exportResult: Result<URL, Error>?
    @State private var showingFilePicker = false
    @State private var showingiCloudOptions = false
    @State private var iCloudBackups: [URL] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Export Section
                        exportSection
                        
                        // iCloud Section
                        iCloudSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Backup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .fileExporter(
                isPresented: $showingFilePicker,
                document: JSONDocument(json: exportJSON),
                contentType: .json,
                defaultFilename: "widget_backup_\(dateString).json"
            ) { result in
                exportResult = .success(URL(fileURLWithPath: ""))
                dismiss()
            } onFailure: { error in
                exportResult = .failure(error)
            }
            .alert("Export Complete", isPresented: .init(
                get: { exportResult != nil },
                set: { if !$0 { exportResult = nil } }
            )) {
                Button("OK") { }
            } message: {
                Text("Backup exported successfully!")
            }
        }
    }
    
    private var exportJSON: String {
        (try? Storage.shared.exportToJSON(appState.configuration)) ?? "{}"
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return formatter.string(from: Date())
    }
    
    private var exportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EXPORT TO FILES")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Button {
                showingFilePicker = true
            } label: {
                HStack {
                    Image(systemName: "folder")
                        .foregroundColor(.blue)
                    
                    Text("Save to Files App")
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
            
            Text("Save the backup file to your preferred location in the Files app. You can restore from this file later.")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    private var iCloudSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ICLOUD DRIVE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Button {
                exportToiCloud()
            } label: {
                HStack {
                    Image(systemName: "icloud")
                        .foregroundColor(.cyan)
                    
                    Text("Save to iCloud")
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if isExporting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
            .disabled(isExporting)
            
            Text("Backups are saved to iCloud Drive > Documents. Access from any device signed into the same Apple ID.")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    private func exportToiCloud() {
        isExporting = true
        DispatchQueue.global().async {
            do {
                _ = try Storage.shared.backupToiCloud(appState.configuration)
                DispatchQueue.main.async {
                    isExporting = false
                    dismiss()
                }
            } catch {
                DispatchQueue.main.async {
                    isExporting = false
                    exportResult = .failure(error)
                }
            }
        }
    }
}

// MARK: - Restore Sheet

struct RestoreSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isRestoring = false
    @State private var showingFilePicker = false
    @State private var iCloudBackups: [URL] = []
    @State private var errorMessage: String?
    
    let onRestore: (AppConfig) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Import from Files
                        importFromFilesSection
                        
                        // iCloud Backups
                        iCloudRestoreSection
                        
                        // Error Message
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Restore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .onAppear {
                loadiCloudBackups()
            }
        }
    }
    
    private var importFromFilesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("IMPORT FROM FILES")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Button {
                showingFilePicker = true
            } label: {
                HStack {
                    Image(systemName: "folder")
                        .foregroundColor(.blue)
                    
                    Text("Select Backup File")
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "square.and.arrow.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
            
            Text("Select a previously exported JSON backup file from the Files app.")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    private var iCloudRestoreSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ICLOUD BACKUPS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            if iCloudBackups.isEmpty {
                HStack {
                    Image(systemName: "icloud")
                        .foregroundColor(.gray)
                    
                    Text("No iCloud backups found")
                        .foregroundColor(.gray)
                }
                .padding()
            } else {
                ForEach(iCloudBackups, id: \.absoluteString) { url in
                    Button {
                        restoreFromiCloud(url)
                    } label: {
                        HStack {
                            Image(systemName: "doc")
                                .foregroundColor(.cyan)
                            
                            Text(url.lastPathComponent)
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            if isRestoring {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "arrow.down.circle")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                    .disabled(isRestoring)
                }
            }
        }
    }
    
    private func loadiCloudBackups() {
        DispatchQueue.global().async {
            let backups = Storage.shared.listBackups()
            DispatchQueue.main.async {
                iCloudBackups = backups
            }
        }
    }
    
    private func restoreFromiCloud(_ url: URL) {
        isRestoring = true
        errorMessage = nil
        
        DispatchQueue.global().async {
            do {
                let config = try Storage.shared.restoreFromiCloud(at: url)
                DispatchQueue.main.async {
                    isRestoring = false
                    onRestore(config)
                    dismiss()
                }
            } catch {
                DispatchQueue.main.async {
                    isRestoring = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Start accessing security-scoped resource
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let config = try Storage.shared.loadFromFiles(at: url)
                onRestore(config)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - JSON Document

struct JSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var json: String
    
    init(json: String) {
        self.json = json
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            json = String(data: data, encoding: .utf8) ?? ""
        } else {
            json = "{}"
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: json.data(using: .utf8)!)
    }
}

#Preview {
    BackupSheet()
        .environmentObject(AppState())
}