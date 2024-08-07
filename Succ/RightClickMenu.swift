import SwiftUI

struct RightClickMenu: View {
    @ObservedObject var pullRequest: PullRequest

    var body: some View {
        Button("Pull Requests") {
            Task {
                let url = URL(string: "https://github.com/pulls?q=" + (pullRequest.githubQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))!
                NSWorkspace.shared.open(url)
            }
        }
        Button("Issues") {
            Task {
                let url = URL(string: "https://github.com/issues")!
                NSWorkspace.shared.open(url)
            }
        }
        Button("Notifications") {
            Task {
                let url = URL(string: "https://github.com/notifications")!
                NSWorkspace.shared.open(url)
            }
        }
        Divider()
        Button("Update Manually") {
            pullRequest.update(showError: true)
        }
        SettingsLink {
            Text("Settings")
        }.preActionButtonStyle {
            NSApp.activate(ignoringOtherApps: true)
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
