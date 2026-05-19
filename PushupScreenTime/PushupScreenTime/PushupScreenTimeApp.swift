import SwiftUI

@main
struct PushupScreenTimeApp: App {
    @StateObject private var timeBankManager = TimeBankManager()
    @StateObject private var screenTimeManager = ScreenTimeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timeBankManager)
                .environmentObject(screenTimeManager)
        }
    }
}
