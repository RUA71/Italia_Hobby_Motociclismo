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
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .navigationTitle("Mappa Eventi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if eventsVM.isLoading {
                        ProgressView()
                    }
                }
            }
            .task { await eventsVM.loadEvents() }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(event: event)
                    .environmentObject(eventsVM)
                    .environmentObject(authVM)
            }
            .alert("Errore", isPresented: errorBinding) {
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
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(event.isSubscribed ? Color.green : Color.orange)
                    .frame(width: 36, height: 36)
                Image(systemName: event.isSubscribed ? "checkmark.circle.fill" : "motorcycle")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
            }
            Image(systemName: "triangle.fill")
                .foregroundColor(event.isSubscribed ? .green : .orange)
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
