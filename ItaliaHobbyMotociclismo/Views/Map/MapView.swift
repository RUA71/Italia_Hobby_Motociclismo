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
            Map(position: $cameraPosition) {
                ForEach(eventsVM.events) { event in
                    Annotation(event.title, coordinate: event.coordinate) {
                        EventAnnotationView(event: event)
                            .onTapGesture { selectedEvent = event }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Label("\(eventsVM.events.count) Events", systemImage: "calendar")
                    Spacer()
                    Label("\(eventsVM.subscribedEvents.count) Joined", systemImage: "checkmark.circle")
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.regularMaterial)
            }
            .navigationTitle("Events Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if eventsVM.isLoading {
                        ProgressView()
                    }
                }
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
        }
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
        Image(systemName: event.isSubscribed ? "checkmark.circle.fill" : "mappin.circle.fill")
            .font(.title)
            .foregroundStyle(event.isSubscribed ? .green : .red)
            .background(Circle().fill(.white).padding(4))
    }
}

#Preview {
    MapView()
        .environmentObject(EventsViewModel())
        .environmentObject(AuthViewModel())
}
