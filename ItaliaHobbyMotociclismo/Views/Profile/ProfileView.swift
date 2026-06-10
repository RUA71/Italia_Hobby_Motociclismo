import SwiftUI

/// User profile screen with edit and logout capabilities.
struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var profileVM: ProfileViewModel
    @State private var showLogoutAlert = false

    init(user: User) {
        _profileVM = StateObject(wrappedValue: ProfileViewModel(user: user))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Dati Personali") {
                    if profileVM.isEditing {
                        TextField("Nickname", text: $profileVM.user.nickname)
                        TextField("Nome", text: $profileVM.user.name)
                        TextField("Cognome", text: $profileVM.user.surname)
                        TextField("Città", text: $profileVM.user.city)
                        TextField("Nazione", text: $profileVM.user.country)
                    } else {
                        infoRow(label: "Nickname", value: profileVM.user.nickname)
                        infoRow(label: "Nome", value: profileVM.user.name)
                        infoRow(label: "Cognome", value: profileVM.user.surname)
                        infoRow(label: "Città", value: profileVM.user.city)
                        infoRow(label: "Nazione", value: profileVM.user.country)
                    }
                }

                Section("La Tua Moto") {
                    if profileVM.isEditing {
                        TextField("Marca", text: $profileVM.user.motorbikeBrand)
                        TextField("Modello", text: $profileVM.user.motorbikeModel)
                        TextField("Tipo", text: $profileVM.user.motorbikeType)
                    } else {
                        infoRow(label: "Marca", value: profileVM.user.motorbikeBrand)
                        infoRow(label: "Modello", value: profileVM.user.motorbikeModel)
                        infoRow(label: "Tipo", value: profileVM.user.motorbikeType)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profilo")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if profileVM.isEditing {
                        Button("Salva") {
                            Task { await profileVM.saveProfile() }
                        }
                        .disabled(profileVM.isSaving)
                    } else {
                        Button("Modifica") {
                            profileVM.isEditing = true
                        }
                    }
                }
                if profileVM.isEditing {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Annulla") {
                            profileVM.isEditing = false
                        }
                    }
                }
            }
            .overlay {
                if profileVM.isSaving {
                    ProgressView("Salvataggio…")
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(12)
                }
            }
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Esci", role: .destructive) { authVM.logout() }
                Button("Annulla", role: .cancel) {}
            } message: {
                Text("Sei sicuro di voler uscire?")
            }
            .alert("Avviso", isPresented: profileErrorBinding) {
                Button("OK", role: .cancel) { profileVM.errorMessage = nil }
            } message: {
                Text(profileVM.errorMessage ?? "")
            }
        }
    }

    private var profileErrorBinding: Binding<Bool> {
        Binding(
            get: { profileVM.errorMessage != nil },
            set: { if !$0 { profileVM.errorMessage = nil } }
        )
    }

    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value.isEmpty ? "—" : value)
        }
    }
}

#Preview {
    ProfileView(user: User(
        id: "1",
        nickname: "MotoRider",
        name: "Mario",
        surname: "Rossi",
        city: "Roma",
        country: "Italia",
        motorbikeBrand: "Ducati",
        motorbikeModel: "Panigale V4",
        motorbikeType: "Sport"
    ))
    .environmentObject(AuthViewModel())
}
