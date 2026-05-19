import Foundation
import UserNotifications

class TimeBankManager: ObservableObject {
    @Published private(set) var remainingSeconds: TimeInterval = 0

    private var expiresAt: Date {
        didSet { UserDefaults.standard.set(expiresAt, forKey: "timeBankExpiresAt") }
    }

    var isUnlocked: Bool { remainingSeconds > 0 }
    var remainingMinutes: Int { Int(remainingSeconds) / 60 }
    var remainingSecondsDisplay: Int { Int(remainingSeconds) % 60 }

    private var countdownTimer: Timer?

    init() {
        self.expiresAt = UserDefaults.standard.object(forKey: "timeBankExpiresAt") as? Date ?? .distantPast
        tick()
        startCountdown()
    }

    func addMinutes(_ minutes: Int) {
        let base = max(expiresAt, Date.now)
        expiresAt = base.addingTimeInterval(Double(minutes) * 60)
        tick()
        scheduleExpiryNotification()
    }

    func resetBank() {
        expiresAt = .distantPast
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["expiry"])
        tick()
    }

    private func tick() {
        remainingSeconds = max(0, expiresAt.timeIntervalSinceNow)
    }

    private func startCountdown() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func scheduleExpiryNotification() {
        let interval = expiresAt.timeIntervalSinceNow
        guard interval > 0 else { return }

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["expiry"])

        let content = UNMutableNotificationContent()
        content.title = "Screen Time Used Up!"
        content.body = "Hit the floor — every push-up earns you another minute."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: "expiry", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
