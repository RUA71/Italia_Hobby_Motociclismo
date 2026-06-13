import SwiftUI
import MapKit

/// Displays all club events on a map with annotations.
struct MapView: View {
    @EnvironmentObject var eventsVM: EventsViewModel
    @EnvironmentObject var authVM: AuthViewModel

    @State private var selectedEvent: Event?
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            ZStack {
                CrownBackground()

                Map(position: $cameraPosition) {
                    ForEach(eventsVM.events) { event in
                        Annotation(event.title, coordinate: event.coordinate) {
                            EventAnnotationView(event: event)
                                .onTapGesture { selectedEvent = event }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(CrownTheme.gold.opacity(0.85), lineWidth: 2)
                )
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 120)
                .shadow(color: CrownTheme.shadow, radius: 18, y: 10)
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
            }
            .navigationTitle("Events Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if eventsVM.isLoading {
                        ProgressView()
                            .tint(CrownTheme.gold)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                CrownPanel(spacing: 10) {
                    Text("Royal Route Ledger")
                        .font(.system(.headline, design: .serif, weight: .bold))
                        .foregroundStyle(CrownTheme.ink)
                    HStack {
                        labelPill(title: "Events", value: "\(eventsVM.events.count)", fill: CrownTheme.gold.opacity(0.28))
                        labelPill(title: "Joined", value: "\(eventsVM.subscribedEvents.count)", fill: CrownTheme.emerald.opacity(0.25))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .task { await eventsVM.loadEvents(userId: authVM.currentUser?.id) }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(event: event)
                    .environmentObject(eventsVM)
                    .environmentObject(authVM)
            }
            .alert("Error", isPresented: errorBinding) {
                Button("OK", role: .cancel) { eventsVM.errorMessage = nil }
            } message: {
                Text(eventsVM.errorMessage ?? "")
            }
            .crownNavigationChrome()
        }
    }

    private func labelPill(title: String, value: String, fill: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(CrownTheme.ink.opacity(0.7))
            Text(value)
                .font(.system(.title3, design: .serif, weight: .bold))
                .foregroundStyle(CrownTheme.ink)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(fill)
        )
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { eventsVM.errorMessage != nil },
            set: { if !$0 { eventsVM.errorMessage = nil } }
        )
    }
}

/// Custom annotation callout for a map pin.
private struct EventAnnotationView: View {
    let event: Event

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(event.isSubscribed ? CrownTheme.emerald : CrownTheme.crimson)
                    .frame(width: 40, height: 40)
                Circle()
                    .stroke(CrownTheme.gold, lineWidth: 2)
                    .frame(width: 40, height: 40)
                Image(systemName: event.isSubscribed ? "checkmark.shield.fill" : "crown.fill")
                    .foregroundColor(CrownTheme.parchment)
                    .font(.system(size: 18))
            }
            Image(systemName: "triangle.fill")
                .foregroundColor(event.isSubscribed ? CrownTheme.emerald : CrownTheme.crimson)
                .font(.system(size: 10))
                .rotationEffect(.degrees(180))
                .offset(y: -2)
        }
    }
}

#Preview {
    MapView()
        .environmentObject(EventsViewModel())
        .environmentObject(AuthViewModel())
}
