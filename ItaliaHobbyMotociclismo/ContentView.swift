import SwiftUI

/// Root view: shows a splash screen on launch, then registration or the main tab bar.
struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var eventsVM: EventsViewModel

    /// Controls splash visibility; starts as `true` and is dismissed once
    /// the remote fetch completes or 5 seconds have elapsed.
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            } else {
                ZStack {
                    CrownBackground()

                    Group {
                        if !authVM.isRegistered {
                            RegistrationView()
                        } else if let user = authVM.currentUser {
                            MainTabView(user: user)
                        } else {
                            RegistrationView()
                        }
                    }
                }
                .transition(.opacity)
                .zIndex(0)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showSplash)
        .tint(CrownTheme.gold)
        .preferredColorScheme(.dark)
        .task {
            // Hard cap: dismiss the splash after 5 seconds at the latest.
            try? await Task.sleep(for: .seconds(5))
            showSplash = false
        }
        .onChange(of: authVM.isLoading) { _, isLoading in
            // Dismiss as soon as the remote fetch completes.
            if !isLoading {
                showSplash = false
            }
        }
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
        .crownTabChrome()
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
                ZStack {
                    CrownBackground()

                    ScrollView {
                        VStack(spacing: 20) {
                            CrownHeroBanner(
                                title: "Club Court",
                                subtitle: "Review your rider details, your motorcycle and the privacy settings from one hall.",
                                symbol: "shield.lefthalf.filled"
                            )

                            CrownPanel(spacing: 0) {
                                settingLink(title: "User Profile", systemImage: "person.crop.circle", destination: ProfileView(user: user))
                                Divider().background(CrownTheme.gold.opacity(0.35))
                                settingLink(title: "Motorbikes", systemImage: "motorcycle", destination: MotorbikesView(user: user))
                                Divider().background(CrownTheme.gold.opacity(0.35))
                                settingLink(title: "Privacy", systemImage: "lock.shield", destination: PrivacyView())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                    }
                }
                .navigationTitle("Settings")
                .crownNavigationChrome()
            }
        }

        private func settingLink<Destination: View>(title: String, systemImage: String, destination: Destination) -> some View {
            NavigationLink {
                destination
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(CrownTheme.crimson)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(CrownTheme.gold.opacity(0.26)))

                    Text(title)
                        .font(.system(.headline, design: .serif, weight: .semibold))
                        .foregroundStyle(CrownTheme.ink)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(CrownTheme.bronze)
                }
                .padding(.vertical, 14)
            }
        }
    }

    private struct MotorbikesView: View {
        let user: User

        var body: some View {
            ZStack {
                CrownBackground()

                ScrollView {
                    CrownPanel {
                        CrownSectionHeader(
                            title: "Your Motorcycle",
                            subtitle: "The machine you bring to the next ride."
                        )
                        infoRow(label: "Brand", value: user.motorbikeBrand)
                        infoRow(label: "Model", value: user.motorbikeModel)
                        infoRow(label: "Type", value: user.motorbikeType)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Motorbikes")
            .crownNavigationChrome()
        }

        @ViewBuilder
        private func infoRow(label: String, value: String) -> some View {
            HStack {
                Text(label)
                    .font(.system(.headline, design: .serif, weight: .semibold))
                    .foregroundStyle(CrownTheme.ink.opacity(0.8))
                Spacer()
                Text(value.isEmpty ? "—" : value)
                    .foregroundStyle(CrownTheme.ink)
            }
        }
    }

    private struct PrivacyView: View {
        var body: some View {
            ZStack {
                CrownBackground()

                ScrollView {
                    CrownPanel {
                        CrownSectionHeader(
                            title: "Privacy",
                            subtitle: "Data controls are gathered here so every rider keeps command of their visibility."
                        )
                        Text("Manage your privacy preferences and data visibility from this section.")
                            .foregroundStyle(CrownTheme.ink)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Privacy")
            .crownNavigationChrome()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(EventsViewModel())
}
