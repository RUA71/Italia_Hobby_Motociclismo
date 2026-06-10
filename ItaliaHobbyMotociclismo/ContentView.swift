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
                    Label("Mappa", systemImage: "map")
                }

            ChatListView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right")
                }

            TripsView()
                .tabItem {
                    Label("Uscite", systemImage: "road.lanes")
                }

            ProfileView(user: user)
                .tabItem {
                    Label("Profilo", systemImage: "person.circle")
                }
        }
        .onAppear {
            SyncManager.shared.startSync()
        }
        .onDisappear {
            SyncManager.shared.stopSync()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(EventsViewModel())
}
