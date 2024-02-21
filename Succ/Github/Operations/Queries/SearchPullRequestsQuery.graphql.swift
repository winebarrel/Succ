// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension Github {
  class SearchPullRequestsQuery: GraphQLQuery {
    static let operationName: String = "SearchPullRequests"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query SearchPullRequests($query: String!) { search(type: ISSUE, last: 100, query: $query) { __typename nodes { __typename ... on PullRequest { title url reviewDecision commits(last: 1) { __typename nodes { __typename commit { __typename statusCheckRollup { __typename state } } } } } } } }"#
      ))

    public var query: String

    public init(query: String) {
      self.query = query
    }

    public var __variables: Variables? { ["query": query] }

    struct Data: Github.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: ApolloAPI.ParentType { Github.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("search", Search.self, arguments: [
          "type": "ISSUE",
          "last": 100,
          "query": .variable("query")
        ]),
      ] }

      /// Perform a search across resources, returning a maximum of 1,000 results.
      var search: Search { __data["search"] }

      /// Search
      ///
      /// Parent Type: `SearchResultItemConnection`
      struct Search: Github.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: ApolloAPI.ParentType { Github.Objects.SearchResultItemConnection }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("nodes", [Node?]?.self),
        ] }

        /// A list of nodes.
        var nodes: [Node?]? { __data["nodes"] }

        /// Search.Node
        ///
        /// Parent Type: `SearchResultItem`
        struct Node: Github.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: ApolloAPI.ParentType { Github.Unions.SearchResultItem }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .inlineFragment(AsPullRequest.self),
          ] }

          var asPullRequest: AsPullRequest? { _asInlineFragment() }

          /// Search.Node.AsPullRequest
          ///
          /// Parent Type: `PullRequest`
          struct AsPullRequest: Github.InlineFragment {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            typealias RootEntityType = SearchPullRequestsQuery.Data.Search.Node
            static var __parentType: ApolloAPI.ParentType { Github.Objects.PullRequest }
            static var __selections: [ApolloAPI.Selection] { [
              .field("title", String.self),
              .field("url", Github.URI.self),
              .field("reviewDecision", GraphQLEnum<Github.PullRequestReviewDecision>?.self),
              .field("commits", Commits.self, arguments: ["last": 1]),
            ] }

            /// Identifies the pull request title.
            var title: String { __data["title"] }
            /// The HTTP URL for this pull request.
            var url: Github.URI { __data["url"] }
            /// The current status of this pull request with respect to code review.
            var reviewDecision: GraphQLEnum<Github.PullRequestReviewDecision>? { __data["reviewDecision"] }
            /// A list of commits present in this pull request's head branch not present in the base branch.
            var commits: Commits { __data["commits"] }

            /// Search.Node.AsPullRequest.Commits
            ///
            /// Parent Type: `PullRequestCommitConnection`
            struct Commits: Github.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: ApolloAPI.ParentType { Github.Objects.PullRequestCommitConnection }
              static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("nodes", [Node?]?.self),
              ] }

              /// A list of nodes.
              var nodes: [Node?]? { __data["nodes"] }

              /// Search.Node.AsPullRequest.Commits.Node
              ///
              /// Parent Type: `PullRequestCommit`
              struct Node: Github.SelectionSet {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                static var __parentType: ApolloAPI.ParentType { Github.Objects.PullRequestCommit }
                static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("commit", Commit.self),
                ] }

                /// The Git commit object
                var commit: Commit { __data["commit"] }

                /// Search.Node.AsPullRequest.Commits.Node.Commit
                ///
                /// Parent Type: `Commit`
                struct Commit: Github.SelectionSet {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  static var __parentType: ApolloAPI.ParentType { Github.Objects.Commit }
                  static var __selections: [ApolloAPI.Selection] { [
                    .field("__typename", String.self),
                    .field("statusCheckRollup", StatusCheckRollup?.self),
                  ] }

                  /// Check and Status rollup information for this commit.
                  var statusCheckRollup: StatusCheckRollup? { __data["statusCheckRollup"] }

                  /// Search.Node.AsPullRequest.Commits.Node.Commit.StatusCheckRollup
                  ///
                  /// Parent Type: `StatusCheckRollup`
                  struct StatusCheckRollup: Github.SelectionSet {
                    let __data: DataDict
                    init(_dataDict: DataDict) { __data = _dataDict }

                    static var __parentType: ApolloAPI.ParentType { Github.Objects.StatusCheckRollup }
                    static var __selections: [ApolloAPI.Selection] { [
                      .field("__typename", String.self),
                      .field("state", GraphQLEnum<Github.StatusState>.self),
                    ] }

                    /// The combined status for the commit.
                    var state: GraphQLEnum<Github.StatusState> { __data["state"] }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

}