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
        Form {
            Section("Personal Data") {
                if profileVM.isEditing {
                    TextField("Nickname", text: $profileVM.user.nickname)
                        .textInputAutocapitalization(.words)
                    TextField("First Name", text: $profileVM.user.name)
                        .textInputAutocapitalization(.words)
                    TextField("Last Name", text: $profileVM.user.surname)
                        .textInputAutocapitalization(.words)
                    TextField("City", text: $profileVM.user.city)
                        .textInputAutocapitalization(.words)
                    TextField("Country", text: $profileVM.user.country)
                        .textInputAutocapitalization(.words)
                } else {
                    LabeledContent("Nickname", value: profileVM.user.nickname.isEmpty ? "—" : profileVM.user.nickname)
                    LabeledContent("First Name", value: profileVM.user.name.isEmpty ? "—" : profileVM.user.name)
                    LabeledContent("Last Name", value: profileVM.user.surname.isEmpty ? "—" : profileVM.user.surname)
                    LabeledContent("City", value: profileVM.user.city.isEmpty ? "—" : profileVM.user.city)
                    LabeledContent("Country", value: profileVM.user.country.isEmpty ? "—" : profileVM.user.country)
                }
            }

            Section("Your Motorcycle") {
                if profileVM.isEditing {
                    TextField("Brand", text: $profileVM.user.motorbikeBrand)
                        .textInputAutocapitalization(.words)
                    TextField("Model", text: $profileVM.user.motorbikeModel)
                        .textInputAutocapitalization(.words)
                    TextField("Type", text: $profileVM.user.motorbikeType)
                        .textInputAutocapitalization(.words)
                } else {
                    LabeledContent("Brand", value: profileVM.user.motorbikeBrand.isEmpty ? "—" : profileVM.user.motorbikeBrand)
                    LabeledContent("Model", value: profileVM.user.motorbikeModel.isEmpty ? "—" : profileVM.user.motorbikeModel)
                    LabeledContent("Type", value: profileVM.user.motorbikeType.isEmpty ? "—" : profileVM.user.motorbikeType)
                }
            }

            Section {
                Button(role: .destructive) {
                    showLogoutAlert = true
                } label: {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
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
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
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

    private var profileErrorBinding: Binding<Bool> {
        Binding(
            get: { profileVM.errorMessage != nil },
            set: { if !$0 { profileVM.errorMessage = nil } }
        )
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
