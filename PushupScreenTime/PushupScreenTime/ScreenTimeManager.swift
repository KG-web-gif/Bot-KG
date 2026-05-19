import FamilyControls
import ManagedSettings
import Foundation

@MainActor
class ScreenTimeManager: ObservableObject {
    private let store = ManagedSettingsStore()

    @Published var isAuthorized = false
    @Published var selection: FamilyActivitySelection {
        didSet { persist() }
    }

    init() {
        self.selection = Self.load()
        Task { await refreshAuthStatus() }
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = true
        } catch {
            isAuthorized = false
        }
    }

    func lockApps() {
        guard isAuthorized else { return }
        let apps = selection.applicationTokens
        let cats = selection.categoryTokens
        store.shield.applications = apps.isEmpty ? nil : apps
        store.shield.applicationCategories = cats.isEmpty ? nil : .specific(cats)
    }

    func unlockApps() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }

    private func refreshAuthStatus() async {
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
    }

    private func persist() {
        let data = try? JSONEncoder().encode(selection)
        UserDefaults.standard.set(data, forKey: "selectedApps")
    }

    private static func load() -> FamilyActivitySelection {
        guard
            let data = UserDefaults.standard.data(forKey: "selectedApps"),
            let sel  = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else { return FamilyActivitySelection() }
        return sel
    }
}
