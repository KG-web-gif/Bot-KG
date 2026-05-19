import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var timeBankManager: TimeBankManager
    @StateObject private var detector = PushupDetector()
    @Environment(\.dismiss) private var dismiss

    @State private var sessionEarned = 0
    @State private var showDone = false
    @State private var repBounce = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                if !detector.isDetecting {
                    InstructionsCard()
                    Spacer()

                    Button("Start Detecting") { detector.start() }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.bottom, 40)
                } else {
                    Spacer()
                    repCounter
                    earnedLabel
                    phaseIndicator
                    Spacer()

                    Button("Stop & Save") { finishSession() }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.bottom, 40)
                }
            }
            .padding(.horizontal)
            .navigationTitle("Push-up Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        detector.stop()
                        dismiss()
                    }
                }
            }
            .alert("Nice work! 💪", isPresented: $showDone) {
                Button("Done") {
                    timeBankManager.addMinutes(sessionEarned)
                    dismiss()
                }
            } message: {
                Text("You did \(detector.count) push-up\(detector.count == 1 ? "" : "s") and earned \(sessionEarned) minute\(sessionEarned == 1 ? "" : "s").")
            }
        }
    }

    // MARK: - Sub-views

    private var repCounter: some View {
        Text("\(detector.count)")
            .font(.system(size: 120, weight: .black, design: .rounded))
            .foregroundStyle(.orange)
            .scaleEffect(repBounce ? 1.15 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.4), value: repBounce)
            .onChange(of: detector.count) { _, _ in
                repBounce = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { repBounce = false }
            }
    }

    private var earnedLabel: some View {
        let mins = detector.count
        return Text("= \(mins) minute\(mins == 1 ? "" : "s") earned")
            .font(.title3)
            .foregroundStyle(.secondary)
    }

    private var phaseIndicator: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(detector.currentPhase == .up ? Color.green : Color(.systemGray4))
                .frame(width: 12, height: 12)
            Text(detector.currentPhase == .up ? "UP" : "DOWN")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .animation(nil, value: detector.currentPhase)
        }
        .animation(.easeInOut(duration: 0.1), value: detector.currentPhase)
    }

    // MARK: - Actions

    private func finishSession() {
        detector.stop()
        sessionEarned = detector.count
        showDone = true
    }
}

// MARK: - Instructions

private struct InstructionsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("How to use", systemImage: "info.circle")
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                step("1", "Place your phone flat on the floor beside you, face up.")
                step("2", "Tap **Start Detecting** then get into push-up position.")
                step("3", "The counter increases automatically each rep.")
                step("4", "Tap **Stop & Save** when you're done to bank your minutes.")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func step(_ number: String, _ text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.headline)
                .foregroundStyle(.orange)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }
}
