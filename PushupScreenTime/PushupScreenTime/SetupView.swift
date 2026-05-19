import SwiftUI
import FamilyControls

struct SetupView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false
    @State private var step = 0

    var body: some View {
        VStack(spacing: 0) {
            switch step {
            case 0: WelcomeStep(onNext: { step = 1 })
            case 1: PermissionsStep(onNext: { step = 2 })
            default: AppPickerStep(onDone: { hasCompletedSetup = true })
            }
        }
        .animation(.easeInOut, value: step)
    }
}

// MARK: - Step 1: Welcome

private struct WelcomeStep: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 80))
                .foregroundStyle(.orange)

            VStack(spacing: 12) {
                Text("Pushup Screen Time")
                    .font(.largeTitle.bold())
                Text("Earn 1 minute of screen time\nfor every push-up you do.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()

            Button("Get Started", action: onNext)
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)
                .padding(.bottom, 40)
        }
        .padding()
    }
}

// MARK: - Step 2: Screen Time Permission

private struct PermissionsStep: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "lock.shield")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            VStack(spacing: 12) {
                Text("Screen Time Access")
                    .font(.title.bold())
                Text("The app needs Screen Time permission to lock and unlock apps based on your push-up balance.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()

            Button("Allow Screen Time Access") {
                Task {
                    await screenTimeManager.requestAuthorization()
                    if screenTimeManager.isAuthorized { onNext() }
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .padding()
    }
}

// MARK: - Step 3: Pick apps to restrict

private struct AppPickerStep: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var showPicker = false
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "apps.iphone")
                .font(.system(size: 80))
                .foregroundStyle(.purple)

            VStack(spacing: 12) {
                Text("Choose Apps to Lock")
                    .font(.title.bold())
                Text("Select the apps that get locked when you're out of earned time.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()

            VStack(spacing: 16) {
                Button("Select Apps") { showPicker = true }
                    .buttonStyle(SecondaryButtonStyle())

                Button("Done", action: onDone)
                    .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .padding()
        .familyActivityPicker(isPresented: $showPicker, selection: $screenTimeManager.selection)
    }
}
