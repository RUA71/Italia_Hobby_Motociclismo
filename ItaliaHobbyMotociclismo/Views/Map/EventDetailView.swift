import SwiftUI
import MapKit

/// Detailed view for a single event with subscription controls and chat access.
struct EventDetailView: View {
    @EnvironmentObject var eventsVM: EventsViewModel
    @EnvironmentObject var authVM: AuthViewModel

    /// The event is looked up from the view model by ID each render cycle
    /// so that subscription state updates (from subscribe/unsubscribe calls) are
    /// automatically reflected without needing a separate binding.
    var eventId: String
    @Environment(\.dismiss) private var dismiss

    private var event: Event? {
        eventsVM.events.first { $0.id == eventId }
    }

    @State private var showChat = false

    init(event: Event) {
        self.eventId = event.id
    }

    var body: some View {
        NavigationStack {
            Group {
                if let event {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Mini map
                            Map {
                                Annotation(event.title, coordinate: event.coordinate) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.red)
                                }
                            }
                            .frame(height: 180)
                            .cornerRadius(12)
                            .padding(.horizontal)

                            // Details
                            VStack(alignment: .leading, spacing: 8) {
                                Text(event.title)
                                    .font(.title2.bold())

                                Label(
                                    event.date.formatted(date: .long, time: .shortened),
                                    systemImage: "calendar"
                                )
                                .foregroundColor(.secondary)

                                Label(
                                    String(format: String(localized: "%d participants"), event.participantCount),
                                    systemImage: "person.3"
                                )
                                .foregroundColor(.secondary)

                                Divider()

                                Text(event.description)
                                    .font(.body)
                            }
                            .padding(.horizontal)

                            // Action buttons
                            VStack(spacing: 12) {
                                subscribeButton(event: event)

                                if event.isSubscribed {
                                    Button {
                                        showChat = true
                                    } label: {
                                        Label("Open Chat", systemImage: "bubble.left.and.bubble.right")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.blue)
                                }
                            }
                            .padding()
                        }
                    }
                } else {
                    ContentUnavailableView("Event Not Found", systemImage: "magnifyingglass")
                }
            }
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .navigationDestination(isPresented: $showChat) {
                if let event {
                    ChatRoomView(event: event)
                        .environmentObject(authVM)
                }
            }
        }
    }

    @ViewBuilder
    private func subscribeButton(event: Event) -> some View {
        if event.isSubscribed {
            Button(role: .destructive) {
                Task { await unsubscribe(event: event) }
            } label: {
                Label("Unsubscribe", systemImage: "minus.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.red)
        } else {
            Button {
                Task { await subscribe(event: event) }
            } label: {
                Label("Subscribe", systemImage: "plus.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
    }

    private func subscribe(event: Event) async {
        guard let userId = authVM.currentUser?.id else { return }
        await eventsVM.subscribe(to: event, userId: userId)
    }

    private func unsubscribe(event: Event) async {
        guard let userId = authVM.currentUser?.id else { return }
        await eventsVM.unsubscribe(from: event, userId: userId)
    }
}
