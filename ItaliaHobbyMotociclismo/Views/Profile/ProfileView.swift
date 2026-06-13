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
                Section("Personal Data") {
                    if profileVM.isEditing {
                        TextField("Nickname", text: $profileVM.user.nickname)
                        TextField("First Name", text: $profileVM.user.name)
                        TextField("Last Name", text: $profileVM.user.surname)
                        TextField("City", text: $profileVM.user.city)
                        TextField("Country", text: $profileVM.user.country)
                    } else {
                        infoRow(label: "Nickname", value: profileVM.user.nickname)
                        infoRow(label: "First Name", value: profileVM.user.name)
                        infoRow(label: "Last Name", value: profileVM.user.surname)
                        infoRow(label: "City", value: profileVM.user.city)
                        infoRow(label: "Country", value: profileVM.user.country)
                    }
                }

                Section("Your Motorcycle") {
                    if profileVM.isEditing {
                        TextField("Brand", text: $profileVM.user.motorbikeBrand)
                        TextField("Model", text: $profileVM.user.motorbikeModel)
                        TextField("Type", text: $profileVM.user.motorbikeType)
                    } else {
                        infoRow(label: "Brand", value: profileVM.user.motorbikeBrand)
                        infoRow(label: "Model", value: profileVM.user.motorbikeModel)
                        infoRow(label: "Type", value: profileVM.user.motorbikeType)
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
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if profileVM.isEditing {
                        Button("Save") {
                            Task { await profileVM.saveProfile() }
                        }
                        .disabled(profileVM.isSaving)
                    } else {
                        Button("Edit") {
                            profileVM.isEditing = true
                        }
                    }
                }
                if profileVM.isEditing {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            profileVM.isEditing = false
                        }
                    }
                }
            }
            .overlay {
                if profileVM.isSaving {
                    ProgressView("Saving…")
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(12)
                }
            }
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Sign Out", role: .destructive) { authVM.logout() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Warning", isPresented: profileErrorBinding) {
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
