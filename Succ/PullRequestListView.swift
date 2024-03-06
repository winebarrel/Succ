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
                    Link(destination: URL(string: node.url)!) {
                        if node.draft {
                            Text("Draft")
                                .font(.caption)
                                .padding(.horizontal, 3)
                                .foregroundColor(.white)
                                .background(.gray, in: RoundedRectangle(cornerRadius: 5))
                        }
                        let label = pendingList ? node.title : node.statusEmoji + node.title
                        Text(label)
                            .multilineTextAlignment(.leading)
                    }
                    .underline(hoverId == node.id)
                    .onHover { hovering in
                        hoverId = hovering ? node.id : ""
                    }
                    if let comment = node.comment, let author = node.commentAuthor {
                        let commentText = Text(comment)

                        Button {
                            if commentId != node.id {
                                commentId = node.id
                            } else {
                                commentId = ""
                            }
                        } label: {
                            HStack(spacing: 0) {
                                Image(systemName: commentId != node.id ? "bubble" : "bubble.fill")
                                Text("@\(author)")
                                    .font(.footnote)
                            }
                        }
                        .buttonStyle(.plain)
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
