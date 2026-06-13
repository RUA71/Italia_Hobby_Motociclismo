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
            ZStack {
                CrownBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        CrownHeroBanner(
                            title: "Welcome, Rider",
                            subtitle: "A Defender of the Crown inspired hall for joining the club and preparing your next journey.",
                            symbol: "crown.fill"
                        )

                        CrownPanel {
                            CrownSectionHeader(
                                title: "Personal Data",
                                subtitle: "Share the name you ride under and the land you call home."
                            )

                            textField("Nickname *", text: $nickname, disableAutocorrection: true)
                            textField("First Name", text: $name)
                            textField("Last Name", text: $surname)
                            textField("City *", text: $city)
                            textField("Country *", text: $country)
                        }

                        CrownPanel {
                            CrownSectionHeader(
                                title: "Motorcycle",
                                subtitle: "Tell the club which steed will join the procession."
                            )

                            textField("Brand *", text: $motorbikeBrand)
                            textField("Model *", text: $motorbikeModel)
                            textField("Type", text: $motorbikeType)
                        }

                        Button(action: register) {
                            if authVM.isLoading {
                                ProgressView()
                                    .tint(CrownTheme.midnight)
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Join the Court")
                            }
                        }
                        .buttonStyle(CrownPrimaryButtonStyle())
                        .disabled(!isFormValid || authVM.isLoading)
                        .opacity((!isFormValid || authVM.isLoading) ? 0.65 : 1)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
            .crownNavigationChrome()
            .alert("Error", isPresented: errorBinding) {
                Button("OK", role: .cancel) { authVM.errorMessage = nil }
            } message: {
                Text(authVM.errorMessage ?? "")
            }
        }
    }

    private func textField(_ title: String, text: Binding<String>, disableAutocorrection: Bool = false) -> some View {
        TextField(title, text: text)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled(disableAutocorrection)
            .crownTextField()
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
