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
                Section("Dati Personali") {
                    TextField("Nickname *", text: $nickname)
                        .autocorrectionDisabled()
                    TextField("Nome", text: $name)
                    TextField("Cognome", text: $surname)
                    TextField("Città *", text: $city)
                    TextField("Nazione *", text: $country)
                }

                Section("Moto") {
                    TextField("Marca *", text: $motorbikeBrand)
                    TextField("Modello *", text: $motorbikeModel)
                    TextField("Tipo", text: $motorbikeType)
                }

                Section {
                    Button(action: register) {
                        HStack {
                            Spacer()
                            if authVM.isLoading {
                                ProgressView()
                            } else {
                                Text("Registrati")
                                    .bold()
                            }
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid || authVM.isLoading)
                }
            }
            .navigationTitle("Benvenuto!")
            .navigationBarTitleDisplayMode(.large)
            .alert("Errore", isPresented: errorBinding) {
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
