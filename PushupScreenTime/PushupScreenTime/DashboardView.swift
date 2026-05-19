import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var timeBankManager: TimeBankManager
    @EnvironmentObject var screenTimeManager: ScreenTimeManager

    @State private var showWorkout = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                StatusRing()
                TimerDisplay()
                Spacer()

                VStack(spacing: 16) {
                    Button("Do Push-ups") { showWorkout = true }
                        .buttonStyle(PrimaryButtonStyle())

                    if !timeBankManager.isUnlocked {
                        Text("Apps are currently locked")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal)
            .navigationTitle("Pushup Screen Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings") { showSettings = true }
                }
            }
        }
        .sheet(isPresented: $showWorkout) {
            WorkoutView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onChange(of: timeBankManager.isUnlocked) { _, unlocked in
            unlocked ? screenTimeManager.unlockApps() : screenTimeManager.lockApps()
        }
        .onAppear {
            timeBankManager.isUnlocked ? screenTimeManager.unlockApps() : screenTimeManager.lockApps()
        }
    }
}

// MARK: - Ring

private struct StatusRing: View {
    @EnvironmentObject var timeBankManager: TimeBankManager

    private var maxSeconds: Double { 60 * 60 } // 60 min cap for display
    private var progress: Double {
        min(timeBankManager.remainingSeconds / maxSeconds, 1.0)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 16)
                .frame(width: 200, height: 200)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    timeBankManager.isUnlocked ? Color.green : Color.red,
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            Image(systemName: timeBankManager.isUnlocked ? "lock.open.fill" : "lock.fill")
                .font(.system(size: 48))
                .foregroundStyle(timeBankManager.isUnlocked ? .green : .red)
        }
    }
}

// MARK: - Timer display

private struct TimerDisplay: View {
    @EnvironmentObject var timeBankManager: TimeBankManager

    var body: some View {
        VStack(spacing: 4) {
            if timeBankManager.isUnlocked {
                Text(timeString)
                    .font(.system(size: 52, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)
                Text("remaining")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("0:00")
                    .font(.system(size: 52, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)
                Text("no time earned")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var timeString: String {
        let m = timeBankManager.remainingMinutes
        let s = timeBankManager.remainingSecondsDisplay
        return String(format: "%d:%02d", m, s)
    }
}
