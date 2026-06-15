import SwiftUI

/// Full-screen splash that is shown at launch until remote data has been
/// fetched (or 5 seconds have elapsed, whichever comes first).
struct SplashScreenView: View {
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var spinnerOpacity: Double = 0

    var body: some View {
        ZStack {
            CrownBackground()

            VStack(spacing: 0) {
                Spacer()

                // ── Crown emblem ──────────────────────────────────────────
                ZStack {
                    Circle()
                        .fill(CrownTheme.gold.opacity(0.18))
                        .frame(width: 160, height: 160)

                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [CrownTheme.gold, CrownTheme.bronze],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 160, height: 160)

                    Image(systemName: "crown.fill")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [CrownTheme.gold, CrownTheme.bronze],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: CrownTheme.gold.opacity(0.55), radius: 18)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // ── App title ─────────────────────────────────────────────
                VStack(spacing: 8) {
                    Text("Italia Hobby")
                        .font(.system(.largeTitle, design: .serif, weight: .bold))
                        .foregroundStyle(CrownTheme.gold)
                        .tracking(2)

                    Text("Motociclismo")
                        .font(.system(.title2, design: .serif, weight: .semibold))
                        .foregroundStyle(CrownTheme.parchment)
                        .tracking(4)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, CrownTheme.gold, .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .padding(.horizontal, 48)
                        .padding(.top, 6)

                    Text("The Italian Riders' Brotherhood")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(CrownTheme.parchment.opacity(0.75))
                        .italic()
                        .padding(.top, 4)
                }
                .opacity(subtitleOpacity)
                .padding(.top, 28)

                Spacer()

                // ── Loading indicator ─────────────────────────────────────
                VStack(spacing: 10) {
                    ProgressView()
                        .tint(CrownTheme.gold)
                        .scaleEffect(1.1)

                    Text("Entering the realm…")
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(CrownTheme.parchment.opacity(0.65))
                }
                .opacity(spinnerOpacity)
                .padding(.bottom, 52)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.9).delay(0.35)) {
                subtitleOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.5).delay(0.7)) {
                spinnerOpacity = 1.0
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
