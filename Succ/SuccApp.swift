import MenuBarExtraAccess
import SwiftUI
import UserNotifications

@main
struct SuccApp: App {
    @State private var initialized = false
    @State private var isMenuPresented = false
    @StateObject private var pullRequest = PullRequest()
    @State private var githubToken = AppValet.githubToken
    @AppStorage("githubQuery") private var githubQuery = Constants.defaultGithubQuery
    @State private var timer: Timer?
    @AppStorage("timerInterval") private var timerInterval: TimeInterval = Constants.defaultTimerInterval

    private var popover: NSPopover = {
        let pop = NSPopover()
        pop.behavior = .transient
        pop.animates = false
        pop.contentSize = NSSize(width: 500, height: 400)
        return pop
    }()

    private func initialize() {
        let userNotificationCenter = UNUserNotificationCenter.current()

        userNotificationCenter.requestAuthorization(options: [.alert, .sound]) { authorized, _ in
            guard authorized else {
                AppLogger.shared.debug("user notificationCentern not authorized")
                return
            }
        }

        pullRequest.configure(
            token: githubToken,
            query: githubQuery
        )

        let view = ContentView(pullRequest: pullRequest)
        popover.contentViewController = NSHostingController(rootView: view)

        scheduleUpdate()
    }

    func scheduleUpdate() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
            pullRequest.update()
        }
        timer?.fire()
    }

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        MenuBarExtra {
            RightClickMenu(pullRequest: pullRequest)
        } label: {
            if pullRequest.nodes.isEmpty {
                Image("checked.black")
            } else if pullRequest.nodes.allSatisfy({ $0.success }) {
                Image("checked")
            } else {
                Image("checked.red")
            }
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

                scheduleUpdate()
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        UNUserNotificationCenter.current().delegate = self
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        guard let url = userInfo["url"] as? String else {
            fatalError("failed to cast userInfo['url'] to String")
        }

        NSWorkspace.shared.open(URL(string: url)!)
        completionHandler()
    }
}
