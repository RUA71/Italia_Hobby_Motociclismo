import SwiftUI

/// Registration screen shown to new users on first launch.
struct RegistrationView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var nickname = ""
    @State private var name = ""
    @State private var surname = ""
    @State private var city = ""
    @State private var country = ""
    @State private var motorbikeBrand = ""
    @State private var motorbikeModel = ""
    @State private var motorbikeType = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Data") {
                    TextField("Nickname *", text: $nickname)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                    TextField("First Name", text: $name)
                        .textInputAutocapitalization(.words)
                    TextField("Last Name", text: $surname)
                        .textInputAutocapitalization(.words)
                    TextField("City *", text: $city)
                        .textInputAutocapitalization(.words)
                    TextField("Country *", text: $country)
                        .textInputAutocapitalization(.words)
                }

                Section("Motorcycle") {
                    TextField("Brand *", text: $motorbikeBrand)
                        .textInputAutocapitalization(.words)
                    TextField("Model *", text: $motorbikeModel)
                        .textInputAutocapitalization(.words)
                    TextField("Type", text: $motorbikeType)
                        .textInputAutocapitalization(.words)
                }

                Section {
                    Button(action: register) {
                        if authVM.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Register")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isFormValid || authVM.isLoading)
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: errorBinding) {
                Button("OK", role: .cancel) { authVM.errorMessage = nil }
            } message: {
                Text(authVM.errorMessage ?? "")
            }
        }
    }

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
                nickname: nickname,
                name: name,
                surname: surname,
                city: city,
                country: country,
                motorbikeBrand: motorbikeBrand,
                motorbikeModel: motorbikeModel,
                motorbikeType: motorbikeType
            )
        }
    }
}

#Preview {
    RegistrationView()
        .environmentObject(AuthViewModel())
}
