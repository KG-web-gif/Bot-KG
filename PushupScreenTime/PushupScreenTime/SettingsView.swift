import SwiftUI
import FamilyControls

struct SettingsView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @EnvironmentObject var timeBankManager: TimeBankManager
    @Environment(\.dismiss) private var dismiss

    @State private var showAppPicker = false
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            List {
                Section("Locked Apps") {
                    Button("Change App Selection") { showAppPicker = true }
                    let appCount = screenTimeManager.selection.applicationTokens.count
                    let catCount = screenTimeManager.selection.categoryTokens.count
                    if appCount > 0 || catCount > 0 {
                        Text("\(appCount) app\(appCount == 1 ? "" : "s"), \(catCount) categor\(catCount == 1 ? "y" : "ies") selected")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Time Bank") {
                    HStack {
                        Text("Current balance")
                        Spacer()
                        Text("\(timeBankManager.remainingMinutes)m \(timeBankManager.remainingSecondsDisplay)s")
                            .foregroundStyle(.secondary)
                    }
                    Button("Reset Time Bank", role: .destructive) { showResetConfirm = true }
                }

                Section("About") {
                    HStack {
                        Text("Rate")
                        Spacer()
                        Text("1 push-up = 1 minute")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Detection")
                        Spacer()
                        Text("CoreMotion (accelerometer)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .familyActivityPicker(isPresented: $showAppPicker, selection: $screenTimeManager.selection)
            .confirmationDialog("Reset your time bank to zero?", isPresented: $showResetConfirm, titleVisibility: .visible) {
                Button("Reset", role: .destructive) {
                    timeBankManager.resetBank()
                    screenTimeManager.lockApps()
                }
            }
        }
    }
}
