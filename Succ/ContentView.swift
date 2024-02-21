import SwiftUI

struct ContentView: View {
    @ObservedObject var pullRequest: PullRequest

    var body: some View {
        VStack {
            if !pullRequest.errorMessage.isEmpty {
                HStack {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle")
                        .imageScale(.large)
                    Text(pullRequest.errorMessage)
                    Spacer()
                }
            } else if pullRequest.nodes.isEmpty {
                List {
                    HStack {
                        Spacer()
                        Image(systemName: "rectangle.portrait.on.rectangle.portrait.slash")
                            .imageScale(.large)
                        Text("No pull requests")
                        Spacer()
                    }
                }
            } else {
                // TODO: fix
                List {
                    HStack {
                        Spacer()
                        Image(systemName: "rectangle.portrait.on.rectangle.portrait.slash")
                            .imageScale(.large)
                        Text("No pull requests")
                        Spacer()
                    }
                }
            }
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                Text(pullRequest.updatedAt)
            }
            .padding(.bottom, 5)
        }.background(.background)
    }
}

#Preview {
    ContentView(
        pullRequest: PullRequest()
    )
}
