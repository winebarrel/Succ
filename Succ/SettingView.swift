import ServiceManagement
import SwiftUI

struct SettingView: View {
    @Binding var githubToken: String
    @AppStorage("githubQuery") private var githubQuery = Constants.defaultGithubQuery
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled

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
        }
        .padding(20)
        .frame(width: 400)
    }
}

#Preview {
    SettingView(
        githubToken: .constant("")
    )
}
