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
                        "Nessuna uscita",
                        systemImage: "road.lanes",
                        description: Text("Non sei ancora iscritto a nessun evento.")
                    )
                } else {
                    List {
                        if !upcomingTrips.isEmpty {
                            Section("Prossime Uscite") {
                                ForEach(upcomingTrips) { event in
                                    TripRowView(event: event)
                                }
                            }
                        }

                        if !pastTrips.isEmpty {
                            Section("Storico") {
                                ForEach(pastTrips) { event in
                                    TripRowView(event: event)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Le Mie Uscite")
            .task { await eventsVM.loadEvents() }
        }
    }
}

private struct TripRowView: View {
    let event: Event

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                Text(event.date.formatted(date: .long, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Label("\(event.participantCount)", systemImage: "person.3")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TripsView()
        .environmentObject(EventsViewModel())
}
