import Valet

enum AppValet {
    static let shared = Valet.valet(with: Identifier(nonEmpty: "jp.winebarrel.Succ")!, accessibility: .whenUnlocked)

    static var githubToken: String {
        get {
            do {
                return try self.shared.string(forKey: "githubToken")
            } catch KeychainError.itemNotFound {
                // nothing to do
            } catch {
                AppLogger.shared.error("failed to get githubToken from Valet: \(error)")
            }

            return ""
        }

        set(token) {
            do {
                if token.isEmpty {
                    try self.shared.removeObject(forKey: "githubToken")
                } else {
                    try self.shared.setString(token, forKey: "githubToken")
                }
            } catch {
                AppLogger.shared.error("failed to set githubToken to Valet: \(error)")
            }
        }
    }
}
