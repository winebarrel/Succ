import MenuBarExtraAccess
import SwiftUI

@main
struct SuccApp: App {
    var body: some Scene {
        MenuBarExtra {
            RightClickMenu()
        } label: {
            Image(systemName: "leaf")
        }
    }
}
