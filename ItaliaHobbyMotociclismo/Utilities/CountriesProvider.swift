import Foundation
import SwiftUI

/// Loads a local list of countries from the app bundle.
/// Falls back to a generated list from Locale if the resource is missing.
final class CountriesProvider {
    static let shared = CountriesProvider()

    private(set) var countries: [String] = []

    private init() {
        // Try loading a bundled JSON file `countries.json` first.
        if let url = Bundle.main.url(forResource: "countries", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let list = try? JSONDecoder().decode([String].self, from: data),
           !list.isEmpty {
            countries = list.sorted()
            return
        }

        // Fallback: generate a list from Locale (stable, local to device language).
        var generated: [String] = []
        for code in Locale.isoRegionCodes {
            let id = Locale.current.identifier
            let name = Locale(identifier: id).localizedString(forRegionCode: code) ?? code
            generated.append(name)
        }
        countries = Array(Set(generated)).sorted()
    }
}
