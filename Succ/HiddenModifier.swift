// from https://tomolog.reafo.io/jp/article/swiftui-view-hidden-visible-nituite
import SwiftUI

struct HiddenModifier: ViewModifier {
    let hidden: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if self.hidden {
            EmptyView()
        } else {
            content
        }
    }
}

extension View {
    func hidden(_ hidden: Bool) -> some View {
        modifier(HiddenModifier(hidden: hidden))
    }
}
