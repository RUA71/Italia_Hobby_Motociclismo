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
            ZStack {
                CrownBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        CrownPanel {
                            CrownSectionHeader(
                                title: "Personal Data",
                                subtitle: profileVM.isEditing ? "Update the details other riders will recognize." : "The rider information shown to the club."
                            )

                            if profileVM.isEditing {
                                editableField("Nickname", text: $profileVM.user.nickname)
                                editableField("First Name", text: $profileVM.user.name)
                                editableField("Last Name", text: $profileVM.user.surname)
                                editableField("City", text: $profileVM.user.city)
                                editableField("Country", text: $profileVM.user.country)
                            } else {
                                infoRow(label: "Nickname", value: profileVM.user.nickname)
                                infoRow(label: "First Name", value: profileVM.user.name)
                                infoRow(label: "Last Name", value: profileVM.user.surname)
                                infoRow(label: "City", value: profileVM.user.city)
                                infoRow(label: "Country", value: profileVM.user.country)
                            }
                        }

                        CrownPanel {
                            CrownSectionHeader(
                                title: "Your Motorcycle",
                                subtitle: "Keep your bike details current for future rides."
                            )

                            if profileVM.isEditing {
                                editableField("Brand", text: $profileVM.user.motorbikeBrand)
                                editableField("Model", text: $profileVM.user.motorbikeModel)
                                editableField("Type", text: $profileVM.user.motorbikeType)
                            } else {
                                infoRow(label: "Brand", value: profileVM.user.motorbikeBrand)
                                infoRow(label: "Model", value: profileVM.user.motorbikeModel)
                                infoRow(label: "Type", value: profileVM.user.motorbikeType)
                            }
                        }

                        Button(role: .destructive) {
                            showLogoutAlert = true
                        } label: {
                            Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                        .buttonStyle(CrownSecondaryButtonStyle(foreground: CrownTheme.parchment, background: CrownTheme.crimson))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }

                if profileVM.isSaving {
                    CrownPanel(alignment: .center, spacing: 12) {
                        ProgressView("Saving…")
                            .tint(CrownTheme.crimson)
                        Text("Updating your rider record")
                            .font(.system(.headline, design: .serif, weight: .bold))
                            .foregroundStyle(CrownTheme.ink)
                    }
                    .padding(.horizontal, 36)
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
            .crownNavigationChrome()
        }
    }

    private var profileErrorBinding: Binding<Bool> {
        Binding(
            get: { profileVM.errorMessage != nil },
            set: { if !$0 { profileVM.errorMessage = nil } }
        )
    }

    private func editableField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(.subheadline, design: .serif, weight: .semibold))
                .foregroundStyle(CrownTheme.ink.opacity(0.78))
            TextField(label, text: text)
                .textInputAutocapitalization(.words)
                .crownTextField()
        }
    }

    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(.headline, design: .serif, weight: .semibold))
                .foregroundStyle(CrownTheme.ink.opacity(0.8))
            Spacer()
            Text(value.isEmpty ? "—" : value)
                .foregroundStyle(CrownTheme.ink)
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
