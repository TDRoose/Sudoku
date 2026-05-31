import Foundation

struct Cell: Codable, Equatable {
    var value: Int?
    var notes: Set<Int> = []
    var isGiven: Bool = false

    var isEmpty: Bool { value == nil }

    mutating func clearUserEntry() {
        guard !isGiven else { return }
        value = nil
        notes = []
    }
}
