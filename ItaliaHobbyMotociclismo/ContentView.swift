import SwiftUI

/// Root view: shows registration if the user isn't registered yet, otherwise the main tab bar.
struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var eventsVM: EventsViewModel

    var body: some View {
        Group {
            if authVM.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.4)
                    Text("Loading…")
                        .foregroundStyle(.secondary)
                }
            } else if !authVM.isRegistered {
                RegistrationView()
            } else if let user = authVM.currentUser {
                MainTabView(user: user)
            } else {
                RegistrationView()
            }
        }
        .animation(.easeInOut, value: authVM.isRegistered)
    }
}

/// The main tab bar shown after login.
struct MainTabView: View {
    let user: User
    @EnvironmentObject var eventsVM: EventsViewModel
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }

            ChatListView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right")
                }

            SettingsMenuView(user: user)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .onAppear {
            SyncManager.shared.startSync()
        }
        .onDisappear {
            SyncManager.shared.stopSync()
        }
    }

    /// Settings tab with profile, motorbike and privacy sub-menu.
    private struct SettingsMenuView: View {
        let user: User

        var body: some View {
            NavigationStack {
                List {
                    NavigationLink(destination: ProfileView(user: user)) {
                        Label("User Profile", systemImage: "person.crop.circle")
                    }
                    NavigationLink(destination: MotorbikesView(user: user)) {
                        Label("Motorbikes", systemImage: "motorcycle")
                    }
                    NavigationLink(destination: PrivacyView()) {
                        Label("Privacy", systemImage: "lock.shield")
                    }
                }
                .navigationTitle("Settings")
            }
        }
    }

    private struct MotorbikesView: View {
        let user: User

        var body: some View {
            List {
                Section("Your Motorcycle") {
                    LabeledContent("Brand", value: user.motorbikeBrand.isEmpty ? "—" : user.motorbikeBrand)
                    LabeledContent("Model", value: user.motorbikeModel.isEmpty ? "—" : user.motorbikeModel)
                    LabeledContent("Type", value: user.motorbikeType.isEmpty ? "—" : user.motorbikeType)
                }
            }
            .navigationTitle("Motorbikes")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private struct PrivacyView: View {
        var body: some View {
            List {
                Section {
                    Text("Manage your privacy preferences and data visibility from this section.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Privacy")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(EventsViewModel())
}
