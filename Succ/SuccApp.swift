import MenuBarExtraAccess
import SwiftUI

@main
struct SuccApp: App {
    @State var isMenuPresented = false
    @StateObject var pullRequest = PullRequest()
    @State var githubToken = AppValet.githubToken
    @AppStorage("githubQuery") private var githubQuery = Constants.defaultGithubQuery

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
            if !pullRequest.initialized {
                pullRequest.configure(
                    token: githubToken,
                    query: githubQuery
                )
            }

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
                    pullRequest.configure(
                        token: githubToken,
                        query: githubQuery
                    )
                    pullRequest.update()
                }
            }
        }
    }
}
