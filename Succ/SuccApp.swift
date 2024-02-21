import MenuBarExtraAccess
import SwiftUI

@main
struct SuccApp: App {
    @State var isMenuPresented = false
    @State var githubToken = AppValet.githubToken
    @StateObject var pullRequest = PullRequest(apollo: buildApolloClient(token: AppValet.githubToken))

    private var popover: NSPopover = {
        let pop = NSPopover()
        pop.behavior = .transient
        pop.animates = false
        return pop
    }()

    var body: some Scene {
        MenuBarExtra {
            RightClickMenu(pullRequest: pullRequest)
        } label: {
            Image(systemName: "leaf")
        }.menuBarExtraAccess(isPresented: $isMenuPresented) { statusItem in
            if popover.contentViewController == nil {
                let view = ContentView(pullRequest: pullRequest)
                popover.contentViewController = NSHostingController(rootView: view)
            }

            if let button = statusItem.button {
                let mouseHandlerView = MouseHandlerView(frame: button.frame)

                mouseHandlerView.onMouseDown = {
                    if popover.isShown {
                        popover.performClose(nil)
                    } else {
                        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.maxY)
                        popover.contentViewController?.view.window?.makeKey()
                    }
                }

                button.addSubview(mouseHandlerView)
            }
        }
        Settings {
            SettingView(
                githubToken: $githubToken
            ).onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { notification in
                if let window = notification.object as? NSWindow, window.title == "Succ Settings" {
                    pullRequest.apollo = buildApolloClient(token: githubToken)
                    pullRequest.update()
                }
            }
        }
    }
}
