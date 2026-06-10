import SwiftUI

@main
struct ItaliaHobbyMotociclismoApp: App {
    @StateObject private var authVM    = AuthViewModel()
    @StateObject private var eventsVM  = EventsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
                .environmentObject(eventsVM)
        }
    }
}
