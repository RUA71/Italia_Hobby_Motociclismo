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
            ZStack {
                CrownBackground()

                Group {
                    if eventsVM.subscribedEvents.isEmpty {
                        ContentUnavailableView(
                            "No Trips",
                            systemImage: "road.lanes",
                            description: Text("You haven't joined any event yet.")
                        )
                    } else {
                        ScrollView {
                            VStack(spacing: 18) {
                                if !upcomingTrips.isEmpty {
                                    tripSection(title: "Upcoming Trips", trips: upcomingTrips)
                                }

                                if !pastTrips.isEmpty {
                                    tripSection(title: "History", trips: pastTrips)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 24)
                        }
                    }
                }
            }
            .navigationTitle("My Trips")
            .task { await eventsVM.loadEvents() }
            .crownNavigationChrome()
        }
    }

    private func tripSection(title: String, trips: [Event]) -> some View {
        CrownPanel {
            CrownSectionHeader(title: title)
            ForEach(Array(trips.enumerated()), id: \.element.id) { index, event in
                if index > 0 {
                    Divider().background(CrownTheme.gold.opacity(0.3))
                }
                TripRowView(event: event)
            }
        }
    }
}

private struct TripRowView: View {
    let event: Event

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(.headline, design: .serif, weight: .bold))
                    .foregroundStyle(CrownTheme.ink)
                Text(event.date.formatted(date: .long, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(CrownTheme.ink.opacity(0.72))
            }
            Spacer()
            Label("\(event.participantCount)", systemImage: "person.3")
                .font(.caption)
                .foregroundStyle(CrownTheme.bronze)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TripsView()
        .environmentObject(EventsViewModel())
}
