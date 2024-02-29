import SwiftUI

struct PullRequestListView: View {
    @ObservedObject var pullRequest: PullRequest
    @State private var hoverId = ""
    @State private var commentId = ""
    var pendingList: Bool

    var body: some View {
        let nodes = pendingList ? pullRequest.pendingNodes : pullRequest.nodes

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
        } else if nodes.isEmpty {
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
            List(nodes) { node in
                VStack(alignment: .leading) {
                    Text(node.ownerRepo)
                        .font(.caption2)
                        .multilineTextAlignment(.leading)
                    let commentText = Text(node.comment ?? "")
                    HStack {
                        Link(destination: URL(string: node.url)!) {
                            let label = pendingList ? node.title : node.statusEmoji + node.title
                            Text(label)
                                .multilineTextAlignment(.leading)
                        }
                        .underline(hoverId == node.id)
                        .onHover { hovering in
                            hoverId = hovering ? node.id : ""
                        }
                        if node.comment != nil {
                            Button {
                                if commentId.isEmpty {
                                    commentId = node.id
                                } else {
                                    commentId = ""
                                }
                            } label: {
                                Image(systemName: "bubble")
                            }
                        }
                    }
                    if node.comment != nil {
                        commentText
                            .font(.footnote)
                            .hidden(commentId != node.id)
                    }
                }
            }
        }
    }
}

#Preview {
    PullRequestListView(
        pullRequest: PullRequest(),
        pendingList: false
    )
}
