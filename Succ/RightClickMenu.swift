import SwiftUI

struct RightClickMenu: View {
    var body: some View {
        Button("Pull Requests") {}
        Button("Issues") {}
        Divider()
        Button("Update Manually") {}
        SettingsLink {
            Text("Settings")
        }
        Divider()
        Button("Quit") {
            NSApplication.shared.terminate(self)
        }
    }
}
