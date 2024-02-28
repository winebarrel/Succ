import SwiftUI

struct ContentView: View {
    @ObservedObject var pullRequest: PullRequest
    @State private var selection = 1

    var body: some View {
        VStack {
            TabView(selection: $selection) {
                SettledListView(
                    pullRequest: pullRequest
                )
                .tabItem { Text("Settled (\(pullRequest.nodes.count))") }
                .tag(1)
                PendingListView(
                    pullRequest: pullRequest
                )
                .tabItem { Text("Pending (\(pullRequest.pendingNodes.count))") }
                .tag(2)
            }
            .padding(.top, 5)
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                Text(pullRequest.updatedAt)
            }
            .padding(.bottom, 5)
        }
        .background(.background)
    }
}

#Preview {
    ContentView(
        pullRequest: PullRequest()
    )
}
