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
            ZStack {
                CrownBackground()

                Group {
                    if let event {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 18) {
                                CrownPanel(spacing: 14) {
                                    CrownSectionHeader(
                                        title: event.title,
                                        subtitle: "Gather your companions and ride under the club banner."
                                    )

                                    Map {
                                        Annotation(event.title, coordinate: event.coordinate) {
                                            Image(systemName: "crown.fill")
                                                .font(.title2)
                                                .foregroundColor(CrownTheme.crimson)
                                        }
                                    }
                                    .frame(height: 210)
                                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .stroke(CrownTheme.gold.opacity(0.8), lineWidth: 2)
                                    )
                                }

                                CrownPanel {
                                    detailRow(systemImage: "calendar", value: event.date.formatted(date: .long, time: .shortened))
                                    detailRow(systemImage: "person.3", value: String(format: String(localized: "%d participants"), event.participantCount))

                                    Divider().background(CrownTheme.gold.opacity(0.35))

                                    Text(event.description)
                                        .foregroundStyle(CrownTheme.ink)
                                }

                                CrownPanel {
                                    subscribeButton(event: event)

                                    if event.isSubscribed {
                                        Button {
                                            showChat = true
                                        } label: {
                                            Label("Open Chat", systemImage: "bubble.left.and.bubble.right")
                                        }
                                        .buttonStyle(CrownSecondaryButtonStyle())
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 24)
                        }
                    } else {
                        ContentUnavailableView("Event Not Found", systemImage: "magnifyingglass")
                    }
                }
            }
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(CrownTheme.gold)
                }
            }
            .navigationDestination(isPresented: $showChat) {
                if let event {
                    ChatRoomView(event: event)
                        .environmentObject(authVM)
                }
            }
            .crownNavigationChrome()
        }
    }

    private func detailRow(systemImage: String, value: String) -> some View {
        Label {
            Text(value)
                .foregroundStyle(CrownTheme.ink)
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(CrownTheme.crimson)
        }
    }

    @ViewBuilder
    private func subscribeButton(event: Event) -> some View {
        if event.isSubscribed {
            Button(role: .destructive) {
                Task { await unsubscribe(event: event) }
            } label: {
                Label("Withdraw from Ride", systemImage: "minus.circle")
            }
            .buttonStyle(CrownSecondaryButtonStyle(foreground: CrownTheme.parchment, background: CrownTheme.crimson))
        } else {
            Button {
                Task { await subscribe(event: event) }
            } label: {
                Label("Join the Ride", systemImage: "plus.circle")
            }
            .buttonStyle(CrownPrimaryButtonStyle())
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
