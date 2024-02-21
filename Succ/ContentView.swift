import SwiftUI

struct ContentView: View {
    @ObservedObject var pullRequest: PullRequest

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView(
        pullRequest: PullRequest(apollo: buildApolloClient(token: ""))
    )
}
