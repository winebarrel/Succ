import Apollo
import Foundation
import SwiftUI
import UserNotifications

extension PullRequest.Nodes {
    mutating func replaceAll(_ newNodes: PullRequest.Nodes) {
        replaceSubrange(0 ..< count, with: newNodes)
    }
}

func - (left: PullRequest.Nodes, right: PullRequest.Nodes) -> PullRequest.Nodes {
    let rightIDs = right.map { $0.id }
    return left.filter { !rightIDs.contains($0.id) }
}

class PullRequest: ObservableObject {
    struct Node: Identifiable {
        let owner: String
        let repo: String
        let title: String
        let url: String
        let reviewDecision: String
        let state: String
        let commitUrl: String
        let success: Bool

        var id: String {
            commitUrl
        }

        var titleWithRepo: String {
            "[\(owner)/\(repo)] \(title)"
        }

        var statusEmoji: String {
            success ? "✅" : "❌"
        }
    }

    typealias Nodes = [Node]

    private var apollo: ApolloClient?
    var githubQuery = Constants.defaultGithubQuery

    @Published var nodes: [Node] = []
    @Published var updatedAt = "-"
    @Published var errorMessage: String = ""

    private let dateFmt = {
        let dtfmt = DateFormatter()
        dtfmt.dateStyle = .none
        dtfmt.timeStyle = .short
        return dtfmt
    }()

    func configure(token: String, query: String) {
        apollo = {
            let cache = InMemoryNormalizedCache()
            let store = ApolloStore(cache: cache)
            let client = URLSessionClient()
            let provider = DefaultInterceptorProvider(client: client, store: store)
            let url = URL(string: "https://api.github.com/graphql")!
            let transport = RequestChainNetworkTransport(
                interceptorProvider: provider,
                endpointURL: url,
                additionalHeaders: ["Authorization": "Bearer \(token)"]
            )
            return ApolloClient(networkTransport: transport, store: store)
        }()

        githubQuery = query
    }

    private func unwrapError(_ err: Error) -> String {
        var errmsg = err.localizedDescription

        guard let err = err as? Apollo.ResponseCodeInterceptor.ResponseCodeError else {
            return errmsg
        }

        switch err {
        case .invalidResponseCode(let resp, _):
            if let resp {
                let statusCode = resp.statusCode
                let statusMsg = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                errmsg = "GitHub API error: \(statusCode) \(statusMsg)"
            }
        }

        return errmsg
    }

    private func updateNodes(_ value: GraphQLResult<Github.SearchPullRequestsQuery.Data>) {
        var fetchedNodes: Nodes = []

        value.data?.search.nodes?.forEach { body in
            if let pull = body?.asPullRequest {
                if let reviewDecision = pull.reviewDecision, reviewDecision != .approved {
                    return
                }

                guard let commit = pull.commits.nodes?.first??.commit else {
                    return
                }

                guard let state = commit.statusCheckRollup?.state else {
                    return
                }

                if state != .success && state != .failure && state != .error {
                    return
                }

                let node = Node(
                    owner: pull.repository.owner.login,
                    repo: pull.repository.name,
                    title: pull.title,
                    url: pull.url,
                    reviewDecision: pull.reviewDecision?.rawValue ?? "",
                    state: state.rawValue,
                    commitUrl: commit.url,
                    success: state == .success
                )

                fetchedNodes.append(node)
            }
        }

        let newNodes = fetchedNodes - nodes
        nodes.replaceAll(fetchedNodes)

        if newNodes.count > 0 {
            notify(newNodes)
        }

        updatedAt = dateFmt.string(from: Date())
    }

    private func notify(_ newNodes: Nodes) {
        Task {
            let userNotificationCenter = UNUserNotificationCenter.current()

            for node in newNodes {
                let content = UNMutableNotificationContent()
                content.title = node.statusEmoji + node.titleWithRepo
                content.userInfo = ["url": node.url]
                content.sound = UNNotificationSound.default

                let req = UNNotificationRequest(identifier: "jp.winebarrel.Succ.\(node.id)", content: content, trigger: nil)
                try? await userNotificationCenter.add(req)
            }
        }
    }

    func update(showError: Bool = false) {
        errorMessage = ""
        let query = Github.SearchPullRequestsQuery(query: githubQuery)

        apollo?.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely) { result in
            switch result {
            case .success(let value):
                self.updateNodes(value)
            case .failure(let error):
                AppLogger.shared.debug("failed to search GitHub: \(error)")

                if showError {
                    self.errorMessage = self.unwrapError(error)
                }
            }
        }
    }
}
