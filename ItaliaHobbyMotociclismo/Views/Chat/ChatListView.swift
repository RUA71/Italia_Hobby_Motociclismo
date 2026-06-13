import SwiftUI

/// Lists all events the user is subscribed to for chat access.
struct ChatListView: View {
    @EnvironmentObject var eventsVM: EventsViewModel
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                CrownBackground()

                Group {
                    if eventsVM.subscribedEvents.isEmpty {
                        ContentUnavailableView(
                            "No Events",
                            systemImage: "bubble.left.and.bubble.right",
                            description: Text("Subscribe to an event to access the chat.")
                        )
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                CrownHeroBanner(
                                    title: "Messenger Hall",
                                    subtitle: "Ride companions can speak here before, during and after every event.",
                                    symbol: "scroll.fill"
                                )

                                ForEach(eventsVM.subscribedEvents) { event in
                                    NavigationLink(destination: ChatRoomView(event: event).environmentObject(authVM)) {
                                        EventRowView(event: event)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 24)
                        }
                    }
                }
            }
            .navigationTitle("Chat")
            .task { await eventsVM.loadEvents(userId: authVM.currentUser?.id) }
            .crownNavigationChrome()
        }
    }
}

/// A compact row representing an event in the chat list.
struct EventRowView: View {
    let event: Event

    var body: some View {
        CrownPanel(spacing: 10) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: event.isSubscribed ? "checkmark.shield.fill" : "crown.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(CrownTheme.crimson)
                    .frame(width: 46, height: 46)
                    .background(Circle().fill(CrownTheme.gold.opacity(0.24)))

                VStack(alignment: .leading, spacing: 6) {
                    Text(event.title)
                        .font(.system(.headline, design: .serif, weight: .bold))
                        .foregroundStyle(CrownTheme.ink)
                    Text(event.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(CrownTheme.ink.opacity(0.72))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(CrownTheme.bronze)
            }
        }
    }
}

#Preview {
    ChatListView()
        .environmentObject(EventsViewModel())
        .environmentObject(AuthViewModel())
}
