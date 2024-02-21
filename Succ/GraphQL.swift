import Apollo
import Foundation

func buildApolloClient(token: String) -> ApolloClient {
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
}
