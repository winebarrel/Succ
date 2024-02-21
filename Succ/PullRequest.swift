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

    var apollo: ApolloClient
    @Published var nodes: [Node] = []
    @Published var errorMessage: String = ""

    init(apollo: ApolloClient) {
        self.apollo = apollo
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

    func update(showError: Bool = false) {
        errorMessage = ""
        let query = Github.SearchPullRequestsQuery(query: "is:open is:pr author:@me org:qubole") // TODO: fix

        apollo.fetch(query: query) { result in
            switch result {
            case .success(let value):
                print(value) // TODO: fix
            case .failure(let error):
                AppLogger.shared.debug("failed to search GitHub: \(error)")

                if showError {
                    self.errorMessage = self.unwrapError(error)
                }
            }
        }
    }
}
