import ServiceManagement
import SwiftUI

struct SettingView: View {
    @Binding var githubToken: String
    @AppStorage("githubQuery") private var githubQuery = Constants.defaultGithubQuery
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled
    @AppStorage("timerInterval") private var timerInterval: TimeInterval = Constants.defaultTimerInterval

    var body: some View {
        Form {
            SecureField("GitHub token", text: $githubToken).onChange(of: githubToken) {
                AppValet.githubToken = githubToken
            }
            HStack {
                TextField("GitHub query", text: $githubQuery)
                Link(destination: URL(string: "https://github.com/pulls?q=" + (githubQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))!) {
                    Image(systemName: "magnifyingglass")
                }
            }
            TextField("Interval (sec)", value: $timerInterval, format: .number.grouping(.never))
                .onChange(of: timerInterval) {
                    if timerInterval < 1 {
                        timerInterval = 1
                    } else if timerInterval > 3600 {
                        timerInterval = 3600
                    }
                }
            Toggle("Launch at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) {
                    do {
                        if launchAtLogin {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        AppLogger.shared.debug("failed to update 'Launch at login': \(error)")
                    }
                }

            // swiftlint:disable force_cast
            let appVer = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            let buildVer = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
            // swiftlint:enable force_cast
            Text("Ver. \(appVer).\(buildVer)")
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(20)
        .frame(width: 400)
    }

    func onClosed(_ action: @escaping () -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { notification in
            if let window = notification.object as? NSWindow, window.title == "Succ Settings" {
                action()
            }
        }
    }
}

#Preview {
    SettingView(
        githubToken: .constant("")
    )
}
