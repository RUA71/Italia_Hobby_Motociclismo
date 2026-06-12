import SwiftUI

/// Root view: shows registration if the user isn't registered yet, otherwise the main tab bar.
struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var eventsVM: EventsViewModel

    var body: some View {
        Group {
            if authVM.isLoading {
                ProgressView("Caricamento…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    Label("Setting", systemImage: "gearshape")
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
                    NavigationLink("User Profile") {
                        ProfileView(user: user)
                    }

                    NavigationLink("Motorbikes") {
                        MotorbikesView(user: user)
                    }

                    NavigationLink("Privacy") {
                        PrivacyView()
                    }
                }
                .navigationTitle("Setting")
            }
        }
    }

    private struct MotorbikesView: View {
        let user: User

        var body: some View {
            Form {
                infoRow(label: "Brand", value: user.motorbikeBrand)
                infoRow(label: "Model", value: user.motorbikeModel)
                infoRow(label: "Type", value: user.motorbikeType)
            }
            .navigationTitle("Motorbikes")
        }

        @ViewBuilder
        private func infoRow(label: String, value: String) -> some View {
            HStack {
                Text(label)
                    .foregroundColor(.secondary)
                Spacer()
                Text(value.isEmpty ? "—" : value)
            }
        }
    }

    private struct PrivacyView: View {
        var body: some View {
            ScrollView {
                Text("Manage your privacy preferences and data visibility from this section.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .navigationTitle("Privacy")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(EventsViewModel())
}
