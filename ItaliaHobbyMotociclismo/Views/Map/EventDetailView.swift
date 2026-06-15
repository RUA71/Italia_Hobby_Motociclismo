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
                    List {
                        Section {
                            Map {
                                Annotation(event.title, coordinate: event.coordinate) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title)
                                        .foregroundStyle(.red)
                                }
                            }
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .listRowInsets(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
                        }

                        Section("Details") {
                            LabeledContent("Date", value: event.date.formatted(date: .long, time: .shortened))
                            LabeledContent("Participants", value: "\(event.participantCount)")
                        }

                        Section("Description") {
                            Text(event.description)
                                .foregroundStyle(.secondary)
                        }

                        Section {
                            subscribeButton(event: event)

                            if event.isSubscribed {
                                Button {
                                    showChat = true
                                } label: {
                                    Label("Open Chat", systemImage: "bubble.left.and.bubble.right")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(.init(top: 4, leading: 0, bottom: 4, trailing: 0))
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
                Label("Leave Event", systemImage: "minus.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        } else {
            Button {
                Task { await subscribe(event: event) }
            } label: {
                Label("Join Event", systemImage: "plus.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
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
