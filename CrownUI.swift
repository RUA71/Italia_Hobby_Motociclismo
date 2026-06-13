// CrownUI.swift
//
// Basic replacement for missing CrownUI components to compile and provide medieval look.

import SwiftUI

// MARK: - CrownTheme

struct CrownTheme {
    static let gold      = Color(red: 0.98, green: 0.84, blue: 0.37)
    static let crimson   = Color(red: 0.60, green: 0.08, blue: 0.19)
    static let parchment = Color(red: 0.98, green: 0.95, blue: 0.88)
    static let ink       = Color(red: 0.16, green: 0.13, blue: 0.10)
    static let bronze    = Color(red: 0.75, green: 0.48, blue: 0.23)
    static let emerald   = Color(red: 0.13, green: 0.55, blue: 0.31)
    static let midnight  = Color(red: 0.10, green: 0.12, blue: 0.20)
    static let shadow    = Color.black.opacity(0.25)
}

// MARK: - CrownBackground

struct CrownBackground: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [CrownTheme.midnight, CrownTheme.crimson.opacity(0.46), CrownTheme.gold.opacity(0.32)]),
                       startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}

// MARK: - CrownPanel

struct CrownPanel<Content: View>: View {
    var alignment: HorizontalAlignment = .leading
    var spacing: CGFloat = 16
    let content: () -> Content

    init(alignment: HorizontalAlignment = .leading, spacing: CGFloat = 16, @ViewBuilder content: @escaping () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            content()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(CrownTheme.parchment.opacity(0.92))
                .shadow(color: CrownTheme.shadow, radius: 10, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(CrownTheme.gold, lineWidth: 2.2)
        )
    }
}

// MARK: - CrownPrimaryButtonStyle

struct CrownPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .serif, weight: .bold))
            .foregroundColor(CrownTheme.parchment)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(CrownTheme.crimson)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(CrownTheme.gold.opacity(0.8), lineWidth: 1.4)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.82 : 1.0)
    }
}

// MARK: - crownNavigationChrome

extension View {
    func crownNavigationChrome() -> some View {
        self
            .toolbarBackground(CrownTheme.midnight, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
