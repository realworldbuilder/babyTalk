import SwiftUI

struct SettingsView: View {
    @Environment(LogStore.self) private var logStore
    @State private var showingBabyProfileEditor = false
    @State private var showingAPIKeyEditor = false
    
    var body: some View {
        NavigationView {
            List {
                // Baby Profile Section
                Section {
                    if let baby = logStore.babyProfile {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(baby.name)
                                    .font(.headline)
                                Text("Born \(baby.birthDate, style: .date)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(baby.ageDescription)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Edit") {
                                showingBabyProfileEditor = true
                            }
                            .foregroundColor(.blue)
                        }
                    }
                } header: {
                    Text("Baby Profile")
                }
                
                // API Settings Section
                Section {
                    Button(action: { showingAPIKeyEditor = true }) {
                        HStack {
                            Text("Custom API Key")
                            Spacer()
                            Text("Configure")
                                .foregroundColor(.blue)
                        }
                    }
                    .foregroundColor(.primary)
                } header: {
                    Text("API Settings")
                } footer: {
                    Text("Baby Talk uses OpenAI's API for voice transcription and AI chat. A custom API key can be configured for increased usage limits.")
                }
                
                // Data Section
                Section {
                    HStack {
                        Text("Data Storage")
                        Spacer()
                        Text("Local Device")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: exportData) {
                        HStack {
                            Text("Export Data")
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                        }
                    }
                    .foregroundColor(.primary)
                } header: {
                    Text("Data")
                } footer: {
                    Text("All your baby's data is stored securely on your device. You can export it at any time.")
                }
                
                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://babytalkapp.com/privacy")!)
                    Link("Support", destination: URL(string: "https://babytalkapp.com/support")!)
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showingBabyProfileEditor) {
            if let baby = logStore.babyProfile {
                BabyProfileEditor(baby: baby)
            }
        }
        .sheet(isPresented: $showingAPIKeyEditor) {
            APIKeyEditor()
        }
    }
    
    private func exportData() {
        // TODO: Implement data export
        // For now, just show an alert
    }
}

struct BabyProfileEditor: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LogStore.self) private var logStore
    
    @State private var name: String
    @State private var birthDate: Date
    
    init(baby: BabyProfile) {
        _name = State(initialValue: baby.name)
        _birthDate = State(initialValue: baby.birthDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Baby's Name", text: $name)
                    
                    DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)
                } header: {
                    Text("Baby Information")
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveProfile() {
        guard let baby = logStore.babyProfile else { return }
        baby.name = name
        baby.birthDate = birthDate
        logStore.saveBabyProfile()
        dismiss()
    }
}

struct APIKeyEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var customAPIKey = ""
    @State private var showingKeychain = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("Baby Talk includes a built-in OpenAI API key for basic usage. You can provide your own API key for increased usage limits or if you prefer to use your own OpenAI account.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    SecureField("OpenAI API Key", text: $customAPIKey)
                    
                    Button("Save Custom Key") {
                        saveAPIKey()
                    }
                    .disabled(customAPIKey.isEmpty)
                    
                    if hasCustomKey {
                        Button("Remove Custom Key") {
                            removeAPIKey()
                        }
                        .foregroundColor(.red)
                    }
                } header: {
                    Text("Custom API Key")
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Get your API key from OpenAI's website (platform.openai.com). Your key will be stored securely in the iOS Keychain.")
                        
                        if hasCustomKey {
                            Text("✅ Custom API key is currently configured")
                                .foregroundColor(.green)
                        } else {
                            Text("Using built-in API key")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("API Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var hasCustomKey: Bool {
        // Check if custom key exists in keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.whussey.babytalk.openai",
            kSecAttrAccount as String: "custom_api_key",
            kSecReturnData as String: false
        ]
        return SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess
    }
    
    private func saveAPIKey() {
        let keyData = customAPIKey.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.whussey.babytalk.openai",
            kSecAttrAccount as String: "custom_api_key",
            kSecValueData as String: keyData
        ]
        
        // Delete existing key first
        SecItemDelete(query as CFDictionary)
        
        // Add new key
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            customAPIKey = ""
            dismiss()
        }
    }
    
    private func removeAPIKey() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.whussey.babytalk.openai",
            kSecAttrAccount as String: "custom_api_key"
        ]
        
        SecItemDelete(query as CFDictionary)
        dismiss()
    }
}

#Preview {
    SettingsView()
        .environment(LogStore())
}