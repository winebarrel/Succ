import SwiftUI

struct RightClickMenu: View {
    @ObservedObject var pullRequest: PullRequest

    var body: some View {
        Button("Pull Requests") {
            Task {
                let url = URL(string: "https://github.com/pulls")!
                NSWorkspace.shared.open(url)
            }
        }
        Button("Issues") {
            Task {
                let url = URL(string: "https://github.com/issues")!
                NSWorkspace.shared.open(url)
            }
        }
        Divider()
        Button("Update Manually") {
            pullRequest.update()
        }
        SettingsLink {
            Text("Settings")
        }
        Divider()
        Button("Quit") {
            NSApplication.shared.terminate(self)
        }
    }
}

#Preview {
    RightClickMenu(
        pullRequest: PullRequest()
    )
}
