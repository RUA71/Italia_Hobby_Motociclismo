import SwiftUI

enum CrownTheme {
    static let midnight = Color(red: 18.0 / 255.0, green: 30.0 / 255.0, blue: 56.0 / 255.0)
    static let midnightAccent = Color(red: 29.0 / 255.0, green: 46.0 / 255.0, blue: 84.0 / 255.0)
    static let gold = Color(red: 205.0 / 255.0, green: 170.0 / 255.0, blue: 92.0 / 255.0)
    static let bronze = Color(red: 121.0 / 255.0, green: 73.0 / 255.0, blue: 38.0 / 255.0)
    static let parchment = Color(red: 236.0 / 255.0, green: 220.0 / 255.0, blue: 188.0 / 255.0)
    static let parchmentShade = Color(red: 214.0 / 255.0, green: 191.0 / 255.0, blue: 150.0 / 255.0)
    static let ink = Color(red: 61.0 / 255.0, green: 39.0 / 255.0, blue: 24.0 / 255.0)
    static let crimson = Color(red: 121.0 / 255.0, green: 27.0 / 255.0, blue: 35.0 / 255.0)
    static let emerald = Color(red: 67.0 / 255.0, green: 115.0 / 255.0, blue: 73.0 / 255.0)
}

struct CrownBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [CrownTheme.midnight, CrownTheme.midnightAccent, .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [CrownTheme.gold.opacity(0.22), .clear],
                center: .top,
                startRadius: 30,
                endRadius: 420
            )
            .ignoresSafeArea()

            VStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [CrownTheme.gold.opacity(0.45), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 140)
                Spacer()
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, CrownTheme.crimson.opacity(0.25)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 180)
            }
            .ignoresSafeArea()
        }
    }
}

struct CrownPanel<Content: View>: View {
    private let alignment: HorizontalAlignment
    private let spacing: CGFloat
    private let content: Content

    init(
        alignment: HorizontalAlignment = .leading,
        spacing: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [CrownTheme.parchment, CrownTheme.parchmentShade],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(CrownTheme.gold.opacity(0.85), lineWidth: 2)
        )
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: 2)
                .fill(CrownTheme.gold.opacity(0.9))
                .frame(width: 72, height: 4)
                .padding(.top, 10)
        }
        .shadow(color: .black.opacity(0.24), radius: 18, y: 10)
    }
}

struct CrownSectionHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(.title3, design: .serif, weight: .bold))
                .foregroundStyle(CrownTheme.ink)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(CrownTheme.ink.opacity(0.75))
            }
        }
    }
}

struct CrownHeroBanner: View {
    let title: String
    let subtitle: String
    let symbol: String

    var body: some View {
        CrownPanel(spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(CrownTheme.crimson)
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(CrownTheme.gold.opacity(0.3)))

                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(.largeTitle, design: .serif, weight: .bold))
                        .foregroundStyle(CrownTheme.ink)
                    Text(subtitle)
                        .font(.body)
                        .foregroundStyle(CrownTheme.ink.opacity(0.82))
                }
            }
        }
    }
}

struct CrownPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .serif, weight: .bold))
            .foregroundStyle(CrownTheme.midnight)
            .padding(.vertical, 14)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [CrownTheme.gold, CrownTheme.parchment],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(CrownTheme.bronze, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.18), radius: 10, y: 6)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
    }
}

struct CrownSecondaryButtonStyle: ButtonStyle {
    let foreground: Color
    let background: Color

    init(
        foreground: Color = CrownTheme.gold,
        background: Color = CrownTheme.midnight.opacity(0.72)
    ) {
        self.foreground = foreground
        self.background = background
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .serif, weight: .semibold))
            .foregroundStyle(foreground)
            .padding(.vertical, 13)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(foreground.opacity(0.8), lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

struct CrownTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.72))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(CrownTheme.gold.opacity(0.75), lineWidth: 1.5)
            )
            .foregroundStyle(CrownTheme.ink)
            .tint(CrownTheme.crimson)
    }
}

extension View {
    func crownTextField() -> some View {
        modifier(CrownTextFieldModifier())
    }

    func crownNavigationChrome() -> some View {
        toolbarBackground(CrownTheme.midnight.opacity(0.94), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }

    func crownTabChrome() -> some View {
        toolbarBackground(CrownTheme.midnight.opacity(0.98), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)
    }
}
