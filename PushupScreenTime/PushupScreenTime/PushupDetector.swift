import CoreMotion
import UIKit

class PushupDetector: ObservableObject {
    private let motion = CMMotionManager()
    private let haptics = UIImpactFeedbackGenerator(style: .medium)

    @Published var count = 0
    @Published var isDetecting = false
    @Published var currentPhase: Phase = .up

    enum Phase { case up, down }

    // Tune these if detection feels off
    private let downThreshold = -0.40  // g-force to register "going down"
    private let upThreshold   =  0.35  // g-force to register "coming back up"
    private let minRepInterval: TimeInterval = 0.5  // debounce

    private var lastRepTime: Date = .distantPast

    func start() {
        guard motion.isDeviceMotionAvailable else { return }
        count = 0
        currentPhase = .up
        isDetecting = true
        haptics.prepare()

        motion.deviceMotionUpdateInterval = 1.0 / 30.0
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }
            self.process(data)
        }
    }

    func stop() {
        motion.stopDeviceMotionUpdates()
        isDetecting = false
    }

    private func process(_ data: CMDeviceMotion) {
        // userAcceleration strips gravity; z is vertical when phone lies flat on your back.
        let z = data.userAcceleration.z

        switch currentPhase {
        case .up:
            if z < downThreshold { currentPhase = .down }

        case .down:
            if z > upThreshold {
                let now = Date.now
                guard now.timeIntervalSince(lastRepTime) > minRepInterval else { return }
                lastRepTime = now
                currentPhase = .up
                count += 1
                haptics.impactOccurred()
            }
        }
    }
}
