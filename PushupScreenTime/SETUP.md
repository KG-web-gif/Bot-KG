# Pushup Screen Time — Setup Guide

Earn 1 minute of screen time for every push-up you do.

## Requirements

- Mac with Xcode 15+
- iPhone running iOS 16+
- Apple Developer account (free works for personal/sideloaded builds)

---

## Step 1 — Create the Xcode project

1. Open Xcode → **File › New › Project**
2. Choose **iOS › App**
3. Fill in:
   - **Product Name:** `PushupScreenTime`
   - **Bundle ID:** `com.yourname.PushupScreenTime` (anything unique)
   - **Interface:** SwiftUI
   - **Language:** Swift
4. Click **Next** and save the project inside the `PushupScreenTime/` folder from this repo.

---

## Step 2 — Replace the generated files

Delete the files Xcode created and drag in all `.swift` files from `PushupScreenTime/PushupScreenTime/`:

- `PushupScreenTimeApp.swift`
- `ContentView.swift`
- `TimeBankManager.swift`
- `PushupDetector.swift`
- `ScreenTimeManager.swift`
- `SetupView.swift`
- `DashboardView.swift`
- `WorkoutView.swift`
- `SettingsView.swift`
- `ButtonStyles.swift`

Also replace `Info.plist` with the one from this repo.

---

## Step 3 — Add the FamilyControls capability

1. In Xcode, select your project in the Navigator (top-left).
2. Select the **PushupScreenTime** target.
3. Go to the **Signing & Capabilities** tab.
4. Click **+ Capability** and add **Family Controls**.

This automatically adds the `com.apple.developer.family-controls` entitlement your app needs to lock/unlock apps.

---

## Step 4 — Add frameworks

In the **General** tab → **Frameworks, Libraries, and Embedded Content**, add:

- `FamilyControls.framework`
- `ManagedSettings.framework`

(Xcode may add these automatically when you add the capability.)

---

## Step 5 — Build & run on your iPhone

1. Connect your iPhone via USB (or use wireless pairing).
2. Select your iPhone as the run destination.
3. Press **⌘R** to build and run.
4. Trust the developer certificate on your phone if prompted:
   **Settings › General › VPN & Device Management › your Apple ID → Trust**

---

## How to use

1. **First launch:** Grant Screen Time permission, then select which apps to lock.
2. **Main screen:** Shows your remaining time and whether apps are locked.
3. **Do push-ups:** Tap "Do Push-ups", place your iPhone flat on the floor next to you (face up), get into push-up position, and start. The counter ticks up automatically.
4. **Save:** Tap "Stop & Save" — your earned minutes are added to the bank immediately.

### Push-up detection tips

- Place the phone **flat on the floor** face-up, within arm's reach.
- The accelerometer detects your body's up-down motion through subtle vibration/movement of the floor.
- Alternatively, hold the phone in one hand while doing one-arm push-ups — detection works either way.
- If it's undercounting, move the phone closer to you. If overcounting, check `PushupDetector.swift` and lower `downThreshold` / `upThreshold`.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| "Family Controls" capability is greyed out | Sign in to Xcode with your Apple ID under Preferences › Accounts |
| Apps aren't being locked | Make sure you selected apps in Settings and that Screen Time is enabled on your device (Settings › Screen Time) |
| Push-ups aren't detected | Try adjusting the thresholds in `PushupDetector.swift` |
| Notification not showing | Check Settings › Notifications › PushupScreenTime is enabled |
