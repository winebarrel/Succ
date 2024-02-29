import SwiftUI

struct ContentView: View {
    enum Tab: Hashable {
        case settled
        case pending
    }

    @ObservedObject var pullRequest: PullRequest
    @State private var selection = Tab.settled

    var body: some View {
        VStack {
            TabView(selection: $selection) {
                PullRequestListView(pullRequest: pullRequest, pendingList: false)
                    .tabItem {
                        Text("Settled (\(pullRequest.nodes.count))")
                    }
                    .tag(Tab.settled)
                PullRequestListView(pullRequest: pullRequest, pendingList: true)
                    .tabItem {
                        Text("Pending (\(pullRequest.pendingNodes.count))")
                    }
                    .tag(Tab.pending)
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
