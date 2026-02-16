import SwiftUI

struct MainTabView: View {
    @Environment(LogStore.self) private var logStore
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if logStore.babyProfile == nil {
                SetupView()
            } else {
                TabView(selection: $selectedTab) {
                    TodayView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Today")
                        }
                        .tag(0)
                    
                    RecordView()
                        .tabItem {
                            Image(systemName: "mic.fill")
                            Text("Record")
                        }
                        .tag(1)
                    
                    HistoryView()
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("History")
                        }
                        .tag(2)
                    
                    ChatView()
                        .tabItem {
                            Image(systemName: "message.fill")
                            Text("Chat")
                        }
                        .tag(3)
                    
                    SettingsView()
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                        .tag(4)
                }
                .accentColor(.blue)
            }
        }
    }
}

struct SetupView: View {
    @Environment(LogStore.self) private var logStore
    @State private var babyName = ""
    @State private var birthDate = Date()
    @State private var isShowingDatePicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.pink.opacity(0.7))
                    
                    Text("Welcome to Baby Talk")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text("Let's set up your baby's profile to get started")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 50)
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Baby's Name")
                            .font(.headline)
                        TextField("Enter baby's name", text: $babyName)
                            .textFieldStyle(.roundedBorder)
                            .font(.body)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Birth Date")
                            .font(.headline)
                        
                        Button(action: { isShowingDatePicker.toggle() }) {
                            HStack {
                                Text(birthDate, style: .date)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "calendar")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
                
                if isShowingDatePicker {
                    DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)
                        .datePickerStyle(.wheel)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: createProfile) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .disabled(babyName.isEmpty)
                .opacity(babyName.isEmpty ? 0.6 : 1.0)
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
    
    private func createProfile() {
        logStore.createBabyProfile(name: babyName, birthDate: birthDate)
    }
}

#Preview {
    MainTabView()
        .environment(LogStore())
}