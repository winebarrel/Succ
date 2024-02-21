import MenuBarExtraAccess
import SwiftUI

@main
struct SuccApp: App {
    @State var isMenuPresented: Bool = false

    private var popover: NSPopover = {
        let pop = NSPopover()
        pop.behavior = .transient
        pop.animates = false
        return pop
    }()

    var body: some Scene {
        MenuBarExtra {
            RightClickMenu()
        } label: {
            Image(systemName: "leaf")
        }.menuBarExtraAccess(isPresented: $isMenuPresented) { statusItem in
            if popover.contentViewController == nil {
                let view = ContentView()
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
            SettingView()
        }
    }
}
