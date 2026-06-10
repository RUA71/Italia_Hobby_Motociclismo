import SwiftUI

/// Lists all events the user is subscribed to for chat access.
struct ChatListView: View {
    @EnvironmentObject var eventsVM: EventsViewModel
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationStack {
            Group {
                if eventsVM.subscribedEvents.isEmpty {
                    ContentUnavailableView(
                        "Nessun evento",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("Iscriviti a un evento per accedere alla chat.")
                    )
                } else {
                    List(eventsVM.subscribedEvents) { event in
                        NavigationLink(destination: ChatRoomView(event: event)
                            .environmentObject(authVM)
                        ) {
                            EventRowView(event: event)
                        }
                    }
                }
            }
            .navigationTitle("Chat")
            .task { await eventsVM.loadEvents(userId: authVM.currentUser?.id) }
        }
    }
}

/// A compact row representing an event in the chat list.
struct EventRowView: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.title)
                .font(.headline)
            Text(event.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ChatListView()
        .environmentObject(EventsViewModel())
        .environmentObject(AuthViewModel())
}
