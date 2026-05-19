import SwiftUI

struct ContentView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false

    var body: some View {
        if !hasCompletedSetup || !screenTimeManager.isAuthorized {
            SetupView()
        } else {
            DashboardView()
        }
    }
}
