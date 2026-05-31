import Foundation

enum GameStore {
    private static let key = "savedGameState"
    private static let numpadOnLeftKey = "numpadOnLeft"

    static func save(_ state: GameState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func load() -> GameState? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let state = try? JSONDecoder().decode(GameState.self, from: data) else {
            return nil
        }
        return state
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    /// Default `true` — numpad on the left for left-handed layout.
    static func loadNumpadOnLeft() -> Bool {
        guard UserDefaults.standard.object(forKey: numpadOnLeftKey) != nil else {
            return true
        }
        return UserDefaults.standard.bool(forKey: numpadOnLeftKey)
    }

    static func saveNumpadOnLeft(_ onLeft: Bool) {
        UserDefaults.standard.set(onLeft, forKey: numpadOnLeftKey)
    }
}
