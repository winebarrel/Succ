import SwiftUI

struct SettledListView: View {
    @ObservedObject var pullRequest: PullRequest
    @State private var hoverId = ""

    var body: some View {
        if !pullRequest.errorMessage.isEmpty {
            List {
                HStack {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle")
                        .imageScale(.large)
                    Text(pullRequest.errorMessage)
                    Spacer()
                }
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
            List(pullRequest.nodes) { node in
                VStack(alignment: .leading) {
                    Text(node.ownerRepo)
                        .font(.caption2)
                        .multilineTextAlignment(.leading)
                    Link(destination: URL(string: node.url)!) {
                        Text(node.statusEmoji + node.title)
                            .multilineTextAlignment(.leading)
                    }
                    .underline(hoverId == node.id)
                    .onHover { hovering in
                        hoverId = hovering ? node.id : ""
                    }
                }
            }
        }
    }
}

#Preview {
    SettledListView(
        pullRequest: PullRequest()
    )
}
