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
                        "No Events",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("Subscribe to an event to access the chat.")
                    )
                } else {
                    List(eventsVM.subscribedEvents) { event in
                        NavigationLink(destination: ChatRoomView(event: event).environmentObject(authVM)) {
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
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: event.isSubscribed ? "checkmark.circle.fill" : "calendar")
                .font(.title2)
                .foregroundStyle(event.isSubscribed ? .green : .accentColor)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color(.tertiarySystemFill)))

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                Text(event.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ChatListView()
        .environmentObject(EventsViewModel())
        .environmentObject(AuthViewModel())
}
