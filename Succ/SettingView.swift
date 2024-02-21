import ServiceManagement
import SwiftUI

struct SettingView: View {
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled

    var body: some View {
        Form {
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
    SettingView()
}
