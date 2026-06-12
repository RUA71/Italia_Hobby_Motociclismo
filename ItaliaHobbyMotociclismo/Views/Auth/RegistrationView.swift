import SwiftUI

/// Registration screen shown to new users on first launch.
struct RegistrationView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var nickname      = ""
    @State private var name          = ""
    @State private var surname       = ""
    @State private var city          = ""
    @State private var country       = ""
    @State private var motorbikeBrand = ""
    @State private var motorbikeModel = ""
    @State private var motorbikeType  = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Data") {
                    TextField("Nickname *", text: $nickname)
                        .autocorrectionDisabled()
                    TextField("First Name", text: $name)
                    TextField("Last Name", text: $surname)
                    TextField("City *", text: $city)
                    TextField("Country *", text: $country)
                }

                Section("Motorcycle") {
                    TextField("Brand *", text: $motorbikeBrand)
                    TextField("Model *", text: $motorbikeModel)
                    TextField("Type", text: $motorbikeType)
                }

                Section {
                    Button(action: register) {
                        HStack {
                            Spacer()
                            if authVM.isLoading {
                                ProgressView()
                            } else {
                                Text("Sign Up")
                                    .bold()
                            }
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid || authVM.isLoading)
                }
            }
            .navigationTitle("Welcome!")
            .navigationBarTitleDisplayMode(.large)
            .alert("Error", isPresented: errorBinding) {
                Button("OK", role: .cancel) { authVM.errorMessage = nil }
            } message: {
                Text(authVM.errorMessage ?? "")
            }
        }
    }

    // MARK: - Helpers

    private var isFormValid: Bool {
        !nickname.isEmpty && !city.isEmpty && !country.isEmpty &&
        !motorbikeBrand.isEmpty && !motorbikeModel.isEmpty
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { authVM.errorMessage != nil },
            set: { if !$0 { authVM.errorMessage = nil } }
        )
    }

    private func register() {
        Task {
            await authVM.register(
                nickname:       nickname,
                name:           name,
                surname:        surname,
                city:           city,
                country:        country,
                motorbikeBrand: motorbikeBrand,
                motorbikeModel: motorbikeModel,
                motorbikeType:  motorbikeType
            )
        }
    }
}

#Preview {
    RegistrationView()
        .environmentObject(AuthViewModel())
}
