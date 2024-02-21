import Apollo
import Foundation

extension PullRequest.Nodes {
    mutating func replaceAll(_ newNodes: PullRequest.Nodes) {
        replaceSubrange(0 ..< count, with: newNodes)
    }
}

class PullRequest: ObservableObject {
    struct Node: Identifiable {
        let title: String
        let url: String
        let reviewDecision: String
        let state: String

        var id: String {
            url
        }
    }

    typealias Nodes = [Node]

    private var apollo: ApolloClient?
    private var githubQuery = Constants.defaultGithubQuery
    var initialized = false

    @Published var nodes: [Node] = []
    @Published var errorMessage: String = ""

    func configure(token: String, query: String) {
        initialized = true

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
        var newNodes: Nodes = []

        value.data?.search.nodes?.forEach { body in
            if let pull = body?.asPullRequest {
                if let reviewDecision = pull.reviewDecision, reviewDecision != .approved {
                    return
                }

                guard let state = pull.commits.nodes?.first??.commit.statusCheckRollup?.state else {
                    return
                }

                if state != .success {
                    return
                }

                let node = Node(
                    title: pull.title,
                    url: pull.url,
                    reviewDecision: pull.reviewDecision?.rawValue ?? "",
                    state: pull.commits.nodes?.first??.commit.statusCheckRollup?.state.rawValue ?? ""
                )

                newNodes.append(node)
            }
        }

        nodes.replaceAll(newNodes)
    }

    func update(showError: Bool = false) {
        errorMessage = ""
        let query = Github.SearchPullRequestsQuery(query: githubQuery)

        apollo?.fetch(query: query) { result in
            switch result {
            case .success(let value):
                self.updateNodes(value)
            case .failure(let error):
                AppLogger.shared.debug("failed to search GitHub: \(error)")

                if showError {
                    self.errorMessage = self.unwrapError(error)
                }
            }

            // TODO: debug
            print(self.nodes)
        }
    }
}
