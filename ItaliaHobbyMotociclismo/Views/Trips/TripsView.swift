import SwiftUI

/// Shows all events the user has joined, grouped into upcoming and past.
struct TripsView: View {
    @EnvironmentObject var eventsVM: EventsViewModel

    private var upcomingTrips: [Event] {
        eventsVM.subscribedEvents
            .filter { $0.date >= Date() }
            .sorted { $0.date < $1.date }
    }

    private var pastTrips: [Event] {
        eventsVM.subscribedEvents
            .filter { $0.date < Date() }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            Group {
                if eventsVM.subscribedEvents.isEmpty {
                    ContentUnavailableView(
                        "No Trips",
                        systemImage: "road.lanes",
                        description: Text("You haven't joined any event yet.")
                    )
                } else {
                    List {
                        if !upcomingTrips.isEmpty {
                            Section("Upcoming Trips") {
                                ForEach(upcomingTrips) { event in
                                    TripRowView(event: event)
                                }
                            }
                        }
                        if !pastTrips.isEmpty {
                            Section("History") {
                                ForEach(pastTrips) { event in
                                    TripRowView(event: event)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Trips")
            .task { await eventsVM.loadEvents() }
        }
    }
}

private struct TripRowView: View {
    let event: Event

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                Text(event.date.formatted(date: .long, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Label("\(event.participantCount)", systemImage: "person.3")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    TripsView()
        .environmentObject(EventsViewModel())
}
