import MenuBarExtraAccess
import SwiftUI

@main
struct SuccApp: App {
    @State private var initialized = false
    @State private var isMenuPresented = false
    @StateObject private var pullRequest = PullRequest()
    @State private var githubToken = AppValet.githubToken
    @AppStorage("githubQuery") private var githubQuery = Constants.defaultGithubQuery

    private var popover: NSPopover = {
        let pop = NSPopover()
        pop.behavior = .transient
        pop.animates = false
        return pop
    }()

    private func initialize() {
        pullRequest.configure(
            token: githubToken,
            query: githubQuery
        )

        let view = ContentView(pullRequest: pullRequest)
        popover.contentViewController = NSHostingController(rootView: view)
    }

    var body: some Scene {
        MenuBarExtra {
            RightClickMenu(pullRequest: pullRequest)
        } label: {
            Image(systemName: "leaf")
        }.menuBarExtraAccess(isPresented: $isMenuPresented) { statusItem in
            if !initialized {
                initialize()
                initialized = true
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
            ).onClosed {
                pullRequest.configure(
                    token: githubToken,
                    query: githubQuery
                )
                pullRequest.update()
            }
        }
    }
}
