import Apollo
import Foundation

class PullRequest: ObservableObject {
    struct Node: Codable {
        let title: String
        let url: String
        let reviewDecision: String
        let state: String
    }

    var apollo: ApolloClient
    @Published var nodes: [Node] = []
    @Published var errorMessage: String = ""

    init(apollo: ApolloClient) {
        self.apollo = apollo
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
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
